"""
Syllabus management router for fetching and managing syllabus content.
"""

from fastapi import APIRouter, Depends, HTTPException, status, Query, Security
from fastapi.security import HTTPAuthorizationCredentials
from supabase import Client
from typing import List
import logging

from config import get_supabase
from models import (
    Block, BlockListResponse, BlockQueryResponse,
    Topic, TopicListResponse, TopicQueryResponse,
    Heading, HeadingListResponse, HeadingQueryResponse,
    Concept, ConceptListResponse, ConceptQueryResponse,
    Question, QuestionListResponse, QuestionQueryResponse
)

from middleware import get_current_user, security

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/syllabus", tags=["Syllabus"])

@router.get("/blocks/fetch", response_model=BlockListResponse)
async def fetch_blocks(
    ids: str = Query(..., description="Comma-separated list of block IDs"),
    current_user = Depends(get_current_user),
    supabase: Client = Depends(get_supabase),
    credentials: HTTPAuthorizationCredentials = Security(security)
):
    """
    Fetch multiple blocks by their IDs.
    
    Requires authentication.
    
    - **ids**: Comma-separated list of UUIDs
    """
    try:
        # Parse IDs
        block_ids = [id.strip() for id in ids.split(',') if id.strip()]
        
        if not block_ids:
            return BlockListResponse(blocks=[])

        # Fetch blocks from Supabase
        # 'in_' filter expects a list
        token = credentials.credentials
        response = supabase.postgrest.auth(token).from_("blocks").select("*").in_("id", block_ids).execute()
        
        # Check for errors in response (supabase-py usually raises exception on error, but good to be safe)
        blocks_data = response.data
        
        # Determine if any blocks were missing (optional: partial success is usually fine for bulk fetch, 
        # but if strict validation is needed, we could check len(blocks_data) == len(block_ids))
        
        return BlockListResponse(blocks=blocks_data)

    except Exception as e:
        logger.error(f"Error fetching blocks: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, 
            detail="Failed to fetch blocks"
        );


@router.get("/blocks/query", response_model=BlockQueryResponse)
async def query_blocks(
    name_text: str = Query(None, description="The text to search for in the name."),
    name_exact: bool = Query(False, description="Indicates if the name must be exactly the same as the one asked for."),
    description_text: str = Query(None, description="The text to search for in the description."),
    description_exact: bool = Query(False, description="Indicates if the description must be exactly the same as the one asked for."),
    order_number: int = Query(None, description="The order to search for."),
    order_greater: bool = Query(False, description="Indicates if the order must be greater than the one asked for."),
    order_less: bool = Query(False, description="Indicates if the order must be less than the one asked for."),
    current_user = Depends(get_current_user),
    supabase: Client = Depends(get_supabase),
    credentials: HTTPAuthorizationCredentials = Security(security)
):
    """
    Query blocks based on criteria.
    Returns a list of block IDs.
    """
    try:
        token = credentials.credentials
        # Select id, order, name, description to facilitate python-side filtering
        query = supabase.postgrest.auth(token).from_("blocks").select("id, order, name, description")
        
        # Always filter for active blocks
        query = query.eq("status", "active")
        
        response = query.execute()
        data = response.data

        # Python-side filtering for name, description and order
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

            # Description filter
            if description_text:
                val = item.get('description') or ""
                if description_exact:
                    if val != description_text:
                        match = False
                else:
                    if description_text.lower() not in val.lower():
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
            
            if match:
                filtered_data.append(item)
        
        ids = [item['id'] for item in filtered_data]
        return BlockQueryResponse(ids=ids)

    except Exception as e:
        logger.error(f"Error querying blocks: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, 
            detail="Failed to query blocks"
        )



