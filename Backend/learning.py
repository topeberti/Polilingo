"""
Learning session management router for fetching questions for learning sessions.
"""

from fastapi import APIRouter, Depends, HTTPException, status, Query, Security
from fastapi.security import HTTPAuthorizationCredentials
from supabase import Client
from typing import List
import logging
import uuid

from config import get_supabase
from models import LearningQuestion, SessionQuestionsResponse, StartSessionRequest, FinishSessionRequest, StartSessionResponse, AnswerQuestionRequest, AnswerQuestionResponse
from middleware import get_current_user, security
from pool_algorithms import select_random, select_random_not_repeated, select_error_review

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/learning", tags=["Learning"])


@router.get("/session/questions", response_model=SessionQuestionsResponse)
async def get_session_questions(
    session_id: str = Query(..., description="The id of the session"),
    current_user = Depends(get_current_user),
    supabase: Client = Depends(get_supabase),
    credentials: HTTPAuthorizationCredentials = Security(security)
):
    """
    Given a session id, returns the questions that the user has to answer in that session.
    
    Steps:
    1. Fetch the session using the session id.
    2. Fetch the question ids that match the session parameters.
    3. Fetch any other questions ids needed depending on the question_selection_strategy.
    4. Execute the question_selection_strategy to select the question ids.
    5. Fetch the questions using the question ids.
    6. Return the questions in the order given by the question_selection_strategy.
    """
    try:
        # Validate session_id is a UUID
        try:
            uuid.UUID(session_id)
        except ValueError:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid session_id format"
            )
        
        token = credentials.credentials
        user_id = current_user.id
        
        # Step 1: Fetch the session
        logger.info(f"Fetching session {session_id}")
        session_response = supabase.postgrest.auth(token).from_("sessions").select("*").eq("id", session_id).execute()
        
        if not session_response.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Session not found"
            )
        
        session = session_response.data[0]
        logger.info(f"Session fetched: {session}")
        
        # Step 2: Fetch question ids that match the session parameters
        question_query = supabase.postgrest.auth(token).from_("questions").select("id")
        
        # Apply filters based on session parameters
        if session.get("concept_id"):
            question_query = question_query.eq("concept_id", session["concept_id"])
        
        if session.get("heading_id"):
            # Need to join with concepts table to filter by heading_id
            # First get concepts with this heading_id
            concepts_response = supabase.postgrest.auth(token).from_("concepts").select("id").eq("heading_id", session["heading_id"]).execute()
            concept_ids = [c["id"] for c in concepts_response.data]
            if concept_ids:
                question_query = question_query.in_("concept_id", concept_ids)
            else:
                # No concepts found for this heading, return empty
                return {"questions": []}
        
        if session.get("topic_id"):
            # Get headings -> concepts
            headings_response = supabase.postgrest.auth(token).from_("headings").select("id").eq("topic_id", session["topic_id"]).execute()
            heading_ids = [h["id"] for h in headings_response.data]
            if heading_ids:
                concepts_response = supabase.postgrest.auth(token).from_("concepts").select("id").in_("heading_id", heading_ids).execute()
                concept_ids = [c["id"] for c in concepts_response.data]
                if concept_ids:
                    question_query = question_query.in_("concept_id", concept_ids)
                else:
                    return {"questions": []}
            else:
                return {"questions": []}
        
        if session.get("block_id"):
            # Get topics -> headings -> concepts
            topics_response = supabase.postgrest.auth(token).from_("topics").select("id").eq("block_id", session["block_id"]).execute()
            topic_ids = [t["id"] for t in topics_response.data]
            if topic_ids:
                headings_response = supabase.postgrest.auth(token).from_("headings").select("id").in_("topic_id", topic_ids).execute()
                heading_ids = [h["id"] for h in headings_response.data]
                if heading_ids:
                    concepts_response = supabase.postgrest.auth(token).from_("concepts").select("id").in_("heading_id", heading_ids).execute()
                    concept_ids = [c["id"] for c in concepts_response.data]
                    if concept_ids:
                        question_query = question_query.in_("concept_id", concept_ids)
                    else:
                        return {"questions": []}
                else:
                    return {"questions": []}
            else:
                return {"questions": []}
        
        # Apply difficulty filters
        if session.get("min_difficulty") is not None:
            question_query = question_query.gte("difficulty", session["min_difficulty"])
        
        if session.get("max_difficulty") is not None:
            question_query = question_query.lte("difficulty", session["max_difficulty"])
        
        # Execute the query
        logger.info("Fetching questions matching session criteria")
        questions_pool_response = question_query.execute()
        question_pool_ids = [q["id"] for q in questions_pool_response.data]
        
        logger.info(f"Found {len(question_pool_ids)} questions in pool")
        
        if not question_pool_ids:
            return {"questions": []}
        
        # Step 3 & 4: Apply question selection strategy
        strategy = session.get("question_selection_strategy", "random")
        num_questions = session.get("number_of_questions", 10)
        
        logger.info(f"Applying strategy: {strategy} to select {num_questions} questions")
        
        if strategy == "random":
            selected_question_ids = select_random(num_questions, question_pool_ids)
        
        elif strategy == "random_not_repeated":
            # Fetch answered question ids for this user
            answered_response = supabase.postgrest.auth(token).from_("user_questions_history").select("question_id").eq("user_id", user_id).execute()
            answered_ids = [q["question_id"] for q in answered_response.data]
            selected_question_ids = select_random_not_repeated(num_questions, question_pool_ids, answered_ids)
        
        elif strategy == "error_review":
            # Fetch question statistics for error review
            # Get all answered questions with correct/incorrect counts
            user_history = supabase.postgrest.auth(token).from_("user_questions_history").select("question_id, correct").eq("user_id", user_id).execute()
            
            # Calculate stats for each question
            question_stats_dict = {}
            for record in user_history.data:
                qid = record["question_id"]
                if qid not in question_stats_dict:
                    question_stats_dict[qid] = {"correct": 0, "wrong": 0}
                
                if record["correct"]:
                    question_stats_dict[qid]["correct"] += 1
                else:
                    question_stats_dict[qid]["wrong"] += 1
            
            # Filter to only include questions in the pool
            question_stats = []
            for qid in question_pool_ids:
                if qid in question_stats_dict:
                    stats = question_stats_dict[qid]
                    question_stats.append((qid, stats["correct"], stats["wrong"]))
                else:
                    # Never answered, treat as high priority
                    question_stats.append((qid, 0, 1))
            
            selected_question_ids = select_error_review(num_questions, question_stats)
        
        else:
            # Unknown strategy, default to random
            logger.warning(f"Unknown strategy '{strategy}', defaulting to random")
            selected_question_ids = select_random(num_questions, question_pool_ids)
        
        logger.info(f"Selected {len(selected_question_ids)} questions")
        
        # Step 5: Fetch full question data
        if not selected_question_ids:
            return {"questions": []}
        
        full_questions_response = supabase.postgrest.auth(token).from_("questions").select("*").in_("id", selected_question_ids).execute()
        
        # Step 6: Return questions in the order selected by the strategy
        # Create a mapping of id to question
        questions_map = {q["id"]: q for q in full_questions_response.data}
        
        # Order questions according to selected_question_ids and map to LearningQuestion format
        ordered_questions = []
        for qid in selected_question_ids:
            if qid in questions_map:
                q = questions_map[qid]
                learning_q = LearningQuestion(
                    id=q["id"],
                    question=q["text"],
                    a=q["option_a"],
                    b=q["option_b"],
                    c=q["option_c"]
                )
                ordered_questions.append(learning_q)
        
        logger.info(f"Returning {len(ordered_questions)} questions")
        
        return SessionQuestionsResponse(questions=ordered_questions)
    
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error fetching session questions: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch session questions: {str(e)}"
        )


