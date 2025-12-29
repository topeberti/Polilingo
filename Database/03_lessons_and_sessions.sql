-- ============================================================================
-- LESSONS AND SESSIONS TABLES
-- ============================================================================
-- Defines the structure of lessons and their component sessions
-- Lessons contain ordered sessions
-- ============================================================================

-- Lessons Table
-- A lesson is a collection of sessions that users complete in order
CREATE TABLE lessons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    "order" INTEGER NOT NULL,
    xp_reward INTEGER NOT NULL DEFAULT 0,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'draft', 'archived')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Lesson Prerequisites Table
-- Defines prerequisite relationships between lessons (many-to-many)
CREATE TABLE lesson_prerequisites (
    lesson_id UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    prerequisite_lesson_id UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    required BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (lesson_id, prerequisite_lesson_id),
    -- Prevent self-referencing prerequisites
    CHECK (lesson_id != prerequisite_lesson_id)
);

-- Sessions Table
-- A session is a set of questions within a lesson
CREATE TABLE sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lesson_id UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    "order" INTEGER NOT NULL,
    number_of_questions INTEGER NOT NULL CHECK (number_of_questions > 0),
    question_selection_strategy TEXT NOT NULL DEFAULT 'random',
    concept_id UUID REFERENCES concepts(id) ON DELETE SET NULL,
    heading_id UUID REFERENCES headings(id) ON DELETE SET NULL,
    topic_id UUID REFERENCES topics(id) ON DELETE SET NULL,
    block_id UUID REFERENCES blocks(id) ON DELETE SET NULL,
    min_difficulty INTEGER CHECK (min_difficulty BETWEEN 1 AND 10),
    max_difficulty INTEGER CHECK (max_difficulty BETWEEN 1 AND 10),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- ============================================================================
-- Triggers for automatic timestamp updates
-- ============================================================================

CREATE TRIGGER update_lessons_updated_at BEFORE UPDATE ON lessons
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_sessions_updated_at BEFORE UPDATE ON sessions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- Comments for documentation
-- ============================================================================

COMMENT ON TABLE lessons IS 'Learning lessons composed of ordered sessions';
COMMENT ON TABLE lesson_prerequisites IS 'Prerequisite relationships between lessons';
COMMENT ON TABLE sessions IS 'Question sessions within lessons';
COMMENT ON TABLE sessions IS 'Question sessions within lessons';

COMMENT ON COLUMN sessions.question_selection_strategy IS 'How questions are sampled: random, weighted_by_difficulty, adaptive, or spaced_repetition';
