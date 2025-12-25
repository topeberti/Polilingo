-- ============================================================================
-- CREATE USER QUESTIONS HISTORY TABLE
-- ============================================================================
-- Stores relationship between user, question, and session
-- ============================================================================

CREATE TABLE IF NOT EXISTS user_questions_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    user_session_history_id UUID NOT NULL REFERENCES user_session_history(id) ON DELETE CASCADE,
    question_id UUID NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
    
    -- Interaction details
    started_at TIMESTAMPTZ NOT NULL,
    answered_at TIMESTAMPTZ,
    asked_for_explanation BOOLEAN NOT NULL DEFAULT false,
    answer TEXT CHECK (answer IN ('a', 'b', 'c')),
    correct BOOLEAN,
    
    -- Creation timestamp
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Note: RLS policies and indexes will be added in separate files/steps, 
-- or typically included in the main schema definition files for this project structure.
-- This migration ensures the table exists.

-- Enable RLS immediately to be safe, though policies are defined in 12_security_policies.sql
ALTER TABLE user_questions_history ENABLE ROW LEVEL SECURITY;
