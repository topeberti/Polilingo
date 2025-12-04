-- ============================================================================
-- GAMIFICATION TABLES
-- ============================================================================
-- Achievements, badges, leagues, and competitive features
-- ============================================================================

-- Achievements/Badges Table
-- Defines available achievements in the system
CREATE TABLE achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Basic info
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    icon_url TEXT,
    
    -- Achievement configuration
    type TEXT NOT NULL CHECK (type IN ('streak', 'completion', 'accuracy', 'challenge', 'social', 'special')),
    unlock_criteria JSONB NOT NULL, -- e.g., {"streak_days": 7} or {"lessons_completed": 10}
    xp_reward INTEGER NOT NULL DEFAULT 0,
    rarity TEXT NOT NULL DEFAULT 'common' CHECK (rarity IN ('common', 'rare', 'epic', 'legendary')),
    
    -- Display
    "order" INTEGER NOT NULL,
    active BOOLEAN NOT NULL DEFAULT true,
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- User Achievements Table
-- Tracks which achievements each user has unlocked
CREATE TABLE user_achievements (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    achievement_id UUID NOT NULL REFERENCES achievements(id) ON DELETE CASCADE,
    unlocked_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    shown_notification BOOLEAN NOT NULL DEFAULT false,
    
    PRIMARY KEY (user_id, achievement_id)
);

-- Leagues Table
-- Weekly competitive leagues
CREATE TABLE leagues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- League info
    league_name TEXT NOT NULL CHECK (league_name IN ('bronze', 'silver', 'gold', 'diamond', 'obsidian')),
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ NOT NULL,
    
    -- Promotion/demotion thresholds
    promotion_threshold INTEGER NOT NULL, -- Top N users get promoted
    demotion_threshold INTEGER NOT NULL, -- Bottom N users get demoted
    
    -- Status
    active BOOLEAN NOT NULL DEFAULT false,
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- League Participants Table
-- Tracks users in each league period
CREATE TABLE league_participants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    league_id UUID NOT NULL REFERENCES leagues(id) ON DELETE CASCADE,
    
    -- Performance
    xp_earned_this_week INTEGER NOT NULL DEFAULT 0,
    current_rank INTEGER,
    previous_rank INTEGER,
    
    -- Results (set at end of week)
    promoted BOOLEAN,
    demoted BOOLEAN,
    
    -- Timestamps
    joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Unique constraint: one entry per user per league
    UNIQUE (user_id, league_id)
);

-- ============================================================================
-- Triggers for automatic timestamp updates
-- ============================================================================

CREATE TRIGGER update_achievements_updated_at BEFORE UPDATE ON achievements
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_league_participants_updated_at BEFORE UPDATE ON league_participants
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- Comments for documentation
-- ============================================================================

COMMENT ON TABLE achievements IS 'Defines available achievements and badges in the system';
COMMENT ON TABLE user_achievements IS 'Tracks which achievements each user has unlocked';
COMMENT ON TABLE leagues IS 'Weekly competitive league periods';
COMMENT ON TABLE league_participants IS 'User participation and performance in leagues';

COMMENT ON COLUMN achievements.unlock_criteria IS 'JSON conditions to earn this badge, e.g., {"streak_days": 7}';
COMMENT ON COLUMN leagues.promotion_threshold IS 'Top N users promoted to next league tier';
COMMENT ON COLUMN leagues.demotion_threshold IS 'Bottom N users demoted to lower league tier';
