"""
Configuration module for the Polilingo backend.
Loads environment variables and initializes the Supabase client.
"""

import os
from dotenv import load_dotenv
from supabase import create_client, Client
from pydantic_settings import BaseSettings

# Load environment variables from .env file
load_dotenv()


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""
    
    supabase_url: str
    supabase_key: str
    
    # CORS settings
    cors_origins: list[str] = ["http://localhost:3000", "http://localhost:5173"]
    
    # API settings
    api_prefix: str = ""
    
    class Config:
        env_file = ".env"
        extra = "allow"


# Initialize settings
settings = Settings()

# Validate required settings
if not settings.supabase_url or not settings.supabase_key:
    raise ValueError(
        "SUPABASE_URL and SUPABASE_KEY must be set in .env file"
    )

# Initialize Supabase client
supabase: Client = create_client(settings.supabase_url, settings.supabase_key)


def get_supabase() -> Client:
    """
    Dependency function to get Supabase client instance.
    
    Returns:
        Client: Configured Supabase client
    """
    return supabase
