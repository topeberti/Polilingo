"""
Pydantic models for request/response validation in the authentication API.
"""

from typing import Optional, Dict, Any, List

from pydantic import BaseModel, EmailStr, Field, field_validator
from datetime import datetime, time as Time


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


class DeleteUserResponse(BaseModel):
    """Response model for user deletion."""
    message: str = "User profile deleted successfully"


# Syllabus Models

class Block(BaseModel):
    """Model for a Syllabus Block."""
    id: str
    name: str
    parent_id: Optional[str] = None
    description: Optional[str] = None
    order: int
    status: str  # e.g., 'active', 'draft', 'archived'

class BlockListResponse(BaseModel):
    """Response model for a list of blocks."""
    blocks: List[Block]


class BlockQueryResponse(BaseModel):
    """Response model for block query."""
    ids: List[str]


class Topic(BaseModel):
    """Model for a Syllabus Topic."""
    id: str
    name: str
    block_id: Optional[str] = None
    description: Optional[str] = None
    order: int
    status: str

class TopicListResponse(BaseModel):
    """Response model for a list of topics."""
    topics: List[Topic]


class TopicQueryResponse(BaseModel):
    """Response model for topic query."""
    ids: List[str]


class Heading(BaseModel):
    """Model for a Syllabus Heading."""
    id: str
    name: str
    topic_id: Optional[str] = None
    description: Optional[str] = None
    order: int
    status: str

class HeadingListResponse(BaseModel):
    """Response model for a list of headings."""
    headings: List[Heading]


class HeadingQueryResponse(BaseModel):
    """Response model for heading query."""
    ids: List[str]


class Concept(BaseModel):
    """Model for a Syllabus Concept."""
    id: str
    name: str
    heading_id: Optional[str] = None
    description: Optional[str] = None
    order: int
    status: str

class ConceptListResponse(BaseModel):
    """Response model for a list of concepts."""
    concepts: List[Concept]


class ConceptQueryResponse(BaseModel):
    """Response model for concept query."""
    ids: List[str]


class Question(BaseModel):
    """Model for a Syllabus Question."""
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

class QuestionListResponse(BaseModel):
    """Response model for a list of questions."""
    questions: List[Question]


# Learning Path Models

class Lesson(BaseModel):
    """Model for a Learning Path Lesson."""
    id: str
    name: str
    order: int
    xp_reward: int
    status: str

class LessonListResponse(BaseModel):
    """Response model for a list of lessons."""
    lessons: List[Lesson]


class LessonQueryResponse(BaseModel):
    """Response model for lesson query."""
    ids: List[str]


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

class SessionListResponse(BaseModel):
    """Response model for a list of sessions."""
    sessions: List[Session]


class SessionQueryResponse(BaseModel):
    """Response model for session query."""
    ids: List[str]


class QuestionQueryResponse(BaseModel):
    """Response model for question query."""
    ids: List[str]


# History Models

class AnsweredQuestionStats(BaseModel):
    """Model for a single answered question statistics."""
    question_id: str
    total_attempts: int
    correct_answers: int


class AnsweredQuestionsHistoryResponse(BaseModel):
    """Response model for a list of answered questions statistics."""
    answered_questions: List[AnsweredQuestionStats]


class PassedSession(BaseModel):
    """Model for a single passed session."""
    session_id: str


class PassedSessionsResponse(BaseModel):
    """Response model for a list of passed sessions."""
    sessions: List[PassedSession]


class PassedLesson(BaseModel):
    """Model for a single passed lesson."""
    lesson_id: str


class PassedLessonsResponse(BaseModel):
    """Response model for a list of passed lessons."""
    lessons: List[PassedLesson]


class NextLessonResponse(BaseModel):
    """Response model for the next lesson ID."""
    lesson_id: Optional[str] = None


class NextSessionResponse(BaseModel):
    """Response model for the next session ID."""
    session_id: Optional[str] = None

