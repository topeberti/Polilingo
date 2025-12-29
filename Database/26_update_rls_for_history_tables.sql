-- ============================================================================
-- UPDATE RLS POLICIES FOR HISTORY TABLES
-- ============================================================================
-- Allow authenticated users to update their own rows in history tables.
-- ============================================================================

-- User Session History
CREATE POLICY "Users can update their own session history"
    ON user_session_history FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id)
    WITH CHECK ((SELECT auth.uid()) = user_id);

-- User Challenges History
CREATE POLICY "Users can update their own challenge history"
    ON user_challenges_history FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id)
    WITH CHECK ((SELECT auth.uid()) = user_id);

-- User Questions History
CREATE POLICY "Users can update their own question history"
    ON user_questions_history FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id)
    WITH CHECK ((SELECT auth.uid()) = user_id);

-- User Lessons History
CREATE POLICY "Users can update their own lesson history"
    ON user_lessons_history FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) = user_id)
    WITH CHECK ((SELECT auth.uid()) = user_id);
