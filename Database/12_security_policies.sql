-- ============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================
-- Supabase security policies to control data access
-- Three-tier access control system:
-- 1. USERS ('user' role): Can only read learning content and manage own data
-- 2. CONTENT ADMINS ('content_admin' role): Full CRUD on learning content
-- 3. SUPER ADMINS ('super_admin' role): Full CRUD on all tables
-- ============================================================================

-- ============================================================================
-- Enable RLS on all tables
-- ============================================================================

-- Learning Path Tables (Read-only for users)
ALTER TABLE blocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE topics ENABLE ROW LEVEL SECURITY;
ALTER TABLE headings ENABLE ROW LEVEL SECURITY;
ALTER TABLE concepts ENABLE ROW LEVEL SECURITY;
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE lesson_prerequisites ENABLE ROW LEVEL SECURITY;
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE challenge_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE learning_path_config ENABLE ROW LEVEL SECURITY;

-- User Tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- User Progress Tables (Users can only access their own data)
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_session_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_gamification_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_activity_log ENABLE ROW LEVEL SECURITY;

-- Gamification Tables
ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE leagues ENABLE ROW LEVEL SECURITY;
ALTER TABLE league_participants ENABLE ROW LEVEL SECURITY;

-- Social Tables
ALTER TABLE friends ENABLE ROW LEVEL SECURITY;
ALTER TABLE friendly_matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_challenges_history ENABLE ROW LEVEL SECURITY;

-- Other Tables
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_configuration ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- Learning Path Content Policies (Read-only for authenticated users)
-- ============================================================================

-- Blocks
CREATE POLICY "Blocks are viewable by authenticated users"
    ON blocks FOR SELECT
    TO authenticated
    USING (status = 'active' OR is_content_admin());

-- Topics
CREATE POLICY "Topics are viewable by authenticated users"
    ON topics FOR SELECT
    TO authenticated
    USING (status = 'active' OR is_content_admin());

-- Headings
CREATE POLICY "Headings are viewable by authenticated users"
    ON headings FOR SELECT
    TO authenticated
    USING (status = 'active' OR is_content_admin());

-- Concepts
CREATE POLICY "Concepts are viewable by authenticated users"
    ON concepts FOR SELECT
    TO authenticated
    USING (status = 'active' OR is_content_admin());

-- Questions
CREATE POLICY "Questions are viewable by authenticated users"
    ON questions FOR SELECT
    TO authenticated
    USING (status = 'active' OR is_content_admin());

-- Lessons
CREATE POLICY "Lessons are viewable by authenticated users"
    ON lessons FOR SELECT
    TO authenticated
    USING (status = 'active' OR is_content_admin());

-- Lesson Prerequisites
CREATE POLICY "Lesson prerequisites are viewable by authenticated users"
    ON lesson_prerequisites FOR SELECT
    TO authenticated
    USING (true);

-- Sessions
CREATE POLICY "Sessions are viewable by authenticated users"
    ON sessions FOR SELECT
    TO authenticated
    USING (true);

-- Challenge Templates
CREATE POLICY "Active challenge templates are viewable by authenticated users"
    ON challenge_templates FOR SELECT
    TO authenticated
    USING (active = true OR is_content_admin());

-- Learning Path Config
CREATE POLICY "Learning path config is viewable by authenticated users"
    ON learning_path_config FOR SELECT
    TO authenticated
    USING (true);

-- ============================================================================
-- Content Admin Policies (Full CRUD for content_admin and super_admin roles)
-- ============================================================================

CREATE OR REPLACE FUNCTION is_content_admin()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
AS $$
DECLARE
  uid uuid;
  user_role text;
BEGIN
  -- Read auth.uid() via a SELECT to ensure stable planner behavior
  SELECT auth.uid() INTO uid;
  IF uid IS NULL THEN
    RETURN false; -- no authenticated user in this context
  END IF;

  -- Ensure we select as the function owner (SECURITY DEFINER) and avoid RLS problems
  SELECT role INTO user_role
  FROM public.users
  WHERE id = uid;

  RETURN user_role IN ('content_admin', 'super_admin');
