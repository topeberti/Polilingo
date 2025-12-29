-- ============================================================================
-- OPTIMIZE RLS PERFORMANCE
-- ============================================================================
-- This migration applies optimization techniques to the Row Level Security (RLS)
-- policies as recommended by the Supabase performance guidelines.
-- 1. Wraps auth.uid() in (select auth.uid()) to avoid row-by-row re-evaluation.
-- 2. Consolidates multiple permissive policies into single policies.
-- ============================================================================

BEGIN;

-- 1. Consolidate Permissive SELECT Policies for Content Tables
-- ============================================================================

-- Blocks
DROP POLICY IF EXISTS "Blocks are viewable by authenticated users" ON public.blocks;
DROP POLICY IF EXISTS "Content admins can view all blocks" ON public.blocks;
CREATE POLICY "Blocks are viewable by authenticated users"
    ON public.blocks FOR SELECT
    TO authenticated
    USING (status = 'active' OR is_content_admin());

-- Topics
DROP POLICY IF EXISTS "Topics are viewable by authenticated users" ON public.topics;
DROP POLICY IF EXISTS "Content admins can view all topics" ON public.topics;
CREATE POLICY "Topics are viewable by authenticated users"
    ON public.topics FOR SELECT
    TO authenticated
    USING (status = 'active' OR is_content_admin());

-- Headings
DROP POLICY IF EXISTS "Headings are viewable by authenticated users" ON public.headings;
DROP POLICY IF EXISTS "Content admins can view all headings" ON public.headings;
CREATE POLICY "Headings are viewable by authenticated users"
    ON public.headings FOR SELECT
    TO authenticated
    USING (status = 'active' OR is_content_admin());

-- Concepts
DROP POLICY IF EXISTS "Concepts are viewable by authenticated users" ON public.concepts;
DROP POLICY IF EXISTS "Content admins can view all concepts" ON public.concepts;
CREATE POLICY "Concepts are viewable by authenticated users"
    ON public.concepts FOR SELECT
    TO authenticated
    USING (status = 'active' OR is_content_admin());

-- Questions
DROP POLICY IF EXISTS "Questions are viewable by authenticated users" ON public.questions;
DROP POLICY IF EXISTS "Content admins can view all questions" ON public.questions;
CREATE POLICY "Questions are viewable by authenticated users"
    ON public.questions FOR SELECT
    TO authenticated
    USING (status = 'active' OR is_content_admin());

-- Lessons
DROP POLICY IF EXISTS "Lessons are viewable by authenticated users" ON public.lessons;
DROP POLICY IF EXISTS "Content admins can view all lessons" ON public.lessons;
CREATE POLICY "Lessons are viewable by authenticated users"
    ON public.lessons FOR SELECT
    TO authenticated
    USING (status = 'active' OR is_content_admin());

-- Challenge Templates
DROP POLICY IF EXISTS "Active challenge templates are viewable by authenticated users" ON public.challenge_templates;
DROP POLICY IF EXISTS "Content admins can view all challenge templates" ON public.challenge_templates;
CREATE POLICY "Active challenge templates are viewable by authenticated users"
    ON public.challenge_templates FOR SELECT
    TO authenticated
    USING (active = true OR is_content_admin());

-- user_gamification_stats
DROP POLICY IF EXISTS "Users can view their own gamification stats" ON public.user_gamification_stats;
DROP POLICY IF EXISTS "Users can view other users' gamification stats" ON public.user_gamification_stats;
CREATE POLICY "Users can view gamification stats"
    ON public.user_gamification_stats FOR SELECT
    TO authenticated
    USING (true);

-- user_achievements
DROP POLICY IF EXISTS "Users can view their own achievements" ON public.user_achievements;
DROP POLICY IF EXISTS "Users can view other users' achievements" ON public.user_achievements;
CREATE POLICY "Users can view achievements"
    ON public.user_achievements FOR SELECT
    TO authenticated
    USING (true);

-- user_lessons_history
DROP POLICY IF EXISTS "Users can view their own lesson history" ON public.user_lessons_history;
DROP POLICY IF EXISTS "Admins can manage user lessons history" ON public.user_lessons_history;
CREATE POLICY "Users can view their own lesson history"
    ON public.user_lessons_history FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = user_id OR is_content_admin());

