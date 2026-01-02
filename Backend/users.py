"""
User management router for creating and managing user profiles.
"""

from fastapi import APIRouter, Depends, HTTPException, status, Security
from fastapi.security import HTTPAuthorizationCredentials
from supabase import Client
from gotrue.errors import AuthApiError
import logging
import re
import httpx
from typing import Optional, List, Set
from datetime import time as Time

from config import get_supabase
from models import (
    CreateUserRequest, CreateUserResponse,
    UpdateUserRequest, UpdateUserResponse, DeleteUserResponse,
    UserProfileData, UserProfileResponse, UserGamificationStats,
    UserProfilePublic
)
from middleware import get_current_user, security
from lives_service import LivesService

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/users", tags=["User Management"])

# Reserved usernames
RESERVED_USERNAMES: Set[str] = {
    "admin", "teacher", "student", "guest", "support", 
    "root", "system", "moderator", "bot", "settings", 
    "api", "login"
}

# Cached offensive words list
_offensive_words_cache: Optional[Set[str]] = None


async def fetch_offensive_words() -> Set[str]:
    """
    Fetch the LDNOOBW (List of Dirty, Naughty, Obscene, and Otherwise Bad Words) list.
    
    Returns:
        Set of offensive words in lowercase
    """
    global _offensive_words_cache
    
    # Return cached version if available
    if _offensive_words_cache is not None:
        return _offensive_words_cache
    
    try:
        url = "https://raw.githubusercontent.com/LDNOOBW/List-of-Dirty-Naughty-Obscene-and-Otherwise-Bad-Words/master/en"
        async with httpx.AsyncClient(timeout=10.0) as client:
            response = await client.get(url)
            response.raise_for_status()
            
            # Parse the list (one word per line)
            words = set(word.strip().lower() for word in response.text.split('\n') if word.strip())
            _offensive_words_cache = words
            
            logger.info(f"Successfully loaded {len(words)} offensive words from LDNOOBW")
            return words
            
    except Exception as e:
        logger.warning(f"Failed to fetch LDNOOBW list: {str(e)}. Offensive word filtering will be disabled.")
        # Fail-open: return empty set so validation continues
        _offensive_words_cache = set()
        return set()


def validate_username(username: str, offensive_words: Set[str]) -> tuple[bool, Optional[str]]:
    """
    Validate username according to the specified rules.
    
    Args:
        username: The username to validate
        offensive_words: Set of offensive words to check against
        
    Returns:
        Tuple of (is_valid, error_message)
    """
    # Check length
    if len(username) < 3:
        return False, "Username must be at least 3 characters long"
    if len(username) > 20:
        return False, "Username must be at most 20 characters long"
    
    # Check allowed characters (a-z, A-Z, 0-9, _)
    if not re.match(r'^[a-zA-Z0-9_]+$', username):
        return False, "Username can only contain letters, numbers, and underscores"
    
    # Check no symbols at start
    if username[0] in ['_', '.', '-']:
        return False, "Username cannot start with a symbol"
    
    # Check for consecutive repeated symbols
    if re.search(r'[._-]{2,}', username):
        return False, "Username cannot contain consecutive repeated symbols (., -, _)"
    
    # Convert to lowercase for checks
    username_lower = username.lower()
    
    # Check reserved words
    if username_lower in RESERVED_USERNAMES:
        return False, "This username is reserved and cannot be used"
    
    # Check offensive words
    if username_lower in offensive_words:
        return False, "This username contains inappropriate content"
    
    return True, None


