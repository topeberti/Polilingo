ALTER TABLE user_gamification_stats
DROP COLUMN IF EXISTS total_lessons_completed,
DROP COLUMN IF EXISTS total_questions_answered,
DROP COLUMN IF EXISTS total_correct_answers,
DROP COLUMN IF EXISTS accuracy_rate,
DROP COLUMN IF EXISTS current_league,
DROP COLUMN IF EXISTS league_position,
DROP COLUMN IF EXISTS league_points_this_week,
DROP COLUMN IF EXISTS lightning_round_high_score,
DROP COLUMN IF EXISTS perfect_streak_record;
