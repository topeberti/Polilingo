-- ============================================================================
-- DATABASE INDEXES
-- ============================================================================
-- Performance optimization indexes for frequently queried columns
-- ============================================================================

-- ============================================================================
-- Learning Path Tables Indexes
-- ============================================================================

-- Questions: Frequently filtered by concept, difficulty, and status
CREATE INDEX idx_questions_concept_id ON questions(concept_id);
CREATE INDEX idx_questions_difficulty ON questions(difficulty);
CREATE INDEX idx_questions_status ON questions(status);
CREATE INDEX idx_questions_concept_difficulty_status ON questions(concept_id, difficulty, status);

-- Sessions: Frequently queried by lesson and order
CREATE INDEX idx_sessions_lesson_id ON sessions(lesson_id);
CREATE INDEX idx_sessions_lesson_order ON sessions(lesson_id, "order");

-- Lessons: Frequently queried by order and status
CREATE INDEX idx_lessons_order ON lessons("order");
CREATE INDEX idx_lessons_status ON lessons(status);
CREATE INDEX idx_lessons_order_status ON lessons("order", status);

-- Session Question Pool: Frequently joined
CREATE INDEX idx_session_question_pool_session_id ON session_question_pool(session_id);
CREATE INDEX idx_session_question_pool_question_id ON session_question_pool(question_id);
CREATE INDEX idx_session_question_pool_active ON session_question_pool(session_id, active);

-- Hierarchy tables: Frequently queried by parent and order
CREATE INDEX idx_topics_block_id ON topics(block_id);
CREATE INDEX idx_topics_block_order ON topics(block_id, "order");
CREATE INDEX idx_headings_topic_id ON headings(topic_id);
CREATE INDEX idx_headings_topic_order ON headings(topic_id, "order");
CREATE INDEX idx_concepts_heading_id ON concepts(heading_id);
CREATE INDEX idx_concepts_heading_order ON concepts(heading_id, "order");

-- ============================================================================
-- User Progress Tables Indexes
-- ============================================================================

-- User Session History: Frequently queried by user, session, and time
CREATE INDEX idx_user_session_history_user_id ON user_session_history(user_id);
CREATE INDEX idx_user_session_history_session_id ON user_session_history(session_id);
CREATE INDEX idx_user_session_history_user_started ON user_session_history(user_id, started_at DESC);
CREATE INDEX idx_user_session_history_lesson_id ON user_session_history(lesson_id);

-- User Progress: Frequently queried by user and status
CREATE INDEX idx_user_progress_user_id ON user_progress(user_id);
CREATE INDEX idx_user_progress_lesson_id ON user_progress(lesson_id);
CREATE INDEX idx_user_progress_user_status ON user_progress(user_id, status);

-- Daily Activity Log: Frequently queried by user and date
CREATE INDEX idx_daily_activity_user_id ON daily_activity_log(user_id);
CREATE INDEX idx_daily_activity_user_date ON daily_activity_log(user_id, activity_date DESC);
CREATE INDEX idx_daily_activity_date ON daily_activity_log(activity_date);

-- ============================================================================
-- Gamification Tables Indexes
-- ============================================================================

-- League Participants: Frequently queried for leaderboards
CREATE INDEX idx_league_participants_league_id ON league_participants(league_id);
CREATE INDEX idx_league_participants_user_id ON league_participants(user_id);
CREATE INDEX idx_league_participants_leaderboard ON league_participants(league_id, xp_earned_this_week DESC);

-- Leagues: Frequently queried by active status and dates
CREATE INDEX idx_leagues_active ON leagues(active);
CREATE INDEX idx_leagues_dates ON leagues(start_date, end_date);

-- User Achievements: Frequently queried by user
CREATE INDEX idx_user_achievements_user_id ON user_achievements(user_id);
CREATE INDEX idx_user_achievements_unlocked ON user_achievements(user_id, unlocked_at DESC);

-- Achievements: Frequently queried by type and active status
CREATE INDEX idx_achievements_type ON achievements(type);
CREATE INDEX idx_achievements_active ON achievements(active);

-- ============================================================================
-- Social Features Indexes
-- ============================================================================

-- Friends: Frequently queried by both user IDs and status
CREATE INDEX idx_friends_user_id_1 ON friends(user_id_1, status);
CREATE INDEX idx_friends_user_id_2 ON friends(user_id_2, status);
CREATE INDEX idx_friends_status ON friends(status);

-- Friendly Matches: Frequently queried by both users and status
CREATE INDEX idx_friendly_matches_challenger ON friendly_matches(challenger_id, status);
CREATE INDEX idx_friendly_matches_opponent ON friendly_matches(opponent_id, status);
CREATE INDEX idx_friendly_matches_status ON friendly_matches(status);
CREATE INDEX idx_friendly_matches_created ON friendly_matches(created_at DESC);

-- Challenge History: Frequently queried by user and template
CREATE INDEX idx_challenge_history_user_id ON challenge_history(user_id);
CREATE INDEX idx_challenge_history_template_id ON challenge_history(challenge_template_id);
CREATE INDEX idx_challenge_history_user_started ON challenge_history(user_id, started_at DESC);

-- ============================================================================
-- Notifications Indexes
-- ============================================================================

-- Notifications: Frequently queried by user and read status
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_user_unread ON notifications(user_id, read_at) WHERE read_at IS NULL;
CREATE INDEX idx_notifications_user_created ON notifications(user_id, created_at DESC);
CREATE INDEX idx_notifications_type ON notifications(type);

-- ============================================================================
-- Users Indexes
-- ============================================================================

-- Users: Frequently queried by username and email
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_last_active ON users(last_active DESC);
CREATE INDEX idx_users_account_status ON users(account_status);

-- ============================================================================
-- Comments for documentation
-- ============================================================================

COMMENT ON INDEX idx_league_participants_leaderboard IS 'Optimizes leaderboard queries for league rankings';
COMMENT ON INDEX idx_notifications_user_unread IS 'Partial index for efficient unread notification counts';
COMMENT ON INDEX idx_user_session_history_user_started IS 'Optimizes user session history queries ordered by time';
