-- ============================================================================
-- USER PROGRESS TABLES
-- ============================================================================
-- Tracks user advancement through lessons, session history, gamification
-- stats, and daily activity
-- ============================================================================

-- User Progress Table
-- Tracks individual user advancement through the learning path
CREATE TABLE user_progress (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    lesson_id UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    
    -- Progress tracking
    status TEXT NOT NULL DEFAULT 'not_started' CHECK (status IN ('not_started', 'in_progress', 'completed', 'locked')),
    current_session INTEGER DEFAULT 0,
    completion_percentage INTEGER NOT NULL DEFAULT 0 CHECK (completion_percentage >= 0 AND completion_percentage <= 100),
    
    -- Performance metrics
    xp_earned INTEGER NOT NULL DEFAULT 0,
    stars_earned INTEGER NOT NULL DEFAULT 0 CHECK (stars_earned >= 0 AND stars_earned <= 3),
    best_score INTEGER NOT NULL DEFAULT 0 CHECK (best_score >= 0 AND best_score <= 100),
    attempts INTEGER NOT NULL DEFAULT 0,
    
    -- Timestamps
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    PRIMARY KEY (user_id, lesson_id)
);

-- User Session History Table
-- Detailed record of each session attempt
CREATE TABLE user_session_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_id UUID NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
    
    -- Session details
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    
    -- Performance
    passed BOOLEAN
);

-- Detailed record of each question answered within a session or challenge
CREATE TABLE user_questions_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Link to either session or challenge
    user_session_history_id UUID REFERENCES user_session_history(id) ON DELETE CASCADE,
    user_challenges_history_id UUID REFERENCES user_challenges_history(id) ON DELETE CASCADE,
    
    question_id UUID NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
    
    -- Interaction details
    started_at TIMESTAMPTZ NOT NULL,
    answered_at TIMESTAMPTZ,
    asked_for_explanation BOOLEAN NOT NULL DEFAULT false,
    answer TEXT CHECK (answer IN ('a', 'b', 'c')),
    correct BOOLEAN,
    
    -- Creation timestamp
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Ensure distinct parent (one or the other, not both)
    CONSTRAINT check_history_source CHECK (
        (user_session_history_id IS NOT NULL AND user_challenges_history_id IS NULL) OR
        (user_session_history_id IS NULL AND user_challenges_history_id IS NOT NULL)
    )
);

-- User Gamification Stats Table
-- Tracks gamification metrics per user
CREATE TABLE user_gamification_stats (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    
    -- XP and leveling
    total_xp INTEGER NOT NULL DEFAULT 0,
    current_level INTEGER NOT NULL DEFAULT 1,
    xp_to_next_level INTEGER NOT NULL DEFAULT 100,
    
    -- Streaks
    current_streak INTEGER NOT NULL DEFAULT 0,
    longest_streak INTEGER NOT NULL DEFAULT 0,
    last_streak_date DATE,
    streak_freeze_count INTEGER NOT NULL DEFAULT 0,
    
    -- Progress stats
    total_lessons_completed INTEGER NOT NULL DEFAULT 0,
    total_questions_answered INTEGER NOT NULL DEFAULT 0,
    total_correct_answers INTEGER NOT NULL DEFAULT 0,
    accuracy_rate DECIMAL(5,2) NOT NULL DEFAULT 0.0 CHECK (accuracy_rate >= 0 AND accuracy_rate <= 100),
    
    -- League info
    current_league TEXT NOT NULL DEFAULT 'bronze' CHECK (current_league IN ('bronze', 'silver', 'gold', 'diamond', 'obsidian')),
    league_position INTEGER,
    league_points_this_week INTEGER NOT NULL DEFAULT 0,
    
    -- Challenge records
    lightning_round_high_score INTEGER NOT NULL DEFAULT 0,
    perfect_streak_record INTEGER NOT NULL DEFAULT 0,
    
    -- Timestamps
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Daily Activity Log Table
-- Tracks daily user engagement for streak calculation and analytics
CREATE TABLE daily_activity_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    activity_date DATE NOT NULL,
    
    -- Daily metrics
    sessions_completed INTEGER NOT NULL DEFAULT 0,
    lessons_completed INTEGER NOT NULL DEFAULT 0,
    questions_answered INTEGER NOT NULL DEFAULT 0,
    correct_answers INTEGER NOT NULL DEFAULT 0,
    xp_earned INTEGER NOT NULL DEFAULT 0,
    time_spent INTEGER NOT NULL DEFAULT 0, -- minutes
    
    -- Streak tracking
    streak_maintained BOOLEAN NOT NULL DEFAULT false,
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Unique constraint: one record per user per day
    UNIQUE (user_id, activity_date)
);

-- ============================================================================
-- Triggers for automatic timestamp updates
-- ============================================================================

CREATE TRIGGER update_user_progress_updated_at BEFORE UPDATE ON user_progress
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_gamification_stats_updated_at BEFORE UPDATE ON user_gamification_stats
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- Trigger to update last_active when user completes a session
-- ============================================================================

CREATE TRIGGER update_last_active_on_session AFTER INSERT ON user_session_history
    FOR EACH ROW EXECUTE FUNCTION update_user_last_active();

-- ============================================================================
-- Function to initialize gamification stats for new users
-- ============================================================================

CREATE OR REPLACE FUNCTION initialize_user_gamification_stats()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO user_gamification_stats (user_id)
    VALUES (NEW.id)
    ON CONFLICT (user_id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER create_gamification_stats_for_new_user AFTER INSERT ON users
    FOR EACH ROW EXECUTE FUNCTION initialize_user_gamification_stats();

-- ============================================================================
-- Comments for documentation
-- ============================================================================

COMMENT ON TABLE user_progress IS 'Tracks individual user advancement through lessons';
COMMENT ON TABLE user_session_history IS 'Detailed record of each session attempt with questions and answers';
COMMENT ON TABLE user_questions_history IS 'Detailed record of each question answered within a session';
COMMENT ON TABLE user_gamification_stats IS 'Gamification metrics including XP, streaks, and league info';
COMMENT ON TABLE daily_activity_log IS 'Daily user engagement tracking for streaks and analytics';


