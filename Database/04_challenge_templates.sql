-- ============================================================================
-- CHALLENGE TEMPLATES TABLE
-- ============================================================================
-- Defines algorithmic challenge types (lightning rounds, review sessions, etc.)
-- Parameters are configurable by the learning expert from the dashboard
-- ============================================================================

CREATE TABLE challenge_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Basic info
    name TEXT NOT NULL,
    challenge_type TEXT NOT NULL CHECK (challenge_type IN (
        'lightning_round', 
        'review_weak_topics', 
        'review_mistakes', 
        'speed_run', 
        'accuracy_challenge', 
        'spaced_repetition_review'
    )),
    description TEXT NOT NULL,
    icon_url TEXT,
    
    -- Challenge parameters
    time_limit INTEGER, -- seconds, nullable for untimed challenges
    number_of_questions INTEGER NOT NULL CHECK (number_of_questions > 0),
    
    -- Algorithm configuration
    question_selection_algorithm TEXT NOT NULL,
    scoring_formula TEXT NOT NULL DEFAULT 'standard' CHECK (scoring_formula IN (
        'standard',
        'time_bonus',
        'combo_multiplier',
        'no_penalty'
    )),
    
    -- Rewards and restrictions
    xp_multiplier DECIMAL(3,2) NOT NULL DEFAULT 1.0 CHECK (xp_multiplier >= 0),
    unlock_criteria JSONB, -- e.g., {"min_lessons_completed": 5, "min_level": 3}
    cooldown_period INTEGER, -- hours, nullable
    
    -- Display and status
    active BOOLEAN NOT NULL DEFAULT true,
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- Trigger for automatic timestamp updates
-- ============================================================================

CREATE TRIGGER update_challenge_templates_updated_at BEFORE UPDATE ON challenge_templates
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- Comments for documentation
-- ============================================================================

COMMENT ON TABLE challenge_templates IS 'Algorithmic challenge templates with configurable parameters';
COMMENT ON COLUMN challenge_templates.unlock_criteria IS 'JSON conditions to access this challenge, e.g., {"min_lessons_completed": 5}';
COMMENT ON COLUMN challenge_templates.xp_multiplier IS 'Bonus multiplier for XP rewards (e.g., 1.5 for 50% bonus)';
COMMENT ON COLUMN challenge_templates.cooldown_period IS 'Hours before challenge can be replayed';
