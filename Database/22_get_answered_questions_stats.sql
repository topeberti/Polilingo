-- ============================================================================
-- GET ANSWERED QUESTIONS STATS FUNCTION
-- ============================================================================
-- Returns aggregated statistics for questions answered by a specific user.
-- Performs server-side aggregation for high performance.
-- ============================================================================

CREATE OR REPLACE FUNCTION get_answered_questions_stats(p_user_id UUID)
RETURNS TABLE (
    question_id UUID,
    total_attempts BIGINT,
    correct_answers BIGINT
) 
LANGUAGE plpgsql
SECURITY INVOKER -- Use the caller's permissions (RLS will apply)
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        uqh.question_id,
        COUNT(*)::BIGINT as total_attempts,
        COUNT(*) FILTER (WHERE uqh.correct = TRUE)::BIGINT as correct_answers
    FROM user_questions_history uqh
    WHERE uqh.user_id = p_user_id
    GROUP BY uqh.question_id;
END;
$$;

-- Grant execution permission to authenticated users
GRANT EXECUTE ON FUNCTION get_answered_questions_stats(UUID) TO authenticated;

-- Comments for documentation
COMMENT ON FUNCTION get_answered_questions_stats IS 'Returns aggregated statistics for questions answered by a specific user.';
