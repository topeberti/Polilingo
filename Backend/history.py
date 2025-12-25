"""
History management router for fetching user activity history.
"""

from fastapi import APIRouter, Depends, HTTPException, status, Security, Query
from fastapi.security import HTTPAuthorizationCredentials
from supabase import Client
from typing import List, Dict, Optional
import logging
from collections import defaultdict

from config import get_supabase
from models import (
    Lesson, Session,
    AnsweredQuestionStats, AnsweredQuestionsHistoryResponse,
    PassedSession, PassedSessionsResponse, PassedLesson, PassedLessonsResponse,
    NextLessonResponse, NextSessionResponse, AvailableSessionsResponse
)
from middleware import get_current_user, security

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/history", tags=["History"])

@router.get("/questions/answered", response_model=AnsweredQuestionsHistoryResponse)
async def get_answered_questions(
    user_id: Optional[str] = Query(None, description="The id of the user. If not provided, the logged in user id will be used."),
    current_user = Depends(get_current_user),
    supabase: Client = Depends(get_supabase),
    credentials: HTTPAuthorizationCredentials = Security(security)
):
    """
    Returns a list of questions that the user has answered,
    including total attempts and correct answer counts.
    """
    try:
        target_user_id = user_id or current_user.id
        
        # Validate UUID format
        import uuid
        try:
            uuid.UUID(str(target_user_id))
        except ValueError:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Invalid user_id format: {target_user_id}. Must be a valid UUID."
            )

        token = credentials.credentials
        
        # Call the optimized RPC for server-side aggregation with authentication
        response = supabase.postgrest.auth(token).rpc("get_answered_questions_stats", {"p_user_id": str(target_user_id)}).execute()
        
        data = response.data
        
        if not data:
            return AnsweredQuestionsHistoryResponse(answered_questions=[])
            
        # Get unique question IDs to fetch their details
        question_ids = list(set(record["question_id"] for record in data))
        
        # Fetch question details from the questions table
        questions_response = supabase.postgrest.auth(token).from_("questions").select("*").in_("id", question_ids).execute()
        questions_map = {q["id"]: q for q in questions_response.data}
        
        # Format response by combining RPC stats with question details
        answered_questions = []
        for record in data:
            qid = record["question_id"]
            if qid in questions_map:
                # Combine full question data with stats
                combined_data = {**questions_map[qid], **record}
                answered_questions.append(AnsweredQuestionStats(**combined_data))
        
        return AnsweredQuestionsHistoryResponse(answered_questions=answered_questions)

    except HTTPException:
        # Re-raise HTTPExceptions (e.g., from validation) to let FastAPI handle them
        raise
    except Exception as e:
        logger.error(f"Error fetching answered questions history: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to fetch answered questions history"
        )


@router.get("/sessions/passed", response_model=PassedSessionsResponse)
async def get_passed_sessions(
    user_id: Optional[str] = Query(None, description="The id of the user. If not provided, the logged in user id will be used."),
    current_user = Depends(get_current_user),
    supabase: Client = Depends(get_supabase),
    credentials: HTTPAuthorizationCredentials = Security(security)
):
    """
    Returns a list of sessions that the user has completed/passed.
    """
    try:
        target_user_id = user_id or current_user.id
        
        # Validate UUID format
        import uuid
        try:
            uuid.UUID(str(target_user_id))
        except ValueError:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Invalid user_id format: {target_user_id}. Must be a valid UUID."
            )

        token = credentials.credentials
        
        # Query user_session_history for passed sessions
        response = supabase.postgrest.auth(token).from_("user_session_history") \
            .select("session_id") \
            .eq("user_id", str(target_user_id)) \
            .eq("passed", True) \
            .execute()
        
        data = response.data
        
        if not data:
            return PassedSessionsResponse(sessions=[])
            
        # Extract unique session IDs
        unique_sessions = {item['session_id'] for item in data}
        
        # Fetch session details from the sessions table
        sessions_response = supabase.postgrest.auth(token).from_("sessions") \
            .select("*") \
            .in_("id", list(unique_sessions)) \
            .execute()
        
        sessions = [
            PassedSession(**item)
            for item in sessions_response.data
        ]
        
        return PassedSessionsResponse(sessions=sessions)

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error fetching passed sessions history: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to fetch passed sessions history"
        )


