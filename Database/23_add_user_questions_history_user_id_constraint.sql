-- ============================================================================
-- ADD USER_ID MATCH CONSTRAINT TO USER_QUESTIONS_HISTORY
-- ============================================================================
-- Ensures that user_id in user_questions_history matches the user_id in 
-- user_session_history or user_challenges_history.
-- ============================================================================

-- Function to validate user_id match
CREATE OR REPLACE FUNCTION validate_user_questions_history_user_id()
RETURNS TRIGGER AS $$
DECLARE
    parent_user_id UUID;
BEGIN
    -- Check if it belongs to a session
    IF NEW.user_session_history_id IS NOT NULL THEN
        SELECT user_id INTO parent_user_id 
        FROM user_session_history 
        WHERE id = NEW.user_session_history_id;
        
        IF parent_user_id IS NULL THEN
            RAISE EXCEPTION 'Referenced user_session_history_id % does not exist', NEW.user_session_history_id;
        END IF;
        
        IF parent_user_id != NEW.user_id THEN
            RAISE EXCEPTION 'user_id % in user_questions_history does not match user_id % in user_session_history', 
                NEW.user_id, parent_user_id;
        END IF;
    
    -- Check if it belongs to a challenge
    ELSIF NEW.user_challenges_history_id IS NOT NULL THEN
        SELECT user_id INTO parent_user_id 
        FROM user_challenges_history 
        WHERE id = NEW.user_challenges_history_id;
        
        IF parent_user_id IS NULL THEN
            RAISE EXCEPTION 'Referenced user_challenges_history_id % does not exist', NEW.user_challenges_history_id;
        END IF;
        
        IF parent_user_id != NEW.user_id THEN
            RAISE EXCEPTION 'user_id % in user_questions_history does not match user_id % in user_challenges_history', 
                NEW.user_id, parent_user_id;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to enforce the constraint
DROP TRIGGER IF EXISTS enforce_user_id_match_on_questions_history ON user_questions_history;
CREATE TRIGGER enforce_user_id_match_on_questions_history
BEFORE INSERT OR UPDATE ON user_questions_history
FOR EACH ROW
EXECUTE FUNCTION validate_user_questions_history_user_id();

-- Comments for documentation
COMMENT ON FUNCTION validate_user_questions_history_user_id IS 'Validates that user_id in user_questions_history matches its parent session or challenge';
