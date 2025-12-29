"""
Pydantic models for request/response validation in the authentication API.
"""

from typing import Optional, Dict, Any, List
from pydantic import BaseModel, EmailStr, Field
from datetime import datetime, date, time as Time


# Request Models

class SignupRequest(BaseModel):
    """Request model for user signup."""
    email: EmailStr = Field(..., description="User's email address")
    password: str = Field(..., min_length=6, description="User's password (min 6 characters)")
    metadata: Optional[Dict[str, Any]] = Field(None, description="Optional user metadata")


class LoginRequest(BaseModel):
    """Request model for user login."""
    email: EmailStr = Field(..., description="User's email address")
    password: str = Field(..., description="User's password")


class PasswordResetRequest(BaseModel):
    """Request model for password reset initiation."""
    email: EmailStr = Field(..., description="Email address to send reset link to")


class PasswordResetConfirm(BaseModel):
    """Request model for password reset confirmation."""
    access_token: str = Field(..., description="Reset token from email link")
    new_password: str = Field(..., min_length=6, description="New password (min 6 characters)")


class RefreshRequest(BaseModel):
    """Request model for session refresh."""
    refresh_token: str = Field(..., description="The refresh token provided by Supabase")


# Response Models

class UserData(BaseModel):
    """User data model."""
    id: str
    email: str
    email_confirmed_at: Optional[datetime] = None
    created_at: datetime
    updated_at: datetime
    user_metadata: Optional[Dict[str, Any]] = None


class SessionData(BaseModel):
    """Session data model."""
    access_token: str
    refresh_token: str
    expires_in: int
    token_type: str = "bearer"


class SignupResponse(BaseModel):
    """Response model for successful signup."""
    message: str = "Signup successful. Please check your email to verify your account."
    user: Optional[UserData] = None


class LoginResponse(BaseModel):
    """Response model for successful login."""
    message: str = "Login successful"
    user: UserData
    session: SessionData


class LogoutResponse(BaseModel):
    """Response model for successful logout."""
    message: str = "Logout successful"


class UserResponse(BaseModel):
    """Response model for user data retrieval."""
    user: UserData


class PasswordResetResponse(BaseModel):
    """Response model for password reset request."""
    message: str = "If the email exists, a password reset link has been sent."


class PasswordResetConfirmResponse(BaseModel):
    """Response model for password reset confirmation."""
    message: str = "Password reset successful. You can now log in with your new password."


class RefreshResponse(BaseModel):
    """Response model for session refresh."""
    message: str = "Session refreshed successfully"
    session: SessionData


class DeleteUserResponse(BaseModel):
    """Response model for user deletion."""
    message: str = "User account deleted successfully"


class ErrorResponse(BaseModel):
    """Error response model."""
    error: str
    detail: Optional[str] = None
    code: Optional[str] = None


# User Management Models

class CreateUserRequest(BaseModel):
    """Request model for creating a user profile."""
    username: str = Field(..., min_length=3, max_length=20, description="Unique username")
    full_name: str = Field(..., min_length=1, description="User's full name")
    profile_picture_url: Optional[str] = Field(None, description="URL to profile picture")
    preferred_study_time: Optional[Time] = Field(None, description="Preferred study time (HH:MM)")
    daily_goal: Optional[int] = Field(None, ge=1, description="Daily XP goal")
    notification_preferences: Optional[Dict[str, bool]] = Field(None, description="Notification preferences")


class UserProfileData(BaseModel):
    """User profile data model."""
    id: str
    username: str
    email: str
    full_name: Optional[str] = None
    profile_picture_url: Optional[str] = None
    date_joined: datetime
    last_active: datetime
    preferred_study_time: Optional[Time] = None
    daily_goal: int
    notification_preferences: Optional[Dict[str, bool]] = None
    account_status: str
    role: str


class UserGamificationStats(BaseModel):
    """User gamification statistics model."""
    total_xp: int
    current_level: int
    xp_to_next_level: int
    current_streak: int
    longest_streak: int
    last_streak_date: Optional[date] = None


class UserProfilePublic(BaseModel):
    """Public user profile data strict model for /profile endpoint."""
    username: str
    email: str
    full_name: str
    profile_picture_url: Optional[str] = None
    preferred_study_time: Optional[Time] = None
    daily_goal: int


class UserProfileResponse(BaseModel):
    """Response model for getting the full user profile."""
    user: UserProfilePublic
    user_gamification_stats: Optional[UserGamificationStats] = None