@router.get("/topics/query", response_model=TopicQueryResponse)
async def query_topics(
    block_ids: str = Query(None, description="The list of block ids separated by commas."),
    name_text: str = Query(None, description="The text to search for in the name."),
    name_exact: bool = Query(False, description="Indicates if the name must be exactly the same as the one asked for."),
    description_text: str = Query(None, description="The text to search for in the description."),
    description_exact: bool = Query(False, description="Indicates if the description must be exactly the same as the one asked for."),
    order_number: int = Query(None, description="The order to search for."),
    order_greater: bool = Query(False, description="Indicates if the order must be greater than the one asked for."),
    order_less: bool = Query(False, description="Indicates if the order must be less than the one asked for."),
    current_user = Depends(get_current_user),
    supabase: Client = Depends(get_supabase),
    credentials: HTTPAuthorizationCredentials = Security(security)
):
    """
    Query topics based on criteria.
    Returns a list of topic IDs.
    """
    try:
        token = credentials.credentials
        # Select id, order, name, description to facilitate python-side filtering
        query = supabase.postgrest.auth(token).from_("topics").select("id, order, name, description")
        
        # Always filter for active topics
        query = query.eq("status", "active")
        
        if block_ids:
            # Parse and validate block_ids
            import uuid
            valid_ids = []
            for id_str in block_ids.split(','):
                id_clean = id_str.strip()
                if id_clean:
                    try:
                        uuid.UUID(id_clean)
                        valid_ids.append(id_clean)
                    except ValueError:
                        pass # Ignore invalid UUIDs
            
            if valid_ids:
                # Topics belong to blocks via block_id
                query = query.in_("block_id", valid_ids)
            elif block_ids.strip(): 
                # If IDs were provided but none were valid, return empty list immediately
                return TopicQueryResponse(ids=[])

        response = query.execute()
        data = response.data

        # Python-side filtering for name, description, and order
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

            # Description filter
            if description_text:
                val = item.get('description') or ""
                if description_exact:
                    if val != description_text:
                        match = False
                else:
                    if description_text.lower() not in val.lower():
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
            
            if match:
                filtered_data.append(item)
        
        ids = [item['id'] for item in filtered_data]
        return TopicQueryResponse(ids=ids)

    except Exception as e:
        logger.error(f"Error querying topics: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, 
            detail="Failed to query topics"
        )


@router.get("/topics/fetch", response_model=TopicListResponse)
async def fetch_topics(
    ids: str = Query(..., description="Comma-separated list of topic IDs"),
    current_user = Depends(get_current_user),
    supabase: Client = Depends(get_supabase),
    credentials: HTTPAuthorizationCredentials = Security(security)
):
    """
    Fetch multiple topics by their IDs.
    
    Requires authentication.
    
    - **ids**: Comma-separated list of UUIDs
    """
    try:
        topic_ids = [id.strip() for id in ids.split(',') if id.strip()]
        
        if not topic_ids:
            return TopicListResponse(topics=[])

        token = credentials.credentials
        response = supabase.postgrest.auth(token).from_("topics").select("*").in_("id", topic_ids).execute()
        return TopicListResponse(topics=response.data)

    except Exception as e:
        logger.error(f"Error fetching topics: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, 
            detail="Failed to fetch topics"
        )





@router.get("/headings/query", response_model=HeadingQueryResponse)
async def query_headings(
    topic_ids: str = Query(None, description="The list of topic ids separated by commas."),
    name_text: str = Query(None, description="The text to search for in the name."),
    name_exact: bool = Query(False, description="Indicates if the name must be exactly the same as the one asked for."),
    description_text: str = Query(None, description="The text to search for in the description."),
    description_exact: bool = Query(False, description="Indicates if the description must be exactly the same as the one asked for."),
    order_number: int = Query(None, description="The order to search for."),
    order_greater: bool = Query(False, description="Indicates if the order must be greater than the one asked for."),
    order_less: bool = Query(False, description="Indicates if the order must be less than the one asked for."),
    current_user = Depends(get_current_user),
    supabase: Client = Depends(get_supabase),
    credentials: HTTPAuthorizationCredentials = Security(security)
):
    """
    Query headings based on criteria.
    Returns a list of heading IDs.
    """
    try:
        token = credentials.credentials
        # Select id, order, name, description, topic_id
        query = supabase.postgrest.auth(token).from_("headings").select("id, order, name, description, topic_id")
        
        # Always filter for active headings
        query = query.eq("status", "active")
        
        if topic_ids:
            # Parse and validate topic_ids
            import uuid
            valid_ids = []
            for id_str in topic_ids.split(','):
                id_clean = id_str.strip()
                if id_clean:
                    try:
                        uuid.UUID(id_clean)
                        valid_ids.append(id_clean)
                    except ValueError:
                        pass # Ignore invalid UUIDs
            
            if valid_ids:
                # Headings belong to topics via topic_id
                query = query.in_("topic_id", valid_ids)
            elif topic_ids.strip():
                 # If IDs were provided but none were valid, return empty list
                return HeadingQueryResponse(ids=[])

        response = query.execute()
        data = response.data

        # Python-side filtering for name, description, and order
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

            # Description filter
            if description_text:
                val = item.get('description') or ""
                if description_exact:
                    if val != description_text:
                        match = False
                else:
                    if description_text.lower() not in val.lower():
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
            
            if match:
                filtered_data.append(item)
        
        ids = [item['id'] for item in filtered_data]
        return HeadingQueryResponse(ids=ids)

    except Exception as e:
        logger.error(f"Error querying headings: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, 
            detail="Failed to query headings"
        )


