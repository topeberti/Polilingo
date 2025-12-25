"""
Polilingo Backend API
Main FastAPI application entry point.
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer
import uvicorn
import logging

from config import settings
from auth import router as auth_router
from users import router as users_router
from syllabus import router as syllabus_router
from learning_path import router as learning_path_router
from history import router as history_router

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

logger = logging.getLogger(__name__)

# Initialize FastAPI app with security scheme
app = FastAPI(
    title="Polilingo API",
    description="Backend API for Polilingo - Gamified learning app for police state exam preparation",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
    swagger_ui_parameters={
        "persistAuthorization": True
    }
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth_router, prefix=settings.api_prefix)
app.include_router(users_router, prefix=settings.api_prefix)
app.include_router(syllabus_router, prefix=settings.api_prefix)
app.include_router(learning_path_router, prefix=settings.api_prefix)
app.include_router(history_router, prefix=settings.api_prefix)


@app.get("/")
async def root():
    """Root endpoint - API health check."""
    return {
        "message": "Polilingo API is running",
        "version": "1.0.0",
        "docs": "/docs"
    }


@app.get("/health")
async def health_check():
    """Health check endpoint."""
    return {"status": "healthy"}


@app.on_event("startup")
async def startup_event():
    """Run on application startup."""
    logger.info("Polilingo API starting up...")
    logger.info(f"Supabase URL: {settings.supabase_url}")
    logger.info(f"CORS origins: {settings.cors_origins}")


@app.on_event("shutdown")
async def shutdown_event():
    """Run on application shutdown."""
    logger.info("Polilingo API shutting down...")


if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )
