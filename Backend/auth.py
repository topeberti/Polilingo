"""
Authentication router implementing all auth-related endpoints.
Integrates with Supabase Auth for user management.
"""

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.responses import HTMLResponse
from supabase import Client
from gotrue.errors import AuthApiError
import logging

from config import get_supabase
from models import (
    SignupRequest, SignupResponse,
    LoginRequest, LoginResponse,
    LogoutResponse,
    UserResponse, UserData,
    PasswordResetRequest, PasswordResetResponse,
    PasswordResetConfirm, PasswordResetConfirmResponse,
    DeleteUserResponse,
    ErrorResponse, SessionData,
    RefreshRequest, RefreshResponse
)
from middleware import get_current_user, get_current_user_token

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.get("/verify", response_class=HTMLResponse)
async def verify_email_success():
    """
    Landing page for successful email verification.
    """
    html_content = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Email Verified | Polilingo</title>
        <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;600;800&display=swap" rel="stylesheet">
        <style>
            :root {
                --primary: #4F46E5;
                --primary-dark: #4338CA;
                --bg: #0F172A;
                --text: #F8FAFC;
                --text-muted: #94A3B8;
                --card-bg: #1E293B;
            }
            body {
                margin: 0;
                padding: 0;
                display: flex;
                align-items: center;
                justify-content: center;
                min-height: 100vh;
                background-color: var(--bg);
                font-family: 'Outfit', sans-serif;
                color: var(--text);
                text-align: center;
            }
            .container {
                max-width: 450px;
                padding: 2.5rem;
                background: var(--card-bg);
                border-radius: 24px;
                box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
                border: 1px solid rgba(255, 255, 255, 0.05);
                backdrop-filter: blur(10px);
                animation: fadeIn 0.8s cubic-bezier(0.16, 1, 0.3, 1);
            }
            @keyframes fadeIn {
                from { opacity: 0; transform: translateY(20px); }
                to { opacity: 1; transform: translateY(0); }
            }
            .icon-wrapper {
                width: 80px;
                height: 80px;
                background: linear-gradient(135deg, #4ade80 0%, #22c55e 100%);
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                margin: 0 auto 1.5rem;
                box-shadow: 0 0 20px rgba(34, 197, 94, 0.3);
            }
            .icon-wrapper svg {
                width: 40px;
                height: 40px;
                color: white;
            }
            h1 {
                font-size: 2rem;
                font-weight: 800;
                margin-bottom: 0.5rem;
                background: linear-gradient(to bottom right, #fff, #94a3b8);
                -webkit-background-clip: text;
                -webkit-text-fill-color: transparent;
            }
            p {
                color: var(--text-muted);
                line-height: 1.6;
                margin-bottom: 2rem;
            }
            .btn {
                display: inline-block;
                background-color: var(--primary);
                color: white;
                padding: 0.8rem 2rem;
                border-radius: 12px;
                text-decoration: none;
                font-weight: 600;
                transition: all 0.2s ease;
                box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            }
            .btn:hover {
                background-color: var(--primary-dark);
                transform: translateY(-2px);
                box-shadow: 0 10px 15px -3px rgba(79, 70, 229, 0.4);
            }
            .footer {
                margin-top: 2rem;
                font-size: 0.875rem;
                color: var(--text-muted);
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="icon-wrapper">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7" />
                </svg>
            </div>
            <h1>Email Verified!</h1>
            <p>Your email has been successfully verified. You can now return to the app and continue your learning journey.</p>
            <a href="polilingo://open" class="btn">Open Polilingo</a>
            <div class="footer">
                Polilingo &copy; 2026
            </div>
        </div>
    </body>
    </html>
    """
    return HTMLResponse(content=html_content)


@router.post("/signup", response_model=SignupResponse, status_code=status.HTTP_201_CREATED)
async def signup(
    request: SignupRequest,
    supabase: Client = Depends(get_supabase)
):
    """
    Create a new user account.
    
    - **email**: User's email address
    - **password**: User's password (minimum 6 characters)
    - **metadata**: Optional user metadata
    
    Triggers email verification. User cannot login until email is verified.
    """
    try:
        # Sign up user with Supabase
        response = supabase.auth.sign_up({
            "email": request.email,
            "password": request.password,
            "options": {
                "data": request.metadata or {}
            }
        })
        
        if not response.user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Failed to create user account"
            )
        
        # Convert user to UserData model
        user_data = None
        if response.user:
            user_data = UserData(
                id=response.user.id,
                email=response.user.email,
                email_confirmed_at=response.user.email_confirmed_at,
                created_at=response.user.created_at,
                updated_at=response.user.updated_at,
                user_metadata=response.user.user_metadata
            )
        
        return SignupResponse(
            message="Signup successful. Please check your email to verify your account.",
            user=user_data
        )
        
    except AuthApiError as e:
        logger.error(f"Signup error: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        logger.error(f"Unexpected signup error: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An unexpected error occurred during signup"
        )


@router.post("/login", response_model=LoginResponse)
async def login(
    request: LoginRequest,
    supabase: Client = Depends(get_supabase)
):
    """
    Authenticate a user and create a session.
    
    - **email**: User's email address
    - **password**: User's password
    
    Returns user information and session tokens.
    Email must be verified before login is allowed.
    """
    try:
        # Sign in with Supabase
        response = supabase.auth.sign_in_with_password({
            "email": request.email,
            "password": request.password
        })
        
        if not response.user or not response.session:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid credentials"
            )
        
        # Check if email is verified
        if not response.user.email_confirmed_at:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Email not verified. Please check your email and verify your account before logging in."
            )
        
        user_data = UserData(
            id=response.user.id,
            email=response.user.email,
            email_confirmed_at=response.user.email_confirmed_at,
            created_at=response.user.created_at,
            updated_at=response.user.updated_at,
            user_metadata=response.user.user_metadata
        )
        
        session_data = SessionData(
            access_token=response.session.access_token,
            refresh_token=response.session.refresh_token,
            expires_in=response.session.expires_in,
            token_type=response.session.token_type or "bearer"
        )
        
        return LoginResponse(
            message="Login successful",
            user=user_data,
            session=session_data
        )
        
    except AuthApiError as e:
        logger.error(f"Login error: {str(e)}")
        # Don't expose detailed error messages to prevent user enumeration
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password"
        )
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Unexpected login error: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An unexpected error occurred during login"
        )


@router.post("/refresh", response_model=RefreshResponse)
async def refresh_session(
    request: RefreshRequest,
    supabase: Client = Depends(get_supabase)
):
    """
    Refresh a user session using a refresh token.
    
    - **refresh_token**: The refresh token from a previous session
    
    Returns a new access token and refresh token.
    """
    try:
        response = supabase.auth.refresh_session(request.refresh_token)
        
        if not response.session:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid or expired refresh token"
            )
            
        session_data = SessionData(
            access_token=response.session.access_token,
            refresh_token=response.session.refresh_token,
            expires_in=response.session.expires_in,
            token_type=response.session.token_type or "bearer"
        )
        
        return RefreshResponse(
            message="Session refreshed successfully",
            session=session_data
        )
        
    except AuthApiError as e:
        logger.error(f"Refresh error: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired refresh token"
        )
    except Exception as e:
        logger.error(f"Unexpected refresh error: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An unexpected error occurred during session refresh"
        )


@router.post("/logout", response_model=LogoutResponse)
async def logout(
    current_user = Depends(get_current_user),
    token: str = Depends(get_current_user_token),
    supabase: Client = Depends(get_supabase)
):
    """
    Terminate the current user session.
    
    Requires a valid authentication token in the Authorization header.
    """
    try:
        # Sign out the user
        supabase.auth.sign_out()
        
        return LogoutResponse(message="Logout successful")
        
    except Exception as e:
        logger.error(f"Logout error: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred during logout"
        )


@router.get("/user", response_model=UserResponse)
async def get_user(
    current_user = Depends(get_current_user)
):
    """
    Get the currently authenticated user's information.
    
    Requires a valid authentication token in the Authorization header.
    """
    try:
        user_data = UserData(
            id=current_user.id,
            email=current_user.email,
            email_confirmed_at=current_user.email_confirmed_at,
            created_at=current_user.created_at,
            updated_at=current_user.updated_at,
            user_metadata=current_user.user_metadata
        )
        
        return UserResponse(user=user_data)
        
    except Exception as e:
        logger.error(f"Get user error: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while retrieving user information"
        )


@router.post("/password/reset/request", response_model=PasswordResetResponse)
async def request_password_reset(
    request: PasswordResetRequest,
    supabase: Client = Depends(get_supabase)
):
    """
    Initiate a password reset flow.
    
    - **email**: Email address to send reset link to
    
    Always returns success to prevent user enumeration.
    If the email exists, a reset link will be sent.
    """
    try:
        # Request password reset from Supabase
        supabase.auth.reset_password_email(request.email)
        
        # Always return success to prevent user enumeration
        return PasswordResetResponse(
            message="If the email exists, a password reset link has been sent."
        )
        
    except Exception as e:
        logger.error(f"Password reset request error: {str(e)}")
        # Still return success to prevent user enumeration
        return PasswordResetResponse(
            message="If the email exists, a password reset link has been sent."
        )


@router.post("/password/reset/confirm", response_model=PasswordResetConfirmResponse)
async def confirm_password_reset(
    request: PasswordResetConfirm,
    supabase: Client = Depends(get_supabase)
):
    """
    Complete the password reset process.
    
    - **access_token**: Reset token from the email link
    - **new_password**: New password (minimum 6 characters)
    
    Sets the new password and confirms the reset.
    """
    try:
        # Update password using the reset token
        response = supabase.auth.update_user({
            "password": request.new_password
        })
        
        if not response.user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid or expired reset token"
            )
        
        return PasswordResetConfirmResponse(
            message="Password reset successful. You can now log in with your new password."
        )
        
    except AuthApiError as e:
        logger.error(f"Password reset confirmation error: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid or expired reset token"
        )
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Unexpected password reset error: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An unexpected error occurred during password reset"
        )


@router.delete("/user", response_model=DeleteUserResponse)
async def delete_user(
    current_user = Depends(get_current_user),
    token: str = Depends(get_current_user_token),
    supabase: Client = Depends(get_supabase)
):
    """
    Delete the authenticated user's account.
    
    Requires a valid authentication token in the Authorization header.
    This action is permanent and cannot be undone.
    """
    try:
        # Delete the user from Supabase Auth
        # Note: Supabase Python SDK doesn't have a direct delete user method for client-side
        # This requires admin privileges and should be done via Management API or Database trigger
        # For now, we'll raise an error suggesting to implement via admin endpoint
        
        raise HTTPException(
            status_code=status.HTTP_501_NOT_IMPLEMENTED,
            detail="User deletion must be implemented via admin endpoint or database trigger. "
                   "Contact support to delete your account."
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"User deletion error: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while deleting the user account"
        )
