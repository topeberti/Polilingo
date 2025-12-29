-- ============================================================================
-- COMPLETE LESSON ON LAST SESSION FINISH TRIGGER
-- ============================================================================
-- Automatically marks an entry in user_lessons_history as completed and passed
-- when the last session of that lesson is finished and passed.
-- ============================================================================

CREATE OR REPLACE FUNCTION handle_user_lesson_history_on_session_finish()
RETURNS TRIGGER AS $$
DECLARE
    v_lesson_id UUID;
    v_session_order INTEGER;
    v_max_order INTEGER;
BEGIN
    -- Only proceed if the session was passed and completed
    IF NEW.status = 'completed' AND NEW.passed = true THEN
        -- 1. Get the lesson id and order of the session
        SELECT lesson_id, "order" INTO v_lesson_id, v_session_order 
        FROM sessions WHERE id = NEW.session_id;

        -- 2. Get the maximum order for sessions in that lesson
        SELECT MAX("order") INTO v_max_order 
        FROM sessions WHERE lesson_id = v_lesson_id;

        -- 3. If it is the last session, update lesson history
        IF v_session_order = v_max_order THEN
            UPDATE user_lessons_history 
            SET completed_at = NOW(), 
                passed = true
            WHERE user_id = NEW.user_id 
              AND lesson_id = v_lesson_id 
              AND completed_at IS NULL;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to user_session_history
DROP TRIGGER IF EXISTS on_session_finish_lesson_history ON user_session_history;
CREATE TRIGGER on_session_finish_lesson_history
AFTER UPDATE ON user_session_history
FOR EACH ROW
WHEN (OLD.status IS DISTINCT FROM NEW.status OR OLD.passed IS DISTINCT FROM NEW.passed)
EXECUTE FUNCTION handle_user_lesson_history_on_session_finish();

-- Add documentation comments
COMMENT ON FUNCTION handle_user_lesson_history_on_session_finish() IS 'Trigger function to complete lesson history when the last session is finished';
COMMENT ON TRIGGER on_session_finish_lesson_history ON user_session_history IS 'Automatically marks lesson as completed when the last session is passed';