@router.post("/session/start", response_model=StartSessionResponse, status_code=status.HTTP_201_CREATED)
async def start_session(
    request: StartSessionRequest,
    current_user = Depends(get_current_user),
    supabase: Client = Depends(get_supabase),
    credentials: HTTPAuthorizationCredentials = Security(security)
):
    """
    Start a session by creating a new row in user_session_history table setting the session_id, user_id and started_at fields.
    Returns the id of the created row.
    """
    try:
        # Validate session_id is a UUID
        try:
            uuid.UUID(request.session_id)
        except ValueError:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid session_id format"
            )
            
        token = credentials.credentials
        user_id = current_user.id
        
        logger.info(f"Starting session {request.session_id} for user {user_id}")
        
        # Verify session exists
        session_response = supabase.postgrest.auth(token).from_("sessions").select("id").eq("id", request.session_id).execute()
        if not session_response.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Session not found"
            )
            
        # STEP: Mark any previous 'started' sessions for this user as 'abandoned'
        logger.info(f"Checking for existing 'started' sessions to abandon for user {user_id}")
        supabase.postgrest.auth(token).from_("user_session_history")\
            .update({"status": "abandoned"})\
            .eq("user_id", user_id)\
            .eq("status", "started")\
            .execute()

        # Create new entry in user_session_history
        from datetime import datetime
        
        data = {
            "user_id": user_id,
            "session_id": request.session_id,
            "started_at": datetime.utcnow().isoformat(),
            "status": "started"
        }
        
        insert_response = supabase.postgrest.auth(token).from_("user_session_history").insert(data).execute()
        
        if not insert_response.data:
             raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to create session history record"
            )
            
        new_id = insert_response.data[0]["id"]
        
        logger.info(f"Session {request.session_id} started successfully with history id {new_id}")
        
        return StartSessionResponse(id=new_id, status="started")
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error starting session: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to start session: {str(e)}"
        )


