-- ============================================================================
-- CREATE LESSON HISTORY ON SESSION START TRIGGER
-- ============================================================================
-- Automatically creates an entry in user_lessons_history when a session starts
-- if it doesn't already exist for that user and lesson.
-- ============================================================================

CREATE OR REPLACE FUNCTION handle_user_lesson_history_on_session_start()
RETURNS TRIGGER AS $$
DECLARE
    v_lesson_id UUID;
BEGIN
    -- 1. Get the parent lesson id of the session
    SELECT lesson_id INTO v_lesson_id FROM sessions WHERE id = NEW.session_id;

    -- 2. Check if there is an entry for the user and lesson in user_lessons_history
    -- 3. If there is not, create it
    IF NOT EXISTS (
        SELECT 1 FROM user_lessons_history 
        WHERE user_id = NEW.user_id AND lesson_id = v_lesson_id
    ) THEN
        INSERT INTO user_lessons_history (user_id, lesson_id, started_at)
        VALUES (NEW.user_id, v_lesson_id, NEW.started_at);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to user_session_history
DROP TRIGGER IF EXISTS on_session_start_lesson_history ON user_session_history;
CREATE TRIGGER on_session_start_lesson_history
AFTER INSERT ON user_session_history
FOR EACH ROW EXECUTE FUNCTION handle_user_lesson_history_on_session_start();

-- Add documentation comments
COMMENT ON FUNCTION handle_user_lesson_history_on_session_start() IS 'Trigger function to ensure lesson history exists when a session is started';
COMMENT ON TRIGGER on_session_start_lesson_history ON user_session_history IS 'Ensures user_lessons_history entry exists for the parent lesson when a session starts';
