"""
Lives system service for Polilingo.
Handles calculating current lives based on time elapsed and consuming lives.
"""

import logging
from datetime import datetime, timedelta, timezone
from typing import Dict, Any, Tuple, Optional
from supabase import Client

logger = logging.getLogger(__name__)

# Simple in-memory cache for learning path config
_config_cache: Dict[str, Any] = {}
_config_cache_last_updated: Optional[datetime] = None
CONFIG_CACHE_TTL_MINUTES = 60

class LivesService:
    def __init__(self, supabase: Client, token: str):
        self.supabase = supabase
        self.token = token

    async def get_lives_config(self) -> Tuple[int, int]:
        """Fetch max_lives and life_refill_interval_minutes from config with caching."""
        global _config_cache, _config_cache_last_updated
        
        now = datetime.now(timezone.utc)
        if (_config_cache_last_updated and 
            (now - _config_cache_last_updated).total_seconds() < CONFIG_CACHE_TTL_MINUTES * 60):
            return int(_config_cache.get("max_lives", 5)), int(_config_cache.get("life_refill_interval_minutes", 240))

        try:
            response = self.supabase.postgrest.auth(self.token).from_("learning_path_config").select("config_key, config_value").in_("config_key", ["max_lives", "life_refill_interval_minutes"]).execute()
            
            _config_cache = {item["config_key"]: item["config_value"] for item in response.data}
            _config_cache_last_updated = now
            
            max_lives = int(_config_cache.get("max_lives", 5))
            refill_minutes = int(_config_cache.get("life_refill_interval_minutes", 240))
            
            return max_lives, refill_minutes
        except Exception as e:
            logger.warning(f"Failed to fetch lives config, using defaults: {str(e)}")
            return 5, 240

    async def get_current_lives(self, user_id: str, stats_data: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        """
        Calculate current lives for a user in real-time.
        Returns a dictionary with current_lives and next_life_at.
        
        Args:
            user_id: The ID of the user.
            stats_data: Optional pre-fetched gamification stats to avoid a DB call.
        """
        # Fetch current stored stats if not provided
        if not stats_data:
            response = self.supabase.postgrest.auth(self.token).from_("user_gamification_stats").select("lives, last_life_lost_at").eq("user_id", user_id).execute()
            
            if not response.data:
                return {"current_lives": 5, "next_life_at": None, "lives": 5}
            stats_data = response.data[0]
            
        stored_lives = stats_data["lives"]
        last_life_lost_at_str = stats_data["last_life_lost_at"]
        logger.info(f"get_current_lives for {user_id}: stored_lives={stored_lives}, last_lost={last_life_lost_at_str}")
        last_life_lost_at = datetime.fromisoformat(last_life_lost_at_str.replace('Z', '+00:00'))
        
        max_lives, refill_minutes = await self.get_lives_config()
        
        if stored_lives >= max_lives:
            return {
                "current_lives": max_lives,
                "next_life_at": None,
                "seconds_to_next_life": None,
                "lives": stored_lives,
                "refilled_lives": 0,
                "last_life_lost_at": last_life_lost_at_str
            }
            
        # Calculate how many lives have refilled
        now = datetime.now(timezone.utc)
        elapsed_seconds = (now - last_life_lost_at).total_seconds()
        refilled_lives = max(0, int(elapsed_seconds // (refill_minutes * 60)))
        
        current_lives = min(max_lives, stored_lives + refilled_lives)
        
        next_life_at = None
        seconds_to_next_life = None
        
        if current_lives < max_lives:
            # Calculate when the NEXT life will be ready
            # It's (refilled_lives + 1) intervals from the original last_life_lost_at
            next_life_at = last_life_lost_at + timedelta(minutes=(refilled_lives + 1) * refill_minutes)
            seconds_to_next_life = max(0, int((next_life_at - now).total_seconds()))
            
        return {
            "current_lives": current_lives,
            "next_life_at": next_life_at,
            "seconds_to_next_life": seconds_to_next_life,
            "lives": stored_lives,
            "refilled_lives": refilled_lives,
            "last_life_lost_at": last_life_lost_at_str
        }

    async def consume_life(self, user_id: str) -> Dict[str, Any]:
        """
        Deduct one life from the user.
        Preserves progress toward the next life refill by shifting the baseline.
        """
        status = await self.get_current_lives(user_id)
        current_lives = status["current_lives"]
        
        if current_lives <= 0:
            return status
            
        stored_lives = status["lives"]
        refilled_lives = status["refilled_lives"]
        max_lives, refill_minutes = await self.get_lives_config()
        
        # Original last_life_lost_at as datetime
        last_life_lost_at = datetime.fromisoformat(status["last_life_lost_at"].replace('Z', '+00:00'))
        
        # Logic: 
        # 1. Sync refilled lives to DB
        # 2. Subtract 1
        # 3. New baseline is (old baseline + refilled intervals)
        
        new_stored_lives = max(0, stored_lives + refilled_lives - 1)
        
        # If we were at max lives, the timer starts NOW
        if current_lives >= max_lives:
            new_last_life_lost_at = datetime.now(timezone.utc)
        else:
            # Otherwise, move the baseline forward by the number of lives that already refilled
            # this preserves the 'partial' interval we are currently in.
            new_last_life_lost_at = last_life_lost_at + timedelta(minutes=refilled_lives * refill_minutes)
            
        update_data = {
            "lives": new_stored_lives,
            "last_life_lost_at": new_last_life_lost_at.isoformat().replace('+00:00', 'Z')
        }
        
        logger.info(f"consume_life for {user_id}: current_lives was {current_lives}. New stored_lives: {new_stored_lives}. Update data: {update_data}")
        
        upd_res = self.supabase.postgrest.auth(self.token).from_("user_gamification_stats").update(update_data).eq("user_id", user_id).execute()
        logger.info(f"consume_life for {user_id}: Update result: {upd_res.data}")
        
        # Return updated status
        return await self.get_current_lives(user_id, stats_data=update_data)
