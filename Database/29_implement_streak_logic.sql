-- ============================================================================
-- IMPLEMENT STREAK LOGIC AND DAILY ACTIVITY TRACKING
-- ============================================================================
-- This migration adds automated streak tracking and daily activity logging
-- via PostgreSQL triggers. Activities include:
-- 1. Answering questions (user_questions_history)
-- 2. Completing sessions (user_session_history)
-- 3. Completing lessons (user_lessons_history)
-- 4. Completing challenges (user_challenges_history)
-- ============================================================================

-- 1. Ensure user_challenges_history has a passed column
ALTER TABLE user_challenges_history 
ADD COLUMN IF NOT EXISTS passed BOOLEAN;

COMMENT ON COLUMN user_challenges_history.passed IS 'Whether the challenge attempt met the passing criteria';

-- 2. Create the Trigger Function
CREATE OR REPLACE FUNCTION fn_log_activity_and_update_streak()
RETURNS TRIGGER AS $$
DECLARE
    v_user_id UUID;
    v_last_streak_date DATE;
    v_current_streak INTEGER;
    v_today DATE := (now() AT TIME ZONE 'UTC')::date;
BEGIN
    -- Determine user_id based on the table
    v_user_id := NEW.user_id;

    -- 1. Ensure daily activity log for today exists
    INSERT INTO daily_activity_log (user_id, activity_date)
    VALUES (v_user_id, v_today)
    ON CONFLICT (user_id, activity_date) DO NOTHING;

    -- 2. Update granular metrics in daily_activity_log
    IF TG_TABLE_NAME = 'user_questions_history' THEN
        UPDATE daily_activity_log
        SET questions_answered = questions_answered + 1,
            correct_answers = correct_answers + (CASE WHEN NEW.correct THEN 1 ELSE 0 END)
        WHERE user_id = v_user_id AND activity_date = v_today;
    ELSIF TG_TABLE_NAME = 'user_session_history' AND NEW.status = 'completed' AND NEW.passed = true THEN
        UPDATE daily_activity_log
        SET sessions_completed = sessions_completed + 1
        WHERE user_id = v_user_id AND activity_date = v_today;
    ELSIF TG_TABLE_NAME = 'user_lessons_history' AND NEW.passed = true THEN
        UPDATE daily_activity_log
        SET lessons_completed = lessons_completed + 1
        WHERE user_id = v_user_id AND activity_date = v_today;
    ELSIF TG_TABLE_NAME = 'user_challenges_history' AND NEW.status = 'completed' AND NEW.passed = true THEN
        UPDATE daily_activity_log
        SET sessions_completed = sessions_completed + 1 -- Counting challenges as sessions in activity logs for now
        WHERE user_id = v_user_id AND activity_date = v_today;
    END IF;

    -- 3. Streak Maintenance Logic
    -- Get current streak info from user_gamification_stats
    SELECT last_streak_date, current_streak
    INTO v_last_streak_date, v_current_streak
    FROM user_gamification_stats
    WHERE user_id = v_user_id;

    -- If already maintained today, exit early to avoid redundant updates
    IF v_last_streak_date = v_today THEN
        RETURN NEW;
    END IF;

    -- Calculate new streak value
    IF v_last_streak_date IS NULL OR v_last_streak_date < v_today - 1 THEN
        -- New streak or reset (last activity was more than 1 day ago)
        v_current_streak := 1;
    ELSIF v_last_streak_date = v_today - 1 THEN
        -- Continue streak (last activity was yesterday)
        v_current_streak := COALESCE(v_current_streak, 0) + 1;
    END IF;

    -- Update user gamification stats
    UPDATE user_gamification_stats
    SET current_streak = v_current_streak,
        longest_streak = GREATEST(longest_streak, v_current_streak),
        last_streak_date = v_today,
        updated_at = NOW()
    WHERE user_id = v_user_id;

    -- Update daily activity log to reflect streak is maintained
    UPDATE daily_activity_log
    SET streak_maintained = true
    WHERE user_id = v_user_id AND activity_date = v_today;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Create Triggers

-- Questions: Every answer counts as activity for streak
DROP TRIGGER IF EXISTS tr_log_question_activity ON user_questions_history;
CREATE TRIGGER tr_log_question_activity
AFTER INSERT ON user_questions_history
FOR EACH ROW EXECUTE FUNCTION fn_log_activity_and_update_streak();

-- Sessions: Update stats when completed and passed
DROP TRIGGER IF EXISTS tr_log_session_activity ON user_session_history;
CREATE TRIGGER tr_log_session_activity
AFTER UPDATE OF status, passed ON user_session_history
FOR EACH ROW
WHEN (NEW.status = 'completed' AND NEW.passed = true)
EXECUTE FUNCTION fn_log_activity_and_update_streak();

-- Lessons: Update stats when passed
DROP TRIGGER IF EXISTS tr_log_lesson_activity ON user_lessons_history;
CREATE TRIGGER tr_log_lesson_activity
AFTER INSERT OR UPDATE OF passed ON user_lessons_history
FOR EACH ROW
WHEN (NEW.passed = true)
EXECUTE FUNCTION fn_log_activity_and_update_streak();

-- Challenges: Update stats when completed and passed
DROP TRIGGER IF EXISTS tr_log_challenge_activity ON user_challenges_history;
CREATE TRIGGER tr_log_challenge_activity
AFTER UPDATE OF status, passed ON user_challenges_history
FOR EACH ROW
WHEN (NEW.status = 'completed' AND NEW.passed = true)
EXECUTE FUNCTION fn_log_activity_and_update_streak();
