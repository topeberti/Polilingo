-- ============================================================================
-- OPTIMIZE DATABASE INDEXES
-- ============================================================================
-- 1. Add missing indexes for foreign keys (as identified by Supabase Advisor)
-- 2. Remove redundant indexes
-- ============================================================================

BEGIN;

-- 1. Adding Missing Indexes for Foreign Keys
-- ============================================================================

-- friendly_matches
CREATE INDEX IF NOT EXISTS idx_friendly_matches_session_id ON public.friendly_matches(session_id);
CREATE INDEX IF NOT EXISTS idx_friendly_matches_winner_id ON public.friendly_matches(winner_id);

-- friends
CREATE INDEX IF NOT EXISTS idx_friends_requested_by ON public.friends(requested_by);

-- lesson_prerequisites
CREATE INDEX IF NOT EXISTS idx_lesson_prerequisites_prerequisite_lesson_id ON public.lesson_prerequisites(prerequisite_lesson_id);

-- sessions
CREATE INDEX IF NOT EXISTS idx_sessions_block_id ON public.sessions(block_id);
CREATE INDEX IF NOT EXISTS idx_sessions_topic_id ON public.sessions(topic_id);
CREATE INDEX IF NOT EXISTS idx_sessions_heading_id ON public.sessions(heading_id);
CREATE INDEX IF NOT EXISTS idx_sessions_concept_id ON public.sessions(concept_id);

-- user_achievements
CREATE INDEX IF NOT EXISTS idx_user_achievements_achievement_id ON public.user_achievements(achievement_id);

-- user_questions_history
CREATE INDEX IF NOT EXISTS idx_user_questions_history_user_id ON public.user_questions_history(user_id);
CREATE INDEX IF NOT EXISTS idx_user_questions_history_user_session_id ON public.user_questions_history(user_session_history_id);
CREATE INDEX IF NOT EXISTS idx_user_questions_history_user_challenge_id ON public.user_questions_history(user_challenges_history_id);
CREATE INDEX IF NOT EXISTS idx_user_questions_history_question_id ON public.user_questions_history(question_id);


-- 2. Removing Redundant Indexes
-- ============================================================================

-- Remove idx_daily_activity_user_id on daily_activity_log 
-- Redundant with daily_activity_log_user_id_activity_date_key (unique constraint)
DROP INDEX IF EXISTS public.idx_daily_activity_user_id;

-- Remove idx_user_progress_user_id on user_progress
-- Redundant with composite primary key (user_id, lesson_id)
DROP INDEX IF EXISTS public.idx_user_progress_user_id;

COMMIT;
