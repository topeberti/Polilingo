"""
Lives system service for Polilingo.
Handles calculating current lives based on time elapsed and consuming lives.
"""

import logging
from datetime import datetime, timedelta
from typing import Dict, Any, Tuple, Optional
from supabase import Client

logger = logging.getLogger(__name__)

class LivesService:
    def __init__(self, supabase: Client, token: str):
        self.supabase = supabase
        self.token = token

    async def get_lives_config(self) -> Tuple[int, int]:
        """Fetch max_lives and life_refill_interval_minutes from config."""
        response = self.supabase.postgrest.auth(self.token).from_("learning_path_config").select("config_key, config_value").in_("config_key", ["max_lives", "life_refill_interval_minutes"]).execute()
        
        config = {item["config_key"]: item["config_value"] for item in response.data}
        max_lives = int(config.get("max_lives", 5))
        refill_minutes = int(config.get("life_refill_interval_minutes", 240))
        
        return max_lives, refill_minutes

    async def get_current_lives(self, user_id: str) -> Dict[str, Any]:
        """
        Calculate current lives for a user in real-time.
        Returns a dictionary with current_lives and next_life_at.
        """
        # Fetch current stored stats
        response = self.supabase.postgrest.auth(self.token).from_("user_gamification_stats").select("lives, last_life_lost_at").eq("user_id", user_id).execute()
        
        if not response.data:
            return {"current_lives": 5, "next_life_at": None, "lives": 5}
            
        stats = response.data[0]
        stored_lives = stats["lives"]
        last_life_lost_at = datetime.fromisoformat(stats["last_life_lost_at"].replace('Z', '+00:00'))
        
        max_lives, refill_minutes = await self.get_lives_config()
        
        if stored_lives >= max_lives:
            return {
                "current_lives": max_lives,
                "next_life_at": None,
                "lives": stored_lives,
                "last_life_lost_at": stats["last_life_lost_at"]
            }
            
        # Calculate how many lives have refilled
        now = datetime.now(last_life_lost_at.tzinfo)
        elapsed_seconds = (now - last_life_lost_at).total_seconds()
        refilled_lives = int(elapsed_seconds // (refill_minutes * 60))
        
        current_lives = min(max_lives, stored_lives + refilled_lives)
        
        next_life_at = None
        if current_lives < max_lives:
            # Calculate when the NEXT life will be ready
            # It's (last_life_lost_at + (refilled_lives + 1) * refill_interval)
            next_life_at = last_life_lost_at + timedelta(minutes=(refilled_lives + 1) * refill_minutes)
            
        return {
            "current_lives": current_lives,
            "next_life_at": next_life_at,
            "lives": stored_lives,
            "last_life_lost_at": stats["last_life_lost_at"]
        }

    async def consume_life(self, user_id: str) -> Dict[str, Any]:
        """
        Deduct one life from the user.
        If lives were refilled, we first 'sync' the refilled lives and then subtract 1.
        """
        current_status = await self.get_current_lives(user_id)
        current_lives = current_status["current_lives"]
        max_lives, refill_minutes = await self.get_lives_config()
        
        if current_lives <= 0:
            return current_status
            
        new_lives = current_lives - 1
        now = datetime.now(datetime.utcnow().astimezone().tzinfo)
        
        # We update the database with the new lives count and the current timestamp
        # because the 'refill' starts from this moment for the newly lost life.
        update_data = {
            "lives": new_lives,
            "last_life_lost_at": now.isoformat()
        }
        
        self.supabase.postgrest.auth(self.token).from_("user_gamification_stats").update(update_data).eq("user_id", user_id).execute()
        
        # Return updated status
        return await self.get_current_lives(user_id)