DROP POLICY IF EXISTS "Users can insert their own lesson history" ON public.user_lessons_history;
CREATE POLICY "Users can insert their own lesson history"
    ON public.user_lessons_history FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT auth.uid()) = user_id OR is_content_admin());

DROP POLICY IF EXISTS "Users can update their own lesson history" ON public.user_lessons_history;
CREATE POLICY "Users can update their own lesson history"
    ON public.user_lessons_history FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id OR is_content_admin())
    WITH CHECK ((SELECT auth.uid()) = user_id OR is_content_admin());

-- user_questions_history
DROP POLICY IF EXISTS "Content admins can view all question history" ON public.user_questions_history;
DROP POLICY IF EXISTS "Users can view their own question history" ON public.user_questions_history;
CREATE POLICY "Users can view their own question history"
    ON public.user_questions_history FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = user_id OR is_content_admin());

-- users (SELECT)
DROP POLICY IF EXISTS "Users can view other users' basic info" ON public.users;
DROP POLICY IF EXISTS "Users can view their own profile" ON public.users;
CREATE POLICY "Users can view profiles"
    ON public.users FOR SELECT
    TO authenticated
    USING ((account_status = 'active') OR ((SELECT auth.uid()) = id));


-- 2. Optimize remaining auth.uid() calls
-- ============================================================================

-- users (INSERT, UPDATE)
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.users;
CREATE POLICY "Users can insert their own profile"
    ON public.users FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT auth.uid()) = id);

DROP POLICY IF EXISTS "Users can update their own profile" ON public.users;
CREATE POLICY "Users can update their own profile"
    ON public.users FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) = id)
    WITH CHECK ((SELECT auth.uid()) = id);

-- user_progress
DROP POLICY IF EXISTS "Users can view their own progress" ON public.user_progress;
CREATE POLICY "Users can view their own progress"
    ON public.user_progress FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

DROP POLICY IF EXISTS "Users can insert their own progress" ON public.user_progress;
CREATE POLICY "Users can insert their own progress"
    ON public.user_progress FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT auth.uid()) = user_id);

DROP POLICY IF EXISTS "Users can update their own progress" ON public.user_progress;
CREATE POLICY "Users can update their own progress"
    ON public.user_progress FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id)
    WITH CHECK ((SELECT auth.uid()) = user_id);

-- user_session_history
DROP POLICY IF EXISTS "Users can view their own session history" ON public.user_session_history;
CREATE POLICY "Users can view their own session history"
    ON public.user_session_history FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

DROP POLICY IF EXISTS "Users can insert their own session history" ON public.user_session_history;
CREATE POLICY "Users can insert their own session history"
    ON public.user_session_history FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT auth.uid()) = user_id);

DROP POLICY IF EXISTS "Users can update their own session history" ON public.user_session_history;
CREATE POLICY "Users can update their own session history"
    ON public.user_session_history FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id)
    WITH CHECK ((SELECT auth.uid()) = user_id);

-- user_questions_history (INSERT, UPDATE)
DROP POLICY IF EXISTS "Users can insert their own question history" ON public.user_questions_history;
CREATE POLICY "Users can insert their own question history"
    ON public.user_questions_history FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT auth.uid()) = user_id);

DROP POLICY IF EXISTS "Users can update their own question history" ON public.user_questions_history;
CREATE POLICY "Users can update their own question history"
    ON public.user_questions_history FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id)
    WITH CHECK ((SELECT auth.uid()) = user_id);

-- user_gamification_stats (INSERT, UPDATE)
DROP POLICY IF EXISTS "Users can insert their own gamification stats" ON public.user_gamification_stats;
CREATE POLICY "Users can insert their own gamification stats"
    ON public.user_gamification_stats FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT auth.uid()) = user_id);

DROP POLICY IF EXISTS "Users can update their own gamification stats" ON public.user_gamification_stats;
CREATE POLICY "Users can update their own gamification stats"
    ON public.user_gamification_stats FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id)
    WITH CHECK ((SELECT auth.uid()) = user_id);

-- daily_activity_log
DROP POLICY IF EXISTS "Users can view their own activity log" ON public.daily_activity_log;
CREATE POLICY "Users can view their own activity log"
    ON public.daily_activity_log FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

DROP POLICY IF EXISTS "Users can insert their own activity log" ON public.daily_activity_log;
CREATE POLICY "Users can insert their own activity log"
    ON public.daily_activity_log FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT auth.uid()) = user_id);

