-- ============================================================================
-- QUESTION POOL FUNCTIONS
-- ============================================================================
-- Functions to support dynamic question pool selection for sessions
-- based on hierarchical learning path criteria and difficulty filters
-- ============================================================================

-- Get Questions by Criteria Function
-- Returns question IDs that match the specified hierarchy level and difficulty range
-- Parameters can be null to indicate "not filtering by this level"
CREATE OR REPLACE FUNCTION get_questions_by_criteria(
    p_block_id UUID DEFAULT NULL,
    p_topic_id UUID DEFAULT NULL,
    p_heading_id UUID DEFAULT NULL,
    p_concept_id UUID DEFAULT NULL,
    p_min_difficulty INTEGER DEFAULT NULL,
    p_max_difficulty INTEGER DEFAULT NULL
)
RETURNS TABLE (
    question_id UUID,
    difficulty INTEGER,
    concept_id UUID,
    concept_name TEXT,
    heading_name TEXT,
    topic_name TEXT,
    block_name TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        q.id as question_id,
        q.difficulty,
        q.concept_id,
        c.name as concept_name,
        h.name as heading_name,
        t.name as topic_name,
        b.name as block_name
    FROM questions q
    JOIN concepts c ON q.concept_id = c.id
    JOIN headings h ON c.heading_id = h.id
    JOIN topics t ON h.topic_id = t.id
    JOIN blocks b ON t.block_id = b.id
    WHERE 
        -- Filter by hierarchy level (most specific level takes precedence)
        (p_concept_id IS NULL OR q.concept_id = p_concept_id)
        AND (p_heading_id IS NULL OR c.heading_id = p_heading_id)
        AND (p_topic_id IS NULL OR h.topic_id = p_topic_id)
        AND (p_block_id IS NULL OR t.block_id = p_block_id)
        -- Filter by difficulty range
        AND (p_min_difficulty IS NULL OR q.difficulty >= p_min_difficulty)
        AND (p_max_difficulty IS NULL OR q.difficulty <= p_max_difficulty)
        -- Only include active questions
        AND q.status = 'active'
    ORDER BY q.difficulty, q.created_at;
END;
$$ LANGUAGE plpgsql;

-- Populate Session Question Pool Function
-- Deletes existing pool entries for a session and inserts new ones based on criteria
-- Returns the count of questions added to the pool
CREATE OR REPLACE FUNCTION populate_session_question_pool(
    p_session_id UUID,
    p_block_id UUID DEFAULT NULL,
    p_topic_id UUID DEFAULT NULL,
    p_heading_id UUID DEFAULT NULL,
    p_concept_id UUID DEFAULT NULL,
    p_min_difficulty INTEGER DEFAULT NULL,
    p_max_difficulty INTEGER DEFAULT NULL
)
RETURNS INTEGER AS $$
DECLARE
    v_question_count INTEGER;
    v_selection_strategy TEXT;
BEGIN
    -- Get the session's selection strategy
    SELECT question_selection_strategy INTO v_selection_strategy
    FROM sessions
    WHERE id = p_session_id;
    
    -- Delete existing pool entries for this session
    DELETE FROM session_question_pool WHERE session_id = p_session_id;
    
    -- Insert new pool entries based on criteria
    INSERT INTO session_question_pool (session_id, question_id, weight, active)
    SELECT 
        p_session_id,
        gq.question_id,
        -- Set weight based on difficulty for weighted strategies
        CASE 
            WHEN v_selection_strategy = 'weighted_by_difficulty' THEN gq.difficulty
            ELSE NULL
        END as weight,
        true as active
    FROM get_questions_by_criteria(
        p_block_id,
        p_topic_id,
        p_heading_id,
        p_concept_id,
        p_min_difficulty,
        p_max_difficulty
    ) gq;
    
    -- Get count of inserted questions
    GET DIAGNOSTICS v_question_count = ROW_COUNT;
    
    RETURN v_question_count;
END;
$$ LANGUAGE plpgsql;

-- Get Question Count by Criteria Function (for preview)
-- Returns just the count of matching questions without inserting into the pool
CREATE OR REPLACE FUNCTION get_question_count_by_criteria(
    p_block_id UUID DEFAULT NULL,
    p_topic_id UUID DEFAULT NULL,
    p_heading_id UUID DEFAULT NULL,
    p_concept_id UUID DEFAULT NULL,
    p_min_difficulty INTEGER DEFAULT NULL,
    p_max_difficulty INTEGER DEFAULT NULL
)
RETURNS INTEGER AS $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM get_questions_by_criteria(
        p_block_id,
        p_topic_id,
        p_heading_id,
        p_concept_id,
        p_min_difficulty,
        p_max_difficulty
    );
    
    RETURN v_count;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- Comments for documentation
-- ============================================================================

COMMENT ON FUNCTION get_questions_by_criteria IS 'Returns questions matching hierarchy and difficulty criteria';
COMMENT ON FUNCTION populate_session_question_pool IS 'Populates session question pool based on criteria, replacing existing entries';
COMMENT ON FUNCTION get_question_count_by_criteria IS 'Returns count of questions matching criteria without populating the pool';