@router.post("/session/finish", status_code=status.HTTP_204_NO_CONTENT)
async def finish_session(
    request: FinishSessionRequest,
    current_user = Depends(get_current_user),
    supabase: Client = Depends(get_supabase),
    credentials: HTTPAuthorizationCredentials = Security(security)
):
    """
    Finish a session by updating the user_sessions_history table setting the finished_at field and the passed field.
    """
    try:
        # Validate session_id is a UUID
        try:
            uuid.UUID(request.history_id)
        except ValueError:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid history_id format"
            )
            
        token = credentials.credentials
        user_id = current_user.id
        
        logger.info(f"Finishing session history {request.history_id} for user {user_id}")
        
        # Verify the session history exists and belongs to the user
        response = supabase.postgrest.auth(token).from_("user_session_history")\
            .select("id")\
            .eq("user_id", user_id)\
            .eq("id", request.history_id)\
            .execute()
            
        if not response.data:
            logger.warning(f"Session history {request.history_id} not found for user {user_id}")
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Session history not found"
            )
        
        from datetime import datetime
        
        update_data = {
            "completed_at": datetime.utcnow().isoformat(),
            "passed": request.passed,
            "status": "completed"
        }
        
        # Add user_id to ensure RLS compliance and extra safety
        logger.info(f"Updating history_id={request.history_id} for user_id={user_id} with data={update_data}")
        
        update_response = supabase.postgrest.auth(token).from_("user_session_history").update(update_data).eq("id", request.history_id).eq("user_id", user_id).execute()
        
        logger.info(f"Update executed. Verifying update...")
        
        # Verify if the update actually happened by reading it back
        verification = supabase.postgrest.auth(token).from_("user_session_history").select("completed_at, passed, status").eq("id", request.history_id).execute()
        
        if not verification.data:
            logger.error(f"Verification failed: Row {request.history_id} not found after update")
            raise HTTPException(status_code=500, detail="Row disappeared after update")
            
        row = verification.data[0]
        if row.get("completed_at") is None or row.get("passed") != request.passed or row.get("status") != 'completed':
             logger.error(f"Verification failed: Data mismatch. DB: {row}, Expected passed={request.passed}, status=completed")
             raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Update operation returned success but data was not updated. Check RLS policies for UPDATE."
            )

        logger.info(f"Session history {request.history_id} finished successfully (passed={request.passed})")
        
        return

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error finishing session: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to finish session: {str(e)}"
        )


@router.post("/question/answer", response_model=AnswerQuestionResponse)
async def answer_question(
    request: AnswerQuestionRequest,
    current_user = Depends(get_current_user),
    supabase: Client = Depends(get_supabase),
    credentials: HTTPAuthorizationCredentials = Security(security)
):
    """
    Answer a question given the question id and the answer (a, b or c).
    
    Steps:
    1. Fetch the question using the question id to get the correct option.
    2. Check if the answer is correct.
    3. Update the user_questions_history table.
    4. Return if the answer is correct.
    """
    try:
        # Validate UUIDs
        try:
            uuid.UUID(request.question_id)
            uuid.UUID(request.user_session_history_id)
        except ValueError:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid UUID format for question_id or user_session_history_id"
            )
            
        if request.answer not in ['a', 'b', 'c']:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Answer must be 'a', 'b', or 'c'"
            )
            
        token = credentials.credentials
        user_id = current_user.id
        
        logger.info(f"User {user_id} answering question {request.question_id} in history {request.user_session_history_id}")
        
        # Step 1: Fetch the question
        question_response = supabase.postgrest.auth(token).from_("questions").select("correct_option, explanation").eq("id", request.question_id).execute()
        
        if not question_response.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Question not found"
            )
            
        question_data = question_response.data[0]
        correct_option = question_data["correct_option"]
        explanation = question_data.get("explanation")
        
        # Step 2: Check if correct
        is_correct = (request.answer == correct_option)
        
        # Step 3: Record in history
        from datetime import datetime
        
        history_data = {
            "user_id": user_id,
            "user_session_history_id": request.user_session_history_id,
            "question_id": request.question_id,
            "started_at": request.started_at.isoformat(),
            "answered_at": datetime.utcnow().isoformat(),
            "asked_for_explanation": request.asked_for_explanation,
            "answer": request.answer,
            "correct": is_correct
        }
        
        logger.info(f"Recording question history: {history_data}")
        
        insert_response = supabase.postgrest.auth(token).from_("user_questions_history").insert(history_data).execute()
        
        if not insert_response.data:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to record question answer in history"
            )
            
        # Step 4: Determine XP gained
        xp_gained = 0
        if is_correct:
            # Fetch XP reward from configuration
            config_response = supabase.postgrest.auth(token).from_("learning_path_config").select("config_value").eq("config_key", "xp_per_correct_answer").execute()
            if config_response.data:
                xp_gained = int(config_response.data[0]["config_value"])
            else:
                xp_gained = 10 # Default fallback
            
        return AnswerQuestionResponse(
            correct=is_correct, 
            explanation=explanation, 
            correct_answer=correct_option,
            xp_gained=xp_gained
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error answering question: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to answer question: {str(e)}"
        )
