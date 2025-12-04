-- ============================================================================
-- USERS TABLE
-- ============================================================================
-- Core user profile and authentication information
-- Integrates with Supabase Auth
-- ============================================================================

CREATE TABLE users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- Profile information
    username TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT,
    profile_picture_url TEXT,
    
    -- Activity tracking
    date_joined TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_active TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- User preferences
    preferred_study_time TIME, -- e.g., '18:00' for 6 PM
    daily_goal INTEGER NOT NULL DEFAULT 50, -- XP target per day
    notification_preferences JSONB DEFAULT '{
        "streak_reminders": true,
        "friend_activity": true,
        "league_updates": true,
        "achievement_unlocks": true
    }'::jsonb,
    
    -- Account status
    account_status TEXT NOT NULL DEFAULT 'active' CHECK (account_status IN ('active', 'suspended', 'deleted')),
    
    -- User role for access control
    role TEXT NOT NULL DEFAULT 'user' CHECK (role IN ('user', 'content_admin', 'super_admin')),
    
    -- Timestamps
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- Trigger for automatic timestamp updates
-- ============================================================================

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- Function to automatically update last_active on any user activity
-- ============================================================================

CREATE OR REPLACE FUNCTION update_user_last_active()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE users SET last_active = NOW() WHERE id = NEW.user_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- Comments for documentation
-- ============================================================================

COMMENT ON TABLE users IS 'User profiles and authentication information';
COMMENT ON COLUMN users.id IS 'References Supabase auth.users for authentication';
COMMENT ON COLUMN users.username IS 'Unique username for display in leaderboards and social features';
COMMENT ON COLUMN users.preferred_study_time IS 'Preferred time of day for notification reminders';
COMMENT ON COLUMN users.daily_goal IS 'Target XP or lessons per day';
COMMENT ON COLUMN users.notification_preferences IS 'JSON object controlling notification settings';
COMMENT ON COLUMN users.role IS 'Access control role: user (default), content_admin (can manage learning content), super_admin (full access)';
