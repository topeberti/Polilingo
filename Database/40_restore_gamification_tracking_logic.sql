-- ============================================================================
-- RESTORE GAMIFICATION TRACKING LOGIC & ADD SESSION TRACKING
-- ============================================================================
-- 1. Add missing column
ALTER TABLE user_gamification_stats
ADD COLUMN IF NOT EXISTS total_sessions_completed INTEGER NOT NULL DEFAULT 0;

-- 2. Redefine trigger function to track all lifetime stats
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

    -- 2. Update granular metrics in daily_activity_log AND user_gamification_stats
    IF TG_TABLE_NAME = 'user_questions_history' THEN
        -- Update daily log
        UPDATE daily_activity_log
        SET questions_answered = questions_answered + 1,
            correct_answers = correct_answers + (CASE WHEN NEW.correct THEN 1 ELSE 0 END)
        WHERE user_id = v_user_id AND activity_date = v_today;

        -- Update lifetime stats in user_gamification_stats
        UPDATE user_gamification_stats
        SET total_questions_answered = total_questions_answered + 1,
            total_correct_answers = total_correct_answers + (CASE WHEN NEW.correct THEN 1 ELSE 0 END)
        WHERE user_id = v_user_id;

    ELSIF TG_TABLE_NAME = 'user_session_history' THEN
        -- Safely check status and passed
        IF NEW.status = 'completed' AND NEW.passed = true THEN
            -- Only process if it's a new pass (Update to passed/completed)
            -- Note: For session history, usually it starts as 'started' and then becomes 'completed'
            IF (TG_OP = 'INSERT') OR (TG_OP = 'UPDATE' AND (OLD.status IS DISTINCT FROM 'completed' OR OLD.passed IS DISTINCT FROM true)) THEN
                UPDATE daily_activity_log
                SET sessions_completed = sessions_completed + 1
                WHERE user_id = v_user_id AND activity_date = v_today;

                UPDATE user_gamification_stats
                SET total_sessions_completed = total_sessions_completed + 1
                WHERE user_id = v_user_id;
            END IF;
        END IF;

    ELSIF TG_TABLE_NAME = 'user_lessons_history' THEN
        -- Safely check passed
        IF NEW.passed = true THEN
            -- Only process if it's a new pass
            IF (TG_OP = 'INSERT') OR (TG_OP = 'UPDATE' AND OLD.passed IS DISTINCT FROM true) THEN
                UPDATE daily_activity_log
                SET lessons_completed = lessons_completed + 1
                WHERE user_id = v_user_id AND activity_date = v_today;

                UPDATE user_gamification_stats
                SET total_lessons_completed = total_lessons_completed + 1
                WHERE user_id = v_user_id;
            END IF;
        END IF;

    ELSIF TG_TABLE_NAME = 'user_challenges_history' THEN
        -- Safely check status and passed
        IF NEW.status = 'completed' AND NEW.passed = true THEN
             IF (TG_OP = 'INSERT') OR (TG_OP = 'UPDATE' AND (OLD.status IS DISTINCT FROM 'completed' OR OLD.passed IS DISTINCT FROM true)) THEN
                UPDATE daily_activity_log
                SET sessions_completed = sessions_completed + 1
                WHERE user_id = v_user_id AND activity_date = v_today;

                UPDATE user_gamification_stats
                SET total_sessions_completed = total_sessions_completed + 1
                WHERE user_id = v_user_id;
            END IF;
        END IF;
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
        -- New streak or reset
        v_current_streak := 1;
    ELSIF v_last_streak_date = v_today - 1 THEN
        -- Continue streak
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
