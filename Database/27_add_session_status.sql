-- Migration to add status to user_session_history
-- Date: 2025-12-27

-- Add status column with CHECK constraint
ALTER TABLE user_session_history 
ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'started' 
CHECK (status IN ('started', 'completed', 'abandoned'));

-- Update existing records
-- If it has completed_at or passed is not null, it's completed.
UPDATE user_session_history
SET status = 'completed'
WHERE (completed_at IS NOT NULL OR passed IS NOT NULL);

-- Migration for user_questions_history (optional, but keep it consistent)
-- Existing code uses 'correct' boolean and 'answered_at' timestamp.