EXCEPTION WHEN OTHERS THEN
  RETURN false;
END;
$$;

-- Blocks
CREATE POLICY "Content admins can insert blocks"
    ON blocks FOR INSERT
    TO authenticated
    WITH CHECK (is_content_admin());

CREATE POLICY "Content admins can update blocks"
    ON blocks FOR UPDATE
    TO authenticated
    USING (is_content_admin())
    WITH CHECK (is_content_admin());

CREATE POLICY "Content admins can delete blocks"
    ON blocks FOR DELETE
    TO authenticated
    USING (is_content_admin());

-- Topics
CREATE POLICY "Content admins can insert topics"
    ON topics FOR INSERT
    TO authenticated
    WITH CHECK (is_content_admin());

CREATE POLICY "Content admins can update topics"
    ON topics FOR UPDATE
    TO authenticated
    USING (is_content_admin())
    WITH CHECK (is_content_admin());

CREATE POLICY "Content admins can delete topics"
    ON topics FOR DELETE
    TO authenticated
    USING (is_content_admin());

-- Headings
CREATE POLICY "Content admins can insert headings"
    ON headings FOR INSERT
    TO authenticated
    WITH CHECK (is_content_admin());

CREATE POLICY "Content admins can update headings"
    ON headings FOR UPDATE
    TO authenticated
    USING (is_content_admin())
    WITH CHECK (is_content_admin());

CREATE POLICY "Content admins can delete headings"
    ON headings FOR DELETE
    TO authenticated
    USING (is_content_admin());

-- Concepts
CREATE POLICY "Content admins can insert concepts"
    ON concepts FOR INSERT
    TO authenticated
    WITH CHECK (is_content_admin());

CREATE POLICY "Content admins can update concepts"
    ON concepts FOR UPDATE
    TO authenticated
    USING (is_content_admin())
    WITH CHECK (is_content_admin());

CREATE POLICY "Content admins can delete concepts"
    ON concepts FOR DELETE
    TO authenticated
    USING (is_content_admin());

-- Questions
CREATE POLICY "Content admins can insert questions"
    ON questions FOR INSERT
    TO authenticated
    WITH CHECK (is_content_admin());

CREATE POLICY "Content admins can update questions"
    ON questions FOR UPDATE
    TO authenticated
    USING (is_content_admin())
    WITH CHECK (is_content_admin());

CREATE POLICY "Content admins can delete questions"
    ON questions FOR DELETE
    TO authenticated
    USING (is_content_admin());

-- Lessons
CREATE POLICY "Content admins can insert lessons"
    ON lessons FOR INSERT
    TO authenticated
    WITH CHECK (is_content_admin());

CREATE POLICY "Content admins can update lessons"
    ON lessons FOR UPDATE
    TO authenticated
    USING (is_content_admin())
    WITH CHECK (is_content_admin());

CREATE POLICY "Content admins can delete lessons"
    ON lessons FOR DELETE
    TO authenticated
    USING (is_content_admin());

-- Lesson Prerequisites
CREATE POLICY "Content admins can insert lesson prerequisites"
    ON lesson_prerequisites FOR INSERT
    TO authenticated
    WITH CHECK (is_content_admin());

CREATE POLICY "Content admins can update lesson prerequisites"
    ON lesson_prerequisites FOR UPDATE
    TO authenticated
    USING (is_content_admin())
    WITH CHECK (is_content_admin());

CREATE POLICY "Content admins can delete lesson prerequisites"
    ON lesson_prerequisites FOR DELETE
    TO authenticated
    USING (is_content_admin());

-- Sessions
CREATE POLICY "Content admins can insert sessions"
    ON sessions FOR INSERT
    TO authenticated
    WITH CHECK (is_content_admin());

CREATE POLICY "Content admins can update sessions"
    ON sessions FOR UPDATE
    TO authenticated
    USING (is_content_admin())
    WITH CHECK (is_content_admin());

CREATE POLICY "Content admins can delete sessions"
    ON sessions FOR DELETE
    TO authenticated
    USING (is_content_admin());

