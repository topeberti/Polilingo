"""
Learning path management router for fetching and managing lessons and sessions.
"""

from fastapi import APIRouter, Depends, HTTPException, status, Query, Security
from fastapi.security import HTTPAuthorizationCredentials
from supabase import Client
from typing import List
import logging

from config import get_supabase
from models import (
    Lesson, LessonListResponse, LessonQueryResponse,
    Session, SessionListResponse, SessionQueryResponse
)
from middleware import get_current_user, security

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/learning-path", tags=["Learning Path"])

@router.get("/lessons/fetch", response_model=LessonListResponse)
async def fetch_lessons(
    ids: str = Query(..., description="Comma-separated list of lesson IDs"),
    current_user = Depends(get_current_user),
    supabase: Client = Depends(get_supabase),
    credentials: HTTPAuthorizationCredentials = Security(security)
):
    """
    Fetch multiple lessons by their IDs.
    
    Requires authentication.
    
    - **ids**: Comma-separated list of UUIDs
    """
    try:
        lesson_ids = [id.strip() for id in ids.split(',') if id.strip()]
        
        if not lesson_ids:
            return LessonListResponse(lessons=[])

        token = credentials.credentials
        response = supabase.postgrest.auth(token).from_("lessons").select("*").in_("id", lesson_ids).execute()
        
        return LessonListResponse(lessons=response.data)

    except Exception as e:
        logger.error(f"Error fetching lessons: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, 
            detail="Failed to fetch lessons"
        )


@router.get("/sessions/fetch", response_model=SessionListResponse)
async def fetch_sessions(
    ids: str = Query(..., description="Comma-separated list of session IDs"),
    current_user = Depends(get_current_user),
    supabase: Client = Depends(get_supabase),
    credentials: HTTPAuthorizationCredentials = Security(security)
):
    """
    Fetch multiple sessions by their IDs.
    
    Requires authentication.
    
    - **ids**: Comma-separated list of UUIDs
    """
    try:
        session_ids = [id.strip() for id in ids.split(',') if id.strip()]
        
        if not session_ids:
            return SessionListResponse(sessions=[])

        token = credentials.credentials
        response = supabase.postgrest.auth(token).from_("sessions").select("*").in_("id", session_ids).execute()
        
        return SessionListResponse(sessions=response.data)

    except Exception as e:
        logger.error(f"Error fetching sessions: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, 
            detail="Failed to fetch sessions"
        )



@router.get("/lessons/query", response_model=LessonQueryResponse)
async def query_lessons(
    name_text: str = Query(None, description="The text to search for in the name."),
    name_exact: bool = Query(False, description="Indicates if the name must be exactly the same as the one asked for."),
    order_number: int = Query(None, description="The order to search for."),
    order_greater: bool = Query(False, description="Indicates if the order must be greater than the one asked for."),
    order_less: bool = Query(False, description="Indicates if the order must be less than the one asked for."),
    xp_reward_number: int = Query(None, description="The xp_reward to search for."),
    xp_reward_greater: bool = Query(False, description="Indicates if the xp_reward must be greater than the one asked for."),
    xp_reward_less: bool = Query(False, description="Indicates if the xp_reward must be less than the one asked for."),
    current_user = Depends(get_current_user),
    supabase: Client = Depends(get_supabase),
    credentials: HTTPAuthorizationCredentials = Security(security)
):
    """
    Query lessons based on criteria.
    Returns a list of lesson IDs.
    """
    try:
        token = credentials.credentials
        # Select id, order, name, xp_reward to facilitate python-side filtering
        query = supabase.postgrest.auth(token).from_("lessons").select("id, order, name, xp_reward")
        
        # Always filter for active lessons
        query = query.eq("status", "active")
        
        response = query.execute()
        data = response.data

        # Python-side filtering due to PostgREST keywords and partial matches
        filtered_data = []
        for item in data:
            match = True
            
            # Name filter
            if name_text:
                val = item.get('name') or ""
                if name_exact:
                    if val != name_text:
                        match = False
                else:
                    if name_text.lower() not in val.lower():
                        match = False
            
            if not match:
                continue

            # Order filter
            if order_number is not None:
                order_val = item.get('order')
                if order_val is None:
                    match = False
                elif order_greater:
                    if not (order_val > order_number):
                        match = False
                elif order_less:
                    if not (order_val < order_number):
                        match = False
                else:
                    if not (order_val == order_number):
                        match = False
            
            if not match:
                continue

            # XP Reward filter
            if xp_reward_number is not None:
                xp_val = item.get('xp_reward')
                if xp_val is None:
                    match = False
                elif xp_reward_greater:
                    if not (xp_val > xp_reward_number):
                        match = False
                elif xp_reward_less:
                    if not (xp_val < xp_reward_number):
                        match = False
                else:
                    if not (xp_val == xp_reward_number):
                        match = False
            
            if match:
                filtered_data.append(item)
        
        ids = [item['id'] for item in filtered_data]
        return LessonQueryResponse(ids=ids)

    except Exception as e:
        logger.error(f"Error querying lessons: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, 
            detail="Failed to query lessons"
        )