@router.get("/lessons/passed", response_model=PassedLessonsResponse)
async def get_passed_lessons(
    user_id: Optional[str] = Query(None, description="The id of the user. If not provided, the logged in user id will be used."),
    current_user = Depends(get_current_user),
    supabase: Client = Depends(get_supabase),
    credentials: HTTPAuthorizationCredentials = Security(security)
):
    """
    Returns a list of lessons that the user has completed/passed.
    """
    try:
        target_user_id = user_id or current_user.id
        
        # Validate UUID format
        import uuid
        try:
            uuid.UUID(str(target_user_id))
        except ValueError:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Invalid user_id format: {target_user_id}. Must be a valid UUID."
            )

        token = credentials.credentials
        
        # Query user_lessons_history for passed lessons
        response = supabase.postgrest.auth(token).from_("user_lessons_history") \
            .select("lesson_id") \
            .eq("user_id", str(target_user_id)) \
            .eq("passed", True) \
            .execute()
        
        data = response.data
        
        if not data:
            return PassedLessonsResponse(lessons=[])
            
        # Extract unique lesson IDs
        unique_lessons = {item['lesson_id'] for item in data}
        
        # Fetch lesson details from the lessons table
        lessons_response = supabase.postgrest.auth(token).from_("lessons") \
            .select("*") \
            .in_("id", list(unique_lessons)) \
            .execute()
        
        lessons = [
            PassedLesson(**item)
            for item in lessons_response.data
        ]
        
        return PassedLessonsResponse(lessons=lessons)

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error fetching passed lessons history: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to fetch passed lessons history"
        )


@router.get("/sessions/next", response_model=NextSessionResponse)
async def get_next_session(
    user_id: Optional[str] = Query(None, description="The id of the user. If not provided, the logged in user id will be used."),
    current_user = Depends(get_current_user),
    supabase: Client = Depends(get_supabase),
    credentials: HTTPAuthorizationCredentials = Security(security)
):
    """
    Returns the next session ID that the user has to complete.
    """
    try:
        target_user_id = user_id or current_user.id
        
        # Validate UUID format
        import uuid
        try:
            uuid.UUID(str(target_user_id))
        except ValueError:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Invalid user_id format: {target_user_id}. Must be a valid UUID."
            )

        token = credentials.credentials
        
        # 1. Get IDs of sessions the user has passed
        history_response = supabase.postgrest.auth(token).from_("user_session_history") \
            .select("session_id") \
            .eq("user_id", str(target_user_id)) \
            .eq("passed", True) \
            .execute()
        
        passed_data = history_response.data
        
        if not passed_data:
            # User hasn't passed any sessions, return the first session (lowest order globally)
            # Note: This globally finds the first session.
            session_response = supabase.postgrest.auth(token).from_("sessions") \
                .select("*") \
                .order('"order"', desc=False) \
                .limit(1) \
                .execute()
            
            if session_response.data:
                return NextSessionResponse(session=Session(**session_response.data[0]))
            return NextSessionResponse(session=None)

        # 2. Get the highest order among passed sessions
        passed_ids = [item['session_id'] for item in passed_data]
        
        # Query sessions table to get orders for these IDs
        sessions_info_response = supabase.postgrest.auth(token).from_("sessions") \
            .select('"order"') \
            .in_("id", passed_ids) \
            .execute()
        
        if not sessions_info_response.data:
             # Fallback
             session_response = supabase.postgrest.auth(token).from_("sessions") \
                .select("*") \
                .order('"order"', desc=False) \
                .limit(1) \
                .execute()
             
             if session_response.data:
                 return NextSessionResponse(session=Session(**session_response.data[0]))
             return NextSessionResponse(session=None)

        max_passed_order = max(item['order'] for item in sessions_info_response.data)

        # 3. Find the next session with order > max_passed_order
        next_session_response = supabase.postgrest.auth(token).from_("sessions") \
            .select("*") \
            .gt('"order"', max_passed_order) \
            .order('"order"', desc=False) \
            .limit(1) \
            .execute()
        
        if next_session_response.data:
            return NextSessionResponse(session=Session(**next_session_response.data[0]))
        
        # All sessions completed
        return NextSessionResponse(session=None)

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error fetching next session: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to fetch next session"
        )


