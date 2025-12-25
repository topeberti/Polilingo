-- ============================================================================
-- RENAME AND ALTER CHALLENGE HISTORY TABLE
-- ============================================================================

-- Rename table
ALTER TABLE IF EXISTS challenge_history RENAME TO user_challenges_history;

-- Drop columns
ALTER TABLE user_challenges_history
DROP COLUMN IF EXISTS questions_answered,
DROP COLUMN IF EXISTS correct_answers,
DROP COLUMN IF EXISTS time_taken,
DROP COLUMN IF EXISTS score,
DROP COLUMN IF EXISTS xp_earned,
DROP COLUMN IF EXISTS new_personal_best,
DROP COLUMN IF EXISTS created_at;

-- Add started_at if it was missing (it was in the original schema, but let's ensure consistency if we dropped created_at)
-- Original schema had started_at and completed_at. We keep those. 
-- created_at was likely redundant or automatic.

-- We also need to rename the sequences/constraints if they were named automatically, 
-- but Postgres usually handles index renaming if they are attached. 
-- However, explicit indexes we created might need renaming if we want to keep naming consistent.
-- Let's rename the indexes in a separate step or just let them be and rename in definition.
-- For migration simplicity, we just rename the table and drop columns. Index renaming is cosmetic here but good for consistency.

ALTER INDEX IF EXISTS idx_challenge_history_user_id RENAME TO idx_user_challenges_history_user_id;
ALTER INDEX IF EXISTS idx_challenge_history_template_id RENAME TO idx_user_challenges_history_template_id;
ALTER INDEX IF EXISTS idx_challenge_history_user_started RENAME TO idx_user_challenges_history_user_started;
