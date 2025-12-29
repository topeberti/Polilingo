-- ============================================================================
-- FIX EXP GAIN TRIGGER
-- ============================================================================
-- Redefine fn_award_xp_on_correct_answer to remove reference to 'league_points_this_week'
-- in user_gamification_stats, as that column has been dropped.

CREATE OR REPLACE FUNCTION fn_award_xp_on_correct_answer()
RETURNS TRIGGER AS $$
DECLARE
    v_xp_reward INTEGER;
    v_today DATE := (now() AT TIME ZONE 'UTC')::date;
BEGIN
    -- Only award XP if the answer is correct
    IF NEW.correct = true THEN
        -- 1. Get the XP reward amount from configuration
        SELECT config_value::INTEGER INTO v_xp_reward
        FROM learning_path_config
        WHERE config_key = 'xp_per_correct_answer';

        -- Default to 10 if not found
        IF v_xp_reward IS NULL THEN
            v_xp_reward := 10;
        END IF;

        -- 2. Update user_gamification_stats (REMOVED league_points_this_week)
        UPDATE user_gamification_stats
        SET total_xp = total_xp + v_xp_reward,
            updated_at = NOW()
        WHERE user_id = NEW.user_id;

        -- 3. Update daily_activity_log
        -- (The log entry is ensured to exist by fn_log_activity_and_update_streak)
        UPDATE daily_activity_log
        SET xp_earned = xp_earned + v_xp_reward
        WHERE user_id = NEW.user_id AND activity_date = v_today;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
