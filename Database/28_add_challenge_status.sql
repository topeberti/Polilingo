-- Migration to add status to user_challenges_history
-- Date: 2025-12-27

-- Add status column with CHECK constraint
ALTER TABLE user_challenges_history 
ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'started' 
CHECK (status IN ('started', 'completed', 'abandoned'));

-- Update existing records
-- For challenges, we only have completed_at to go by.
UPDATE user_challenges_history
SET status = 'completed'
WHERE completed_at IS NOT NULL;