@router.get("/sessions/query", response_model=SessionQueryResponse)
async def query_sessions(
    lesson_ids: str = Query(None, description="The list of lesson ids separated by commas."),
    name_text: str = Query(None, description="The text to search for in the name."),
    name_exact: bool = Query(False, description="Indicates if the name must be exactly the same as the one asked for."),
    order_number: int = Query(None, description="The order to search for."),
    order_greater: bool = Query(False, description="Indicates if the order must be greater than the one asked for."),
    order_less: bool = Query(False, description="Indicates if the order must be less than the one asked for."),
    number_of_questions_number: int = Query(None, description="The number of questions to search for."),
    number_of_questions_greater: bool = Query(False, description="Indicates if the number of questions must be greater than the one asked for."),
    number_of_questions_less: bool = Query(False, description="Indicates if the number of questions must be less than the one asked for."),
    question_selection_strategy: str = Query(None, description="The question selection strategy to search for."),
    concept_ids: str = Query(None, description="The list of concept ids separated by commas."),
    heading_ids: str = Query(None, description="The list of heading ids separated by commas."),
    topic_ids: str = Query(None, description="The list of topic ids separated by commas."),
    block_ids: str = Query(None, description="The list of block ids separated by commas."),
    minimum_difficulty_number: int = Query(None, description="The minimum difficulty to search for."),
    maximum_difficulty_number: int = Query(None, description="The maximum difficulty to search for."),
    current_user = Depends(get_current_user),
    supabase: Client = Depends(get_supabase),
    credentials: HTTPAuthorizationCredentials = Security(security)
):
    """
    Query sessions based on criteria.
    Returns a list of session IDs.
    """
    try:
        token = credentials.credentials
        # Select id, order, name, number_of_questions to facilitate python-side filtering
        # Also need to select columns if we want to filter them in Python, but for IDs we can filter in SQL if columns exist
        # We will try filtering IDs in SQL
        query = supabase.postgrest.auth(token).from_("sessions").select("id, order, name, number_of_questions")
        
        # ID list filters
        import uuid
        
        # Helper to filter by list of IDs
        def filter_by_ids(q, col_name, ids_str):
            if ids_str:
                valid_ids = []
                for id_str in ids_str.split(','):
                    id_clean = id_str.strip()
                    if id_clean:
                        try:
                            uuid.UUID(id_clean)
                            valid_ids.append(id_clean)
                        except ValueError:
                            pass
                if valid_ids:
                    return q.in_(col_name, valid_ids)
                elif ids_str.strip():
                     # Provided but invalid -> return empty result implicitly (by adding impossible condition or handling later)
                     # Supabase-py doesn't have an easy "empty" query modifier other than invalid filter.
                     # We'll return None to signal empty result
                     return None
            return q

        # Apply ID filters
        for col, val in [
            ("lesson_id", lesson_ids),
            ("concept_id", concept_ids),
            ("heading_id", heading_ids),
            ("topic_id", topic_ids),
            ("block_id", block_ids)
        ]:
            if val:
                query = filter_by_ids(query, col, val)
                if query is None:
                    return SessionQueryResponse(ids=[])

        # Difficulty range filters
        if minimum_difficulty_number is not None:
            query = query.gte("difficulty_range", minimum_difficulty_number)
        
        if maximum_difficulty_number is not None:
            query = query.lte("difficulty_range", maximum_difficulty_number)
            
        # Strategy filter
        if question_selection_strategy:
            query = query.eq("question_selection_strategy", question_selection_strategy)

        response = query.execute()
        data = response.data

        # Python-side filtering based on name, order, number_of_questions
        filtered_data = []
        for item in data:
            match = True
            
            # Name filter
            if name_text:
                val = item.get('name') or ""
                if name_exact:
                    if val != name_text:
                        match = False
                else:
                    if name_text.lower() not in val.lower():
                        match = False
            
            if not match:
                continue

            # Order filter
            if order_number is not None:
                order_val = item.get('order')
                if order_val is None:
                    match = False
                elif order_greater:
                    if not (order_val > order_number):
                        match = False
                elif order_less:
                    if not (order_val < order_number):
                        match = False
                else:
                    if not (order_val == order_number):
                        match = False
            
            if not match:
                continue

            # Number of questions filter
            if number_of_questions_number is not None:
                nq_val = item.get('number_of_questions')
                if nq_val is None:
                    match = False
                elif number_of_questions_greater:
                    if not (nq_val > number_of_questions_number):
                        match = False
                elif number_of_questions_less:
                    if not (nq_val < number_of_questions_number):
                        match = False
                else:
                    if not (nq_val == number_of_questions_number):
                        match = False
            
            if match:
                filtered_data.append(item)
        
        ids = [item['id'] for item in filtered_data]
        return SessionQueryResponse(ids=ids)

    except Exception as e:
        logger.error(f"Error querying sessions: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, 
            detail="Failed to query sessions"
        )