-- Challenge Templates
CREATE POLICY "Content admins can insert challenge templates"
    ON challenge_templates FOR INSERT
    TO authenticated
    WITH CHECK (is_content_admin());

CREATE POLICY "Content admins can update challenge templates"
    ON challenge_templates FOR UPDATE
    TO authenticated
    USING (is_content_admin())
    WITH CHECK (is_content_admin());

CREATE POLICY "Content admins can delete challenge templates"
    ON challenge_templates FOR DELETE
    TO authenticated
    USING (is_content_admin());

-- Learning Path Config
CREATE POLICY "Content admins can insert learning path config"
    ON learning_path_config FOR INSERT
    TO authenticated
    WITH CHECK (is_content_admin());

CREATE POLICY "Content admins can update learning path config"
    ON learning_path_config FOR UPDATE
    TO authenticated
    USING (is_content_admin())
    WITH CHECK (is_content_admin());

CREATE POLICY "Content admins can delete learning path config"
    ON learning_path_config FOR DELETE
    TO authenticated
    USING (is_content_admin());

-- Achievements
CREATE POLICY "Content admins can insert achievements"
    ON achievements FOR INSERT
    TO authenticated
    WITH CHECK (is_content_admin());

CREATE POLICY "Content admins can update achievements"
    ON achievements FOR UPDATE
    TO authenticated
    USING (is_content_admin())
    WITH CHECK (is_content_admin());

CREATE POLICY "Content admins can delete achievements"
    ON achievements FOR DELETE
    TO authenticated
    USING (is_content_admin());

-- Leagues
CREATE POLICY "Content admins can insert leagues"
    ON leagues FOR INSERT
    TO authenticated
    WITH CHECK (is_content_admin());

CREATE POLICY "Content admins can update leagues"
    ON leagues FOR UPDATE
    TO authenticated
    USING (is_content_admin())
    WITH CHECK (is_content_admin());

CREATE POLICY "Content admins can delete leagues"
    ON leagues FOR DELETE
    TO authenticated
    USING (is_content_admin());

-- App Configuration
CREATE POLICY "Content admins can insert app configuration"
    ON app_configuration FOR INSERT
    TO authenticated
    WITH CHECK (is_content_admin());

CREATE POLICY "Content admins can update app configuration"
    ON app_configuration FOR UPDATE
    TO authenticated
    USING (is_content_admin())
    WITH CHECK (is_content_admin());

CREATE POLICY "Content admins can delete app configuration"
    ON app_configuration FOR DELETE
    TO authenticated
    USING (is_content_admin());


-- ============================================================================
-- User Policies (Users can read/write their own data)
-- ============================================================================

-- Users can view their own profile
CREATE POLICY "Users can view their own profile"
    ON users FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = id);

-- Users can insert their own profile
CREATE POLICY "Users can insert their own profile"
    ON users FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update their own profile"
    ON users FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) = id)
    WITH CHECK ((SELECT auth.uid()) = id);

-- Users can view other users' basic info (for social features)
CREATE POLICY "Users can view other users' basic info"
    ON users FOR SELECT
    TO authenticated
    USING (account_status = 'active');

-- ============================================================================
-- User Progress Policies
-- ============================================================================

-- User Progress
CREATE POLICY "Users can view their own progress"
    ON user_progress FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can insert their own progress"
    ON user_progress FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can update their own progress"
    ON user_progress FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id)
    WITH CHECK ((SELECT auth.uid()) = user_id);

-- User Session History
CREATE POLICY "Users can view their own session history"
    ON user_session_history FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can insert their own session history"
    ON user_session_history FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can update their own session history"
    ON user_session_history FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id)
    WITH CHECK ((SELECT auth.uid()) = user_id);

-- User Questions History
CREATE POLICY "Users can view their own question history"
    ON user_questions_history FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can insert their own question history"
    ON user_questions_history FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can update their own question history"
    ON user_questions_history FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id)
    WITH CHECK ((SELECT auth.uid()) = user_id);

