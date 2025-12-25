-- ============================================================================
-- ADD PASSED COLUMN TO HISTORY TABLES
-- ============================================================================

-- Add passed to user_lessons_history
ALTER TABLE user_lessons_history 
ADD COLUMN IF NOT EXISTS passed BOOLEAN;

-- Add passed to user_session_history (already exists in DB, but ensuring consistency in scripts)
ALTER TABLE user_session_history 
ADD COLUMN IF NOT EXISTS passed BOOLEAN;

-- ============================================================================
-- Comments for documentation
-- ============================================================================

COMMENT ON COLUMN user_lessons_history.passed IS 'Whether the lesson attempt met the passing criteria';
COMMENT ON COLUMN user_session_history.passed IS 'Whether the session attempt met the passing criteria';
