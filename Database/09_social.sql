-- ============================================================================
-- SOCIAL FEATURES TABLES
-- ============================================================================
-- Friends, friendly matches, and challenge history
-- ============================================================================

-- Friends Table
-- Social connections between users
CREATE TABLE friends (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id_1 UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    user_id_2 UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Friendship status
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'blocked')),
    requested_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    accepted_at TIMESTAMPTZ,
    
    -- Constraints
    CHECK (user_id_1 != user_id_2),
    -- Ensure no duplicate friendships (regardless of order)
    CHECK (user_id_1 < user_id_2)
);

-- Friendly Matches Table
-- Head-to-head challenges between friends
CREATE TABLE friendly_matches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    challenger_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    opponent_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_id UUID NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
    
    -- Match status
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'declined')),
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    
    -- Results
    challenger_score INTEGER CHECK (challenger_score >= 0 AND challenger_score <= 100),
    opponent_score INTEGER CHECK (opponent_score >= 0 AND opponent_score <= 100),
    winner_id UUID REFERENCES users(id) ON DELETE SET NULL,
    xp_reward INTEGER NOT NULL DEFAULT 0,
    
    -- Constraints
    CHECK (challenger_id != opponent_id)
);

-- Challenge History Table
-- Records for special algorithmic challenges (lightning rounds, etc.)
CREATE TABLE user_challenges_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    challenge_template_id UUID NOT NULL REFERENCES challenge_templates(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Challenge execution
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ
);

-- ============================================================================
-- Trigger to update last_active on challenge completion
-- ============================================================================

CREATE TRIGGER update_last_active_on_challenge AFTER INSERT ON user_challenges_history
    FOR EACH ROW EXECUTE FUNCTION update_user_last_active();

-- ============================================================================
-- Comments for documentation
-- ============================================================================

COMMENT ON TABLE friends IS 'Social connections and friendships between users';
COMMENT ON TABLE friendly_matches IS 'Head-to-head challenges between friends';
COMMENT ON TABLE challenge_history IS 'Records of special algorithmic challenge attempts';

COMMENT ON COLUMN friends.user_id_1 IS 'First user ID (must be less than user_id_2 to prevent duplicates)';
COMMENT ON COLUMN friends.user_id_2 IS 'Second user ID (must be greater than user_id_1 to prevent duplicates)';
COMMENT ON COLUMN friends.requested_by IS 'User who initiated the friend request';
COMMENT ON COLUMN challenge_history.new_personal_best IS 'Whether this attempt beat the user''s previous record for this challenge type';
