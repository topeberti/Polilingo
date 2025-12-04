-- ============================================================================
-- NOTIFICATIONS AND APP CONFIGURATION TABLES
-- ============================================================================
-- System notifications and global app configuration
-- ============================================================================

-- Notifications Table
-- System and social notifications for users
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Notification content
    type TEXT NOT NULL CHECK (type IN (
        'streak_reminder',
        'friend_request',
        'league_update',
        'achievement_unlock',
        'match_challenge',
        'level_up',
        'match_result',
        'promotion',
        'demotion'
    )),
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    
    -- Related entity (optional)
    related_entity_id UUID,
    related_entity_type TEXT CHECK (related_entity_type IN (
        'friend_request',
        'match',
        'achievement',
        'league',
        'lesson'
    )),
    
    -- Action
    action_url TEXT, -- Deep link within app, e.g., "app://matches/123"
    
    -- Status
    read_at TIMESTAMPTZ,
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- App Configuration Table
-- Global settings editable by learning expert from dashboard
CREATE TABLE app_configuration (
    config_key TEXT PRIMARY KEY,
    config_value TEXT NOT NULL,
    data_type TEXT NOT NULL CHECK (data_type IN ('integer', 'boolean', 'string', 'json', 'array')),
    description TEXT NOT NULL,
    category TEXT NOT NULL CHECK (category IN ('gamification', 'learning', 'social', 'challenges', 'notifications')),
    last_updated TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- Insert default app configuration values
-- ============================================================================

INSERT INTO app_configuration (config_key, config_value, data_type, description, category) VALUES
    ('max_friends', '100', 'integer', 'Maximum number of friends a user can have', 'social'),
    ('friend_match_xp_reward', '25', 'integer', 'XP reward for winning a friendly match', 'social'),
    ('notification_batch_delay', '300', 'integer', 'Seconds to wait before batching notifications', 'notifications'),
    ('streak_reminder_time', '20:00', 'string', 'Default time to send streak reminder notifications', 'notifications'),
    ('enable_push_notifications', 'true', 'boolean', 'Global toggle for push notifications', 'notifications'),
    ('league_size', '50', 'integer', 'Number of users per league group', 'social'),
    ('achievement_notification_duration', '5', 'integer', 'Seconds to display achievement unlock notification', 'gamification');

-- ============================================================================
-- Trigger for automatic timestamp updates
-- ============================================================================

CREATE OR REPLACE FUNCTION update_app_configuration_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_updated = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_app_configuration_timestamp BEFORE UPDATE ON app_configuration
    FOR EACH ROW EXECUTE FUNCTION update_app_configuration_timestamp();

-- ============================================================================
-- Comments for documentation
-- ============================================================================

COMMENT ON TABLE notifications IS 'System and social notifications for users';
COMMENT ON TABLE app_configuration IS 'Global app settings editable from the dashboard';

COMMENT ON COLUMN notifications.related_entity_id IS 'Optional reference to related item (e.g., friend request ID, match ID)';
COMMENT ON COLUMN notifications.action_url IS 'Deep link within app for notification action';
COMMENT ON COLUMN app_configuration.config_value IS 'The actual value (stored as text, cast based on data_type)';