@router.post("/create", response_model=CreateUserResponse, status_code=status.HTTP_201_CREATED)
async def create_user(
    request: CreateUserRequest,
    current_user = Depends(get_current_user),
    supabase: Client = Depends(get_supabase)
):
    """
    Create a new user profile in the users table.
    
    Requires authentication. The user must be logged in via Supabase Auth.
    
    - **username**: Unique username (3-20 chars, a-z A-Z 0-9 _, no symbols at start, no consecutive symbols)
    - **full_name**: User's full name
    - **profile_picture_url**: Optional profile picture URL
    - **preferred_study_time**: Optional preferred study time (HH:MM format)
    - **daily_goal**: Optional daily XP goal
    - **notification_preferences**: Optional notification settings
    
    Email is automatically filled from the authenticated user's account.
    """
    try:
        # Fetch offensive words list
        offensive_words = await fetch_offensive_words()
        
        # Validate username
        is_valid, error_message = validate_username(request.username, offensive_words)
        if not is_valid:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=error_message
            )
        
        # Lowercase the username before storage
        username_lower = request.username.lower()
        
        # Get email from authenticated user
        email = current_user.email
        
        # Check if user already exists in the users table
        existing_user = supabase.table("users").select("id").eq("id", current_user.id).execute()
        if existing_user.data:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="User profile already exists for this account"
            )
        
        # Check if username is already taken
        existing_username = supabase.table("users").select("username").eq("username", username_lower).execute()
        if existing_username.data:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Username is already taken"
            )
        
        # Prepare user data for insertion
        user_data = {
            "id": current_user.id,
            "username": username_lower,
            "email": email,
            "full_name": request.full_name
        }
        
        # Add optional fields only if provided
        if request.profile_picture_url:
            user_data["profile_picture_url"] = request.profile_picture_url
        
        if request.preferred_study_time:
            user_data["preferred_study_time"] = request.preferred_study_time
        
        if request.daily_goal is not None:
            user_data["daily_goal"] = request.daily_goal
        
        if request.notification_preferences is not None:
            user_data["notification_preferences"] = request.notification_preferences
        
        # Insert user into database
        response = supabase.table("users").insert(user_data).execute()
        
        if not response.data:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to create user profile"
            )
        
        # Get the created user data
        created_user = response.data[0]
        
        # Convert to response model
        user_profile = UserProfileData(
            id=created_user["id"],
            username=created_user["username"],
            email=created_user["email"],
            full_name=created_user.get("full_name"),
            profile_picture_url=created_user.get("profile_picture_url"),
            date_joined=created_user["date_joined"],
            last_active=created_user["last_active"],
            preferred_study_time=created_user.get("preferred_study_time"),
            daily_goal=created_user["daily_goal"],
            notification_preferences=created_user.get("notification_preferences"),
            account_status=created_user["account_status"],
            role=created_user["role"]
        )
        
        return CreateUserResponse(
            message="User profile created successfully",
            user=user_profile
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Unexpected error creating user: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An unexpected error occurred while creating user profile"
        )


@router.get("/profile", response_model=UserProfileResponse)
async def get_user_profile(
    current_user = Depends(get_current_user),
    supabase: Client = Depends(get_supabase),
    credentials: HTTPAuthorizationCredentials = Security(security)
):
    """
    Get the authenticated user's profile, including gamification stats.
    
    Requires authentication.
    """
    try:
        token = credentials.credentials
        
        # Aggregated Query: Fetch user profile data and gamification stats in ONE call
        # Using Supabase Resource Embedding (Join)
        # We use .execute() instead of .single() to avoid Postgrest errors when record is missing
        response = supabase.postgrest.auth(token).from_("users")\
            .select("*, user_gamification_stats(*)")\
            .eq("id", current_user.id)\
            .execute()
        
        if not response.data or len(response.data) == 0:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User profile data not found"
            )
            
        user_data = response.data[0]
        stats_data_raw = user_data.get("user_gamification_stats")
        
        # Handle gamification stats (could be list or dict depending on previous query)
        gamification_stats = None
        if stats_data_raw:
            stats_data = stats_data_raw[0] if isinstance(stats_data_raw, list) else stats_data_raw
            
            # Fetch real-time lives status, passing pre-fetched stats to avoid a second DB call
            lives_service = LivesService(supabase, token)
            lives_status = await lives_service.get_current_lives(current_user.id, stats_data=stats_data)
            
            gamification_stats = UserGamificationStats(
                total_xp=stats_data.get("total_xp", 0),
                current_level=stats_data.get("current_level", 1),
                xp_to_next_level=stats_data.get("xp_to_next_level", 100),
                current_streak=stats_data.get("current_streak", 0),
                longest_streak=stats_data.get("longest_streak", 0),
                last_streak_date=stats_data.get("last_streak_date"),
                total_lessons_completed=stats_data.get("total_lessons_completed", 0),
                total_questions_answered=stats_data.get("total_questions_answered", 0),
                total_correct_answers=stats_data.get("total_correct_answers", 0),
                total_sessions_completed=stats_data.get("total_sessions_completed", 0),
                lives=stats_data.get("lives", 5),
                last_life_lost_at=stats_data.get("last_life_lost_at", user_data.get("updated_at")),
                current_lives=lives_status["current_lives"],
                next_life_at=lives_status.get("next_life_at"),
                seconds_to_next_life=lives_status.get("seconds_to_next_life")
            )
            
        # Convert user data to pydantic model (Strict public response)
        user_profile = UserProfilePublic(
            username=user_data.get("username", "Unknown"),
            email=user_data.get("email", ""),
            full_name=user_data.get("full_name", ""),
            profile_picture_url=user_data.get("profile_picture_url"),
            preferred_study_time=user_data.get("preferred_study_time"),
            daily_goal=user_data.get("daily_goal", 50)
        )
        
        return UserProfileResponse(
            user=user_profile,
            user_gamification_stats=gamification_stats
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error fetching user profile: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch user profile: {str(e)}"
        )