@router.get("/headings/fetch", response_model=HeadingListResponse)
async def fetch_headings(
    ids: str = Query(..., description="Comma-separated list of heading IDs"),
    current_user = Depends(get_current_user),
    supabase: Client = Depends(get_supabase),
    credentials: HTTPAuthorizationCredentials = Security(security)
):
    """
    Fetch multiple headings by their IDs.
    
    Requires authentication.
    
    - **ids**: Comma-separated list of UUIDs
    """
    try:
        heading_ids = [id.strip() for id in ids.split(',') if id.strip()]
        
        if not heading_ids:
            return HeadingListResponse(headings=[])

        token = credentials.credentials
        response = supabase.postgrest.auth(token).from_("headings").select("*").in_("id", heading_ids).execute()
        return HeadingListResponse(headings=response.data)

    except Exception as e:
        logger.error(f"Error fetching headings: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, 
            detail="Failed to fetch headings"
        )





@router.get("/concepts/query", response_model=ConceptQueryResponse)
async def query_concepts(
    heading_ids: str = Query(None, description="The list of heading ids separated by commas."),
    name_text: str = Query(None, description="The text to search for in the name."),
    name_exact: bool = Query(False, description="Indicates if the name must be exactly the same as the one asked for."),
    description_text: str = Query(None, description="The text to search for in the description."),
    description_exact: bool = Query(False, description="Indicates if the description must be exactly the same as the one asked for."),
    order_number: int = Query(None, description="The order to search for."),
    order_greater: bool = Query(False, description="Indicates if the order must be greater than the one asked for."),
    order_less: bool = Query(False, description="Indicates if the order must be less than the one asked for."),
    current_user = Depends(get_current_user),
    supabase: Client = Depends(get_supabase),
    credentials: HTTPAuthorizationCredentials = Security(security)
):
    """
    Query concepts based on criteria.
    Returns a list of concept IDs.
    """
    try:
        token = credentials.credentials
        # Select id, order, name, description, heading_id
        query = supabase.postgrest.auth(token).from_("concepts").select("id, order, name, description, heading_id")
        
        # Always filter for active concepts
        query = query.eq("status", "active")
        
        if heading_ids:
            # Parse and validate heading_ids
            import uuid
            valid_ids = []
            for id_str in heading_ids.split(','):
                id_clean = id_str.strip()
                if id_clean:
                    try:
                        uuid.UUID(id_clean)
                        valid_ids.append(id_clean)
                    except ValueError:
                        pass # Ignore invalid UUIDs
            
            if valid_ids:
                # Concepts belong to headings via heading_id
                query = query.in_("heading_id", valid_ids)
            elif heading_ids.strip():
                 # If IDs were provided but none were valid, return empty list
                return ConceptQueryResponse(ids=[])

        response = query.execute()
        data = response.data

        # Python-side filtering for name, description, and order
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

            # Description filter
            if description_text:
                val = item.get('description') or ""
                if description_exact:
                    if val != description_text:
                        match = False
                else:
                    if description_text.lower() not in val.lower():
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
            
            if match:
                filtered_data.append(item)
        
        ids = [item['id'] for item in filtered_data]
        return ConceptQueryResponse(ids=ids)

    except Exception as e:
        logger.error(f"Error querying concepts: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, 
            detail="Failed to query concepts"
        )