@router.get("/lessons/next", response_model=NextLessonResponse)
async def get_next_lesson(
    user_id: Optional[str] = Query(None, description="The id of the user. If not provided, the logged in user id will be used."),
    current_user = Depends(get_current_user),
    supabase: Client = Depends(get_supabase),
    credentials: HTTPAuthorizationCredentials = Security(security)
):
    """
    Returns the next lesson ID that the user has to complete.
    """
    try:
        target_user_id = user_id or current_user.id
        
        # Validate UUID format
        import uuid
        try:
            uuid.UUID(str(target_user_id))
        except ValueError:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Invalid user_id format: {target_user_id}. Must be a valid UUID."
            )

        token = credentials.credentials
        
        # 1. Get IDs of lessons the user has passed
        history_response = supabase.postgrest.auth(token).from_("user_lessons_history") \
            .select("lesson_id") \
            .eq("user_id", str(target_user_id)) \
            .eq("passed", True) \
            .execute()
        
        passed_data = history_response.data
        
        if not passed_data:
            # User hasn't passed any lessons, return the first active lesson
            lesson_response = supabase.postgrest.auth(token).from_("lessons") \
                .select("*") \
                .eq("status", "active") \
                .order('"order"', desc=False) \
                .limit(1) \
                .execute()
            
            if lesson_response.data:
                return NextLessonResponse(lesson=Lesson(**lesson_response.data[0]))
            return NextLessonResponse(lesson=None)

        # 2. Get the highest order among passed lessons
        passed_ids = [item['lesson_id'] for item in passed_data]
        
        # Query lessons table to get orders for these IDs
        lessons_info_response = supabase.postgrest.auth(token).from_("lessons") \
            .select('"order"') \
            .in_("id", passed_ids) \
            .execute()
        
        if not lessons_info_response.data:
             # This shouldn't happen if database integrity is maintained
             # But as a fallback, return the first lesson
             lesson_response = supabase.postgrest.auth(token).from_("lessons") \
                .select("*") \
                .eq("status", "active") \
                .order('"order"', desc=False) \
                .limit(1) \
                .execute()
             
             if lesson_response.data:
                 return NextLessonResponse(lesson=Lesson(**lesson_response.data[0]))
             return NextLessonResponse(lesson=None)

        max_passed_order = max(item['order'] for item in lessons_info_response.data)

        # 3. Find the next lesson with order > max_passed_order
        next_lesson_response = supabase.postgrest.auth(token).from_("lessons") \
            .select("*") \
            .eq("status", "active") \
            .gt('"order"', max_passed_order) \
            .order('"order"', desc=False) \
            .limit(1) \
            .execute()
        
        if next_lesson_response.data:
            return NextLessonResponse(lesson=Lesson(**next_lesson_response.data[0]))
        
        # All lessons completed
        return NextLessonResponse(lesson=None)

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error fetching next lesson: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to fetch next lesson"
        )


@router.get("/sessions/available", response_model=AvailableSessionsResponse)
async def get_available_sessions(
    user_id: Optional[str] = Query(None, description="The id of the user. If not provided, the logged in user id will be used."),
    current_user = Depends(get_current_user),
    supabase: Client = Depends(get_supabase),
    credentials: HTTPAuthorizationCredentials = Security(security)
):
    """
    Returns an ordered list of sessions that the user can complete, including full session and lesson data.
    Available sessions = passed sessions + next session.
    """
    try:
        target_user_id = user_id or current_user.id
        token = credentials.credentials
        
        # 1. Get IDs of sessions the user has passed
        history_response = supabase.postgrest.auth(token).from_("user_session_history") \
            .select("session_id") \
            .eq("user_id", str(target_user_id)) \
            .eq("passed", True) \
            .execute()
        
        passed_ids = [item['session_id'] for item in history_response.data] if history_response.data else []
        
        # 2. Find the next session (same logic as get_next_session)
        next_session_id = None
        if not passed_ids:
            # Get the first session globally
            first_session_response = supabase.postgrest.auth(token).from_("sessions") \
                .select("id") \
                .order('"order"', desc=False) \
                .limit(1) \
                .execute()
            if first_session_response.data:
                next_session_id = first_session_response.data[0]['id']
        else:
            # Get order of passed sessions
            sessions_info_response = supabase.postgrest.auth(token).from_("sessions") \
                .select('"order"') \
                .in_("id", passed_ids) \
                .execute()
            
            if sessions_info_response.data:
                max_passed_order = max(item['order'] for item in sessions_info_response.data)
                
                # Find the next session
                next_session_response = supabase.postgrest.auth(token).from_("sessions") \
                    .select("id") \
                    .gt('"order"', max_passed_order) \
                    .order('"order"', desc=False) \
                    .limit(1) \
                    .execute()
                if next_session_response.data:
                    next_session_id = next_session_response.data[0]['id']

        # 3. Combine IDs
        available_ids = passed_ids
        if next_session_id and next_session_id not in available_ids:
            available_ids.append(next_session_id)
            
        if not available_ids:
            return AvailableSessionsResponse(sessions=[], lessons=[])
            
        # 4. Fetch full session data
        sessions_response = supabase.postgrest.auth(token).from_("sessions") \
            .select("*") \
            .in_("id", available_ids) \
            .execute()
        
        sessions_data = sessions_response.data
        lesson_ids = list(set(s['lesson_id'] for s in sessions_data))
        
        # 5. Fetch full lesson data
        lessons_response = supabase.postgrest.auth(token).from_("lessons") \
            .select("*") \
            .in_("id", lesson_ids) \
            .execute()
        
        lessons_data = lessons_response.data
        
        # Create lookup maps for sorting
        lessons_map = {l['id']: l for l in lessons_data}
        
        # 6. Sort sessions by lesson order then session order
        def sort_key(s):
            lesson_order = lessons_map.get(s['lesson_id'], {}).get('order', 999999)
            return (lesson_order, s['order'])
            
        sessions_data.sort(key=sort_key)
        
        # Sort lessons by order
        lessons_data.sort(key=lambda x: x['order'])
        
        return AvailableSessionsResponse(
            sessions=[Session(**s) for s in sessions_data],
            lessons=[Lesson(**l) for l in lessons_data]
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error fetching available sessions: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to fetch available sessions"
        )

