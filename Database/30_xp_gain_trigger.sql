-- ============================================================================
-- XP GAIN TRIGGER
-- ============================================================================
-- Automatically awards XP when a user answers a question correctly.
-- Updates:
-- 1. user_gamification_stats (total_xp, league_points_this_week)
-- 2. daily_activity_log (xp_earned)
-- ============================================================================

-- Function to award XP on correct answer
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

        -- 2. Update user_gamification_stats
        UPDATE user_gamification_stats
        SET total_xp = total_xp + v_xp_reward,
            league_points_this_week = league_points_this_week + v_xp_reward,
            updated_at = NOW()
        WHERE user_id = NEW.user_id;

        -- 3. Update daily_activity_log
        -- (The log entry is ensured to exist by fn_log_activity_and_update_streak in 29_implement_streak_logic.sql)
        UPDATE daily_activity_log
        SET xp_earned = xp_earned + v_xp_reward
        WHERE user_id = NEW.user_id AND activity_date = v_today;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create the trigger
DROP TRIGGER IF EXISTS tr_award_xp_on_answer ON user_questions_history;
CREATE TRIGGER tr_award_xp_on_answer
AFTER INSERT ON user_questions_history
FOR EACH ROW
EXECUTE FUNCTION fn_award_xp_on_correct_answer();

COMMENT ON FUNCTION fn_award_xp_on_correct_answer IS 'Awards XP to user when a correct answer is recorded in user_questions_history';
