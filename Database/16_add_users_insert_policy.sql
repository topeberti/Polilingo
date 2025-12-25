-- ============================================================================
-- Migration: Add INSERT policies for users and user_gamification_stats tables
-- ============================================================================
-- This migration adds the missing INSERT policies to allow authenticated users
-- to create their own records in the users and user_gamification_stats tables.
-- ============================================================================

-- Add INSERT policy for users to create their own profile
CREATE POLICY "Users can insert their own profile"
    ON users FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = id);

-- Add INSERT policy for user_gamification_stats
CREATE POLICY "Users can insert their own gamification stats"
    ON user_gamification_stats FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

-- Add comments for documentation
COMMENT ON POLICY "Users can insert their own profile" ON users 
    IS 'Allows authenticated users to create their own profile record';

COMMENT ON POLICY "Users can insert their own gamification stats" ON user_gamification_stats
    IS 'Allows authenticated users to create their own gamification stats record';
