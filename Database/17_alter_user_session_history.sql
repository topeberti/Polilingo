-- ============================================================================
-- ALTER USER SESSION HISTORY TABLE
-- ============================================================================
-- Removing columns as requested
-- ============================================================================

ALTER TABLE user_session_history
DROP COLUMN IF EXISTS lesson_id,
DROP COLUMN IF EXISTS questions_shown,
DROP COLUMN IF EXISTS user_answers,
DROP COLUMN IF EXISTS correct_answers,
DROP COLUMN IF EXISTS time_per_question,
DROP COLUMN IF EXISTS total_score,
DROP COLUMN IF EXISTS xp_earned,
DROP COLUMN IF EXISTS question_selection_strategy_used,
DROP COLUMN IF EXISTS created_at;
