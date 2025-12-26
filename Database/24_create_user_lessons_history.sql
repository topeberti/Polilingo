-- ============================================================================
-- CREATE USER LESSONS HISTORY TABLE
-- ============================================================================

CREATE TABLE user_lessons_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lesson_id UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Lesson execution
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ
);

-- ============================================================================
-- Row Level Security (RLS)
-- ============================================================================

ALTER TABLE user_lessons_history ENABLE ROW LEVEL SECURITY;

-- Users can view their own lesson history
CREATE POLICY "Users can view their own lesson history"
    ON user_lessons_history FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

-- Users can insert their own lesson history
CREATE POLICY "Users can insert their own lesson history"
    ON user_lessons_history FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

-- Users can update their own lesson history
CREATE POLICY "Users can update their own lesson history"
    ON user_lessons_history FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Content admins and super admins have full access
CREATE POLICY "Admins can manage user lessons history"
    ON user_lessons_history FOR ALL
    TO authenticated
    USING (is_content_admin())
    WITH CHECK (is_content_admin());

-- ============================================================================
-- Indexes for performance
-- ============================================================================

CREATE INDEX idx_user_lessons_history_user_id ON user_lessons_history(user_id);
CREATE INDEX idx_user_lessons_history_lesson_id ON user_lessons_history(lesson_id);
CREATE INDEX idx_user_lessons_history_user_started ON user_lessons_history(user_id, started_at);

-- ============================================================================
-- Trigger to update last_active on lesson completion
-- ============================================================================

CREATE TRIGGER update_last_active_on_lesson AFTER INSERT ON user_lessons_history
    FOR EACH ROW EXECUTE FUNCTION update_user_last_active();

-- ============================================================================
-- Comments for documentation
-- ============================================================================

COMMENT ON TABLE user_lessons_history IS 'Records of user attempts and completions of individual lessons';
COMMENT ON COLUMN user_lessons_history.lesson_id IS 'Reference to the lesson attempted';
COMMENT ON COLUMN user_lessons_history.user_id IS 'Reference to the user who attempted the lesson';
COMMENT ON COLUMN user_lessons_history.started_at IS 'Timestamp when the lesson was started';
COMMENT ON COLUMN user_lessons_history.completed_at IS 'Timestamp when the lesson was finished (NULL if not finished)';
