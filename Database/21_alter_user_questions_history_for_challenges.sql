-- ============================================================================
-- ALTER USER QUESTIONS HISTORY FOR CHALLENGES
-- ============================================================================
-- Enable linking questions to challenges in addition to sessions
-- ============================================================================

-- Add user_challenges_history_id column
ALTER TABLE user_questions_history
ADD COLUMN IF NOT EXISTS user_challenges_history_id UUID REFERENCES user_challenges_history(id) ON DELETE CASCADE;

-- Make user_session_history_id nullable
ALTER TABLE user_questions_history
ALTER COLUMN user_session_history_id DROP NOT NULL;

-- Add check constraint to ensure mutually exclusive relationship
-- (A question attempt belongs to EITHER a session OR a challenge, but not both, and must belong to one)
ALTER TABLE user_questions_history DROP CONSTRAINT IF EXISTS check_history_source;

ALTER TABLE user_questions_history
ADD CONSTRAINT check_history_source CHECK (
    (user_session_history_id IS NOT NULL AND user_challenges_history_id IS NULL) OR
    (user_session_history_id IS NULL AND user_challenges_history_id IS NOT NULL)
);