@router.get("/concepts/fetch", response_model=ConceptListResponse)
async def fetch_concepts(
    ids: str = Query(..., description="Comma-separated list of concept IDs"),
    current_user = Depends(get_current_user),
    supabase: Client = Depends(get_supabase),
    credentials: HTTPAuthorizationCredentials = Security(security)
):
    """
    Fetch multiple concepts by their IDs.
    
    Requires authentication.
    
    - **ids**: Comma-separated list of UUIDs
    """
    try:
        concept_ids = [id.strip() for id in ids.split(',') if id.strip()]
        
        if not concept_ids:
            return ConceptListResponse(concepts=[])

        token = credentials.credentials
        response = supabase.postgrest.auth(token).from_("concepts").select("*").in_("id", concept_ids).execute()
        return ConceptListResponse(concepts=response.data)

    except Exception as e:
        logger.error(f"Error fetching concepts: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, 
            detail="Failed to fetch concepts"
        )





@router.get("/questions/query", response_model=QuestionQueryResponse)
async def query_questions(
    concept_ids: str = Query(None, description="The list of concept ids separated by commas."),
    difficulty_number: int = Query(None, description="The difficulty to search for."),
    difficulty_greater: bool = Query(False, description="Indicates if the difficulty must be greater than the one asked for."),
    difficulty_less: bool = Query(False, description="Indicates if the difficulty must be less than the one asked for."),
    current_user = Depends(get_current_user),
    supabase: Client = Depends(get_supabase),
    credentials: HTTPAuthorizationCredentials = Security(security)
):
    """
    Query questions based on criteria.
    Returns a list of question IDs.
    """
    try:
        token = credentials.credentials
        query = supabase.postgrest.auth(token).from_("questions").select("id")
        
        # Always filter for active questions
        query = query.eq("status", "active")
        
        if concept_ids:
            # Parse and validate concept_ids
            import uuid
            valid_ids = []
            for id_str in concept_ids.split(','):
                id_clean = id_str.strip()
                if id_clean:
                    try:
                        uuid.UUID(id_clean)
                        valid_ids.append(id_clean)
                    except ValueError:
                        pass # Ignore invalid UUIDs
            
            if valid_ids:
                query = query.in_("concept_id", valid_ids)
            elif concept_ids.strip():
                 # If IDs were provided but none were valid, return empty list
                return QuestionQueryResponse(ids=[])

        if difficulty_number is not None:
            if difficulty_greater:
                query = query.gt("difficulty", difficulty_number)
            elif difficulty_less:
                query = query.lt("difficulty", difficulty_number)
            else:
                query = query.eq("difficulty", difficulty_number)

        response = query.execute()
        data = response.data
        
        ids = [item['id'] for item in data]
        return QuestionQueryResponse(ids=ids)

    except Exception as e:
        logger.error(f"Error querying questions: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, 
            detail="Failed to query questions"
        )


@router.get("/questions/fetch", response_model=QuestionListResponse)
async def fetch_questions(
    ids: str = Query(..., description="Comma-separated list of question IDs"),
    current_user = Depends(get_current_user),
    supabase: Client = Depends(get_supabase),
    credentials: HTTPAuthorizationCredentials = Security(security)
):
    """
    Fetch multiple questions by their IDs.
    
    Requires authentication.
    
    - **ids**: Comma-separated list of UUIDs
    """
    try:
        question_ids = [id.strip() for id in ids.split(',') if id.strip()]
        
        if not question_ids:
            return QuestionListResponse(questions=[])

        token = credentials.credentials
        response = supabase.postgrest.auth(token).from_("questions").select("*").in_("id", question_ids).execute()
        return QuestionListResponse(questions=response.data)

    except Exception as e:
        logger.error(f"Error fetching questions: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, 
            detail="Failed to fetch questions"
        )
