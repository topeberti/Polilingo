"""
Middleware for handling authentication and session management.
"""

from typing import Optional
from fastapi import Depends, HTTPException, Security
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from supabase import Client
from config import get_supabase
import logging

logger = logging.getLogger(__name__)

# Define the HTTP Bearer security scheme
security = HTTPBearer()


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Security(security),
    supabase: Client = Depends(get_supabase)
):
    """
    Dependency to extract and validate the current user from the Authorization header.
    
    Args:
        credentials: Bearer token credentials from Swagger UI or Authorization header
        supabase: Supabase client instance
        
    Returns:
        User object if authenticated
        
    Raises:
        HTTPException: If authentication fails
    """
    token = credentials.credentials
    
    try:
        # Get user from token
        user_response = supabase.auth.get_user(token)
        
        if not user_response or not user_response.user:
            raise HTTPException(
                status_code=401,
                detail="Invalid or expired token",
                headers={"WWW-Authenticate": "Bearer"},
            )
        
        return user_response.user
        
    except Exception as e:
        logger.error(f"Authentication error: {str(e)}")
        raise HTTPException(
            status_code=401,
            detail="Authentication failed",
            headers={"WWW-Authenticate": "Bearer"},
        )


async def get_current_user_token(
    credentials: HTTPAuthorizationCredentials = Security(security)
) -> str:
    """
    Dependency to extract just the token from the Authorization header.
    
    Args:
        credentials: Bearer token credentials from Swagger UI or Authorization header
        
    Returns:
        The access token string
    """
    return credentials.credentials