-- User Gamification Stats
CREATE POLICY "Users can view gamification stats"
    ON user_gamification_stats FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Users can insert their own gamification stats"
    ON user_gamification_stats FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can update their own gamification stats"
    ON user_gamification_stats FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id)
    WITH CHECK ((SELECT auth.uid()) = user_id);

-- Daily Activity Log
CREATE POLICY "Users can view their own activity log"
    ON daily_activity_log FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can insert their own activity log"
    ON daily_activity_log FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can update their own activity log"
    ON daily_activity_log FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id)
    WITH CHECK ((SELECT auth.uid()) = user_id);

-- ============================================================================
-- Gamification Policies
-- ============================================================================

-- Achievements (Read-only)
CREATE POLICY "Achievements are viewable by authenticated users"
    ON achievements FOR SELECT
    TO authenticated
    USING (active = true);

-- User Achievements
CREATE POLICY "Users can view achievements"
    ON user_achievements FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Users can insert their own achievements"
    ON user_achievements FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can update their own achievements"
    ON user_achievements FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id)
    WITH CHECK ((SELECT auth.uid()) = user_id);

-- Leagues (Read-only)
CREATE POLICY "Active leagues are viewable by authenticated users"
    ON leagues FOR SELECT
    TO authenticated
    USING (active = true);

-- League Participants
CREATE POLICY "Users can view league participants"
    ON league_participants FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Users can insert their own league participation"
    ON league_participants FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can update their own league participation"
    ON league_participants FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id)
    WITH CHECK ((SELECT auth.uid()) = user_id);

-- ============================================================================
-- Social Features Policies
-- ============================================================================

-- Friends
CREATE POLICY "Users can view their own friendships"
    ON friends FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) IN (user_id_1, user_id_2));

CREATE POLICY "Users can create friend requests"
    ON friends FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT auth.uid()) = requested_by AND (SELECT auth.uid()) IN (user_id_1, user_id_2));

CREATE POLICY "Users can update their own friendships"
    ON friends FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) IN (user_id_1, user_id_2))
    WITH CHECK ((SELECT auth.uid()) IN (user_id_1, user_id_2));

CREATE POLICY "Users can delete their own friendships"
    ON friends FOR DELETE
    TO authenticated
    USING ((SELECT auth.uid()) IN (user_id_1, user_id_2));

-- Friendly Matches
CREATE POLICY "Users can view their own matches"
    ON friendly_matches FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) IN (challenger_id, opponent_id));

CREATE POLICY "Users can create match challenges"
    ON friendly_matches FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT auth.uid()) = challenger_id);

CREATE POLICY "Users can update their own matches"
    ON friendly_matches FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) IN (challenger_id, opponent_id))
    WITH CHECK ((SELECT auth.uid()) IN (challenger_id, opponent_id));

-- User Challenges History
ALTER TABLE user_challenges_history ENABLE ROW LEVEL SECURITY;

-- ...

-- Challenge History
CREATE POLICY "Users can view their own challenge history"
    ON user_challenges_history FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can insert their own challenge history"
    ON user_challenges_history FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can update their own challenge history"
    ON user_challenges_history FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id)
    WITH CHECK ((SELECT auth.uid()) = user_id);

-- ============================================================================
-- Notifications Policies
-- ============================================================================

CREATE POLICY "Users can view their own notifications"
    ON notifications FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can update their own notifications"
    ON notifications FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id)
    WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users can delete their own notifications"
    ON notifications FOR DELETE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

-- ============================================================================
-- App Configuration Policies (Read-only)
-- ============================================================================

CREATE POLICY "App configuration is viewable by authenticated users"
    ON app_configuration FOR SELECT
    TO authenticated
    USING (true);

-- ============================================================================
-- Comments for documentation
-- ============================================================================

COMMENT ON POLICY "Blocks are viewable by authenticated users" ON blocks IS 'Users can only view active blocks';
COMMENT ON POLICY "Users can view their own progress" ON user_progress IS 'Users can only access their own progress data';
COMMENT ON POLICY "Users can view league participants" ON league_participants IS 'All users can view league leaderboards';