@router.post("/update", response_model=UpdateUserResponse)
async def update_user(
    request: UpdateUserRequest,
    current_user = Depends(get_current_user),
    supabase: Client = Depends(get_supabase),
    credentials: HTTPAuthorizationCredentials = Security(security)
):
    """
    Update the authenticated user's profile.
    
    Requires authentication. Users can only update their own profile.
    All fields are optional - only provided fields will be updated.
    
    - **full_name**: User's full name
    - **profile_picture_url**: Profile picture URL
    - **preferred_study_time**: Preferred study time (HH:MM format)
    - **daily_goal**: Daily XP goal
    - **notification_preferences**: Notification settings
    """
    try:
        # Build update data with only provided fields
        update_data = {}
        
        if request.full_name is not None:
            update_data["full_name"] = request.full_name
        
        if request.profile_picture_url is not None:
            update_data["profile_picture_url"] = request.profile_picture_url
        
        if request.preferred_study_time is not None:
            update_data["preferred_study_time"] = request.preferred_study_time
        
        if request.daily_goal is not None:
            update_data["daily_goal"] = request.daily_goal
        
        if request.notification_preferences is not None:
            update_data["notification_preferences"] = request.notification_preferences
        
        # Check if there's anything to update
        if not update_data:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="No fields provided for update"
            )
        
        # Get the token
        token = credentials.credentials
        
        # Update user in database using authenticated client
        # We need to pass the token so RLS policies work correctly (auth.uid() = id)
        # Using count='exact' ensures we get the data back
        response = supabase.postgrest.auth(token).from_("users").update(update_data, count='exact').eq("id", current_user.id).execute()
        
        # If count is 0, then RLS blocked the update or ID didn't match
        if response.count == 0:
             raise HTTPException(status_code=500, detail="Update failed to modify row")
        
        # Get the updated user data
        updated_user = response.data[0]
        
        # Convert to response model
        user_profile = UserProfileData(
            id=updated_user["id"],
            username=updated_user["username"],
            email=updated_user["email"],
            full_name=updated_user.get("full_name"),
            profile_picture_url=updated_user.get("profile_picture_url"),
            date_joined=updated_user["date_joined"],
            last_active=updated_user["last_active"],
            preferred_study_time=updated_user.get("preferred_study_time"),
            daily_goal=updated_user["daily_goal"],
            notification_preferences=updated_user.get("notification_preferences"),
            account_status=updated_user["account_status"],
            role=updated_user["role"]
        )

        return UpdateUserResponse(
            message="User profile updated successfully",
            user=user_profile
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Unexpected error updating user: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An unexpected error occurred while updating user profile"
        )


@router.delete("/delete", response_model=DeleteUserResponse)
async def delete_user(
    current_user = Depends(get_current_user),
    supabase: Client = Depends(get_supabase),
    credentials: HTTPAuthorizationCredentials = Security(security)
):
    """
    Delete the authenticated user's profile (soft delete).
    
    Requires authentication. The user profile will be marked as 'deleted'.
    The user will not be able to log in or access data after this operation.
    """
    try:
        # Get the token
        token = credentials.credentials
        
        # Soft delete: Update account_status to 'deleted'
        # We assume RLS policies allow users to UPDATE their own profile
        # Since this is technically an update operation, the same RLS policies apply
        
        logger.info(f"Soft deleting user {current_user.id}")
        
        # Using postgrest.auth(token) to authenticate strongly for RLS
        response = supabase.postgrest.auth(token).from_("users").update({"account_status": "deleted"}, count='exact').eq("id", current_user.id).execute()
        
        # Check if update was successful (should modify 1 row)
        if response.count == 0:
             # This could happen if RLS blocked it or user not found
             logger.warning(f"Soft delete returned 0 modified rows for user {current_user.id}")
             raise HTTPException(
                 status_code=status.HTTP_404_NOT_FOUND, 
                 detail="User profile not found or already deleted"
             )
        
        logger.info(f"Successfully soft-deleted user {current_user.id}")
        
        return DeleteUserResponse(
            message="User profile deleted successfully"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Unexpected error deleting user: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to delete user profile"
        )
