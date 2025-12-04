-- ============================================================================
-- QUESTIONS TABLE
-- ============================================================================
-- Stores exam questions with three multiple choice options (A, B, C)
-- Each question belongs to a concept in the learning hierarchy
-- ============================================================================

CREATE TABLE questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    concept_id UUID NOT NULL REFERENCES concepts(id) ON DELETE CASCADE,
    
    -- Question content
    text TEXT NOT NULL,
    option_a TEXT NOT NULL,
    option_b TEXT NOT NULL,
    option_c TEXT NOT NULL,
    correct_option CHAR(1) NOT NULL CHECK (correct_option IN ('a', 'b', 'c')),
    explanation TEXT NOT NULL,
    
    -- Metadata
    difficulty INTEGER NOT NULL CHECK (difficulty >= 1 AND difficulty <= 10),
    source TEXT,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'draft', 'archived')),
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- Trigger for automatic timestamp updates
-- ============================================================================

CREATE TRIGGER update_questions_updated_at BEFORE UPDATE ON questions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- Comments for documentation
-- ============================================================================

COMMENT ON TABLE questions IS 'Exam questions with three multiple choice options';
COMMENT ON COLUMN questions.text IS 'The question text';
COMMENT ON COLUMN questions.correct_option IS 'The correct answer: a, b, or c';
COMMENT ON COLUMN questions.explanation IS 'Concise explanation of the correct answer';
COMMENT ON COLUMN questions.difficulty IS 'Question difficulty rating from 1 (easiest) to 10 (hardest)';
COMMENT ON COLUMN questions.source IS 'Source from which the question was extracted';
