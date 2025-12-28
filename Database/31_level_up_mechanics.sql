-- ============================================================================
-- LEVEL UP MECHANICS
-- ============================================================================
-- Automatically levels up users based on XP gain.
-- Formula: XP_to_reach_next_level = base_xp_per_level * xp_level_multiplier * current_level
-- ============================================================================

-- 1. Insert Configuration Values
INSERT INTO learning_path_config (config_key, config_value, data_type, description, category)
VALUES 
    ('base_xp_per_level', '100', 'integer', 'Base XP needed for the first levels', 'gamification'),
    ('xp_level_multiplier', '1.2', 'integer', 'Multiplier that increases difficulty per level', 'gamification')
ON CONFLICT (config_key) DO NOTHING;

-- 2. Trigger Function for Level-Up Logic
CREATE OR REPLACE FUNCTION fn_check_level_up()
RETURNS TRIGGER AS $$
DECLARE
    v_base_xp INTEGER;
    v_multiplier DECIMAL;
    v_next_threshold INTEGER;
BEGIN
    -- Only run if total_xp has increased
    IF NEW.total_xp <= OLD.total_xp THEN
        RETURN NEW;
    END IF;

    -- Fetch configuration
    SELECT config_value::INTEGER INTO v_base_xp FROM learning_path_config WHERE config_key = 'base_xp_per_level';
    SELECT config_value::DECIMAL INTO v_multiplier FROM learning_path_config WHERE config_key = 'xp_level_multiplier';

    -- Default fallbacks
    v_base_xp := COALESCE(v_base_xp, 100);
    v_multiplier := COALESCE(v_multiplier, 1.2);

    -- Loop to handle multiple level-ups (rare but possible)
    LOOP
        -- Calculate threshold to reach NEXT level
        -- milestone = current_threshold_achieved + (base * multiplier * current_level)
        -- To keep it consistent and stateless (not depending on previous milestones), 
        -- we define xp_to_next_level as the lifetime XP milestone.
        
        if NEW.total_xp >= NEW.xp_to_next_level THEN
            -- Level Up!
            -- Formula: Increment = base_xp + (multiplier * current_level * base_xp)
            NEW.xp_to_next_level := NEW.xp_to_next_level + FLOOR(v_base_xp + (v_multiplier * NEW.current_level * v_base_xp));
            NEW.current_level := NEW.current_level + 1;
        ELSE
            EXIT;
        END IF;
    END LOOP;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Create the Trigger
DROP TRIGGER IF EXISTS tr_check_level_up ON user_gamification_stats;
CREATE TRIGGER tr_check_level_up
BEFORE UPDATE OF total_xp ON user_gamification_stats
FOR EACH ROW
EXECUTE FUNCTION fn_check_level_up();

COMMENT ON FUNCTION fn_check_level_up IS 'Automatically increments current_level and updates xp_to_next_level milestone when total_xp reaches thresholds';