DROP POLICY IF EXISTS "Users can update their own activity log" ON public.daily_activity_log;
CREATE POLICY "Users can update their own activity log"
    ON public.daily_activity_log FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id)
    WITH CHECK ((SELECT auth.uid()) = user_id);

-- user_achievements (INSERT, UPDATE)
DROP POLICY IF EXISTS "Users can insert their own achievements" ON public.user_achievements;
CREATE POLICY "Users can insert their own achievements"
    ON public.user_achievements FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT auth.uid()) = user_id);

DROP POLICY IF EXISTS "Users can update their own achievements" ON public.user_achievements;
CREATE POLICY "Users can update their own achievements"
    ON public.user_achievements FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id)
    WITH CHECK ((SELECT auth.uid()) = user_id);

-- league_participants
DROP POLICY IF EXISTS "Users can insert their own league participation" ON public.league_participants;
CREATE POLICY "Users can insert their own league participation"
    ON public.league_participants FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT auth.uid()) = user_id);

DROP POLICY IF EXISTS "Users can update their own league participation" ON public.league_participants;
CREATE POLICY "Users can update their own league participation"
    ON public.league_participants FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id)
    WITH CHECK ((SELECT auth.uid()) = user_id);

-- friends
DROP POLICY IF EXISTS "Users can view their own friendships" ON public.friends;
CREATE POLICY "Users can view their own friendships"
    ON public.friends FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) IN (user_id_1, user_id_2));

DROP POLICY IF EXISTS "Users can create friend requests" ON public.friends;
CREATE POLICY "Users can create friend requests"
    ON public.friends FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT auth.uid()) = requested_by AND (SELECT auth.uid()) IN (user_id_1, user_id_2));

DROP POLICY IF EXISTS "Users can update their own friendships" ON public.friends;
CREATE POLICY "Users can update their own friendships"
    ON public.friends FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) IN (user_id_1, user_id_2))
    WITH CHECK ((SELECT auth.uid()) IN (user_id_1, user_id_2));

DROP POLICY IF EXISTS "Users can delete their own friendships" ON public.friends;
CREATE POLICY "Users can delete their own friendships"
    ON public.friends FOR DELETE
    TO authenticated
    USING ((SELECT auth.uid()) IN (user_id_1, user_id_2));

-- friendly_matches
DROP POLICY IF EXISTS "Users can view their own matches" ON public.friendly_matches;
CREATE POLICY "Users can view their own matches"
    ON public.friendly_matches FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) IN (challenger_id, opponent_id));

DROP POLICY IF EXISTS "Users can create match challenges" ON public.friendly_matches;
CREATE POLICY "Users can create match challenges"
    ON public.friendly_matches FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT auth.uid()) = challenger_id);

DROP POLICY IF EXISTS "Users can update their own matches" ON public.friendly_matches;
CREATE POLICY "Users can update their own matches"
    ON public.friendly_matches FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) IN (challenger_id, opponent_id))
    WITH CHECK ((SELECT auth.uid()) IN (challenger_id, opponent_id));

-- user_challenges_history
DROP POLICY IF EXISTS "Users can view their own challenge history" ON public.user_challenges_history;
CREATE POLICY "Users can view their own challenge history"
    ON public.user_challenges_history FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

DROP POLICY IF EXISTS "Users can insert their own challenge history" ON public.user_challenges_history;
CREATE POLICY "Users can insert their own challenge history"
    ON public.user_challenges_history FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT auth.uid()) = user_id);

DROP POLICY IF EXISTS "Users can update their own challenge history" ON public.user_challenges_history;
CREATE POLICY "Users can update their own challenge history"
    ON public.user_challenges_history FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id)
    WITH CHECK ((SELECT auth.uid()) = user_id);

-- notifications
DROP POLICY IF EXISTS "Users can view their own notifications" ON public.notifications;
CREATE POLICY "Users can view their own notifications"
    ON public.notifications FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

DROP POLICY IF EXISTS "Users can update their own notifications" ON public.notifications;
CREATE POLICY "Users can update their own notifications"
    ON public.notifications FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id)
    WITH CHECK ((SELECT auth.uid()) = user_id);

DROP POLICY IF EXISTS "Users can delete their own notifications" ON public.notifications;
CREATE POLICY "Users can delete their own notifications"
    ON public.notifications FOR DELETE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

COMMIT;
