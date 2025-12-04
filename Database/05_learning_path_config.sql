-- ============================================================================
-- LEARNING PATH CONFIGURATION TABLE
-- ============================================================================
-- Global configuration parameters for the learning path
-- Editable by the learning expert from the dashboard
-- ============================================================================

CREATE TABLE learning_path_config (
    config_key TEXT PRIMARY KEY,
    config_value TEXT NOT NULL,
    data_type TEXT NOT NULL CHECK (data_type IN ('integer', 'boolean', 'string', 'json', 'array')),
    description TEXT NOT NULL,
    category TEXT NOT NULL CHECK (category IN ('gamification', 'learning', 'social', 'challenges', 'notifications')),
    last_updated TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- Insert default configuration values
-- ============================================================================

INSERT INTO learning_path_config (config_key, config_value, data_type, description, category) VALUES
    ('retry_penalty_enabled', 'false', 'boolean', 'Whether retrying a session affects XP rewards', 'learning'),
    ('retry_penalty_percentage', '50', 'integer', 'Percentage of XP reduction on retry (0-100)', 'learning'),
    ('spaced_repetition_intervals', '[1, 3, 7, 14, 30]', 'array', 'Days between spaced repetition reviews', 'learning'),
    ('minimum_passing_score', '70', 'integer', 'Minimum percentage to pass a session', 'learning'),
    ('daily_xp_goal_default', '50', 'integer', 'Default daily XP goal for new users', 'gamification'),
    ('xp_per_correct_answer', '10', 'integer', 'Base XP earned per correct answer', 'gamification'),
    ('streak_freeze_cost', '100', 'integer', 'XP cost to purchase a streak freeze', 'gamification'),
    ('league_week_start_day', 'monday', 'string', 'Day of week when league periods start', 'social'),
    ('league_promotion_threshold', '10', 'integer', 'Top N users promoted to next league', 'social'),
    ('league_demotion_threshold', '5', 'integer', 'Bottom N users demoted to lower league', 'social');

-- ============================================================================
-- Trigger for automatic timestamp updates
-- ============================================================================

CREATE OR REPLACE FUNCTION update_learning_path_config_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_updated = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_learning_path_config_timestamp BEFORE UPDATE ON learning_path_config
    FOR EACH ROW EXECUTE FUNCTION update_learning_path_config_timestamp();

-- ============================================================================
-- Comments for documentation
-- ============================================================================

COMMENT ON TABLE learning_path_config IS 'Global configuration parameters editable from the learning expert dashboard';
COMMENT ON COLUMN learning_path_config.config_key IS 'Unique identifier for the configuration parameter';
COMMENT ON COLUMN learning_path_config.config_value IS 'The actual value (stored as text, cast based on data_type)';
COMMENT ON COLUMN learning_path_config.data_type IS 'Type of the value for proper parsing';
