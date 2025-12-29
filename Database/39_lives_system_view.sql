-- ============================================================================
-- LIVES SYSTEM VIEW
-- ============================================================================
-- Calculates "effective lives" in real-time based on elapsed time
-- ============================================================================

CREATE OR REPLACE VIEW view_user_lives 
WITH (security_invoker = true)
AS
WITH config AS (
    SELECT 
        (SELECT config_value::INTEGER FROM learning_path_config WHERE config_key = 'max_lives') as max_lives,
        (SELECT config_value::INTEGER FROM learning_path_config WHERE config_key = 'life_refill_interval_minutes') as refill_minutes
)
SELECT 
    ugs.user_id,
    ugs.lives as stored_lives,
    ugs.last_life_lost_at,
    LEAST(
        c.max_lives,
        ugs.lives + FLOOR(
            EXTRACT(EPOCH FROM (now() - ugs.last_life_lost_at)) / (c.refill_minutes * 60)
        )::INTEGER
    ) as current_lives,
    CASE 
        WHEN ugs.lives < c.max_lives THEN
            ugs.last_life_lost_at + (
                (FLOOR(EXTRACT(EPOCH FROM (now() - ugs.last_life_lost_at)) / (c.refill_minutes * 60)) + 1) * (c.refill_minutes * 60) 
                * INTERVAL '1 second'
            )
        ELSE NULL
    END as next_life_at
FROM 
    user_gamification_stats ugs,
    config c;

COMMENT ON VIEW view_user_lives IS 'Calculates real-time lives based on the last time a life was lost and the refill interval.';