class CreateUserResponse(BaseModel):
    """Response model for user creation."""
    message: str = "User profile created successfully"
    user: UserProfileData


class UpdateUserRequest(BaseModel):
    """Request model for updating a user profile."""
    full_name: Optional[str] = Field(None, min_length=1, description="User's full name")
    profile_picture_url: Optional[str] = Field(None, description="URL to profile picture")
    preferred_study_time: Optional[Time] = Field(None, description="Preferred study time (HH:MM)")
    daily_goal: Optional[int] = Field(None, ge=1, description="Daily XP goal")
    notification_preferences: Optional[Dict[str, bool]] = Field(None, description="Notification preferences")


class UpdateUserResponse(BaseModel):
    """Response model for user update."""
    message: str = "User profile updated successfully"
    user: UserProfileData


# Question models

class Question(BaseModel):
    """Model for a question."""
    id: str
    concept_id: str
    text: str
    option_a: str
    option_b: str
    option_c: str
    correct_option: str
    explanation: Optional[str] = None
    difficulty: int
    source: Optional[str] = None


# Learning Path Models

class Lesson(BaseModel):
    """Model for a Learning Path Lesson."""
    id: str
    name: str
    order: int
    xp_reward: int
    status: str


class Session(BaseModel):
    """Model for a Learning Path Session."""
    id: str
    name: str
    lesson_id: str
    number_of_questions: int
    order: int
    question_selection_strategy: str
    concept_id: Optional[str] = None
    heading_id: Optional[str] = None
    topic_id: Optional[str] = None
    block_id: Optional[str] = None
    min_difficulty: Optional[int] = None
    max_difficulty: Optional[int] = None


# History Models

class AnsweredQuestionStats(Question):
    """Model for a single answered question statistics with full question data."""
    total_attempts: int
    correct_answers: int


class AnsweredQuestionsHistoryResponse(BaseModel):
    """Response model for a list of answered questions statistics."""
    answered_questions: List[AnsweredQuestionStats]


class PassedSession(Session):
    """Model for a single passed session with full session data."""
    pass


class PassedSessionsResponse(BaseModel):
    """Response model for a list of passed sessions."""
    sessions: List[PassedSession]


class PassedLesson(Lesson):
    """Model for a single passed lesson with full lesson data."""
    pass


class PassedLessonsResponse(BaseModel):
    """Response model for a list of passed lessons."""
    lessons: List[PassedLesson]


class NextLessonResponse(BaseModel):
    """Response model for the next lesson with full lesson data."""
    lesson: Optional[Lesson] = None


class NextSessionResponse(BaseModel):
    """Response model for the next session with full session data."""
    session: Optional[Session] = None


class AvailableSessionsResponse(BaseModel):
    """Response model for available sessions, including sessions and their lessons."""
    sessions: List[Session]
    lessons: List[Lesson]


# Learning Models

class LearningQuestion(BaseModel):
    """Model for a question in a learning session (limited fields for student view)."""
    id: str
    question: str
    a: str
    b: str
    c: str


class SessionQuestionsResponse(BaseModel):
    """Response model for questions in a learning session."""
    questions: List[LearningQuestion]


class StartSessionRequest(BaseModel):
    """Request model for starting a session."""
    session_id: str = Field(..., description="The id of the session")


class StartSessionResponse(BaseModel):
    """Response model for starting a session."""
    id: str = Field(..., description="The id of the created user session history row")
    status: str = Field("started", description="The status of the session")



class FinishSessionRequest(BaseModel):
    """Request model for finishing a session."""
    history_id: str = Field(..., description="The id of the user session history row")
    passed: bool = Field(..., description="Whether the session was passed or not")


class AnswerQuestionRequest(BaseModel):
    """Request model for answering a question."""
    question_id: str = Field(..., description="The id of the question")
    answer: str = Field(..., description="The answer (a, b, or c)")
    user_session_history_id: str = Field(..., description="The id of the user session history row")
    started_at: datetime = Field(..., description="The time when the question started")
    asked_for_explanation: bool = Field(..., description="Whether the user asked for an explanation")


class AnswerQuestionResponse(BaseModel):
    """Response model for answering a question."""
    correct: bool = Field(..., description="Whether the answer is correct or not")
    explanation: Optional[str] = Field(None, description="The explanation for the question")
    correct_answer: str = Field(..., description="The correct answer (a, b, or c)")
    xp_gained: int = Field(0, description="The amount of XP gained for this answer")

