-- ============================================================================
-- MIGRATION: UPDATE SESSIONS SCHEMA
-- ============================================================================
-- Adds new columns to the sessions table for hierarchical filtering and difficulty
-- ============================================================================

-- Add concept_id column
ALTER TABLE sessions 
ADD COLUMN IF NOT EXISTS concept_id UUID REFERENCES concepts(id) ON DELETE SET NULL;

-- Add heading_id column
ALTER TABLE sessions 
ADD COLUMN IF NOT EXISTS heading_id UUID REFERENCES headings(id) ON DELETE SET NULL;

-- Add topic_id column
ALTER TABLE sessions 
ADD COLUMN IF NOT EXISTS topic_id UUID REFERENCES topics(id) ON DELETE SET NULL;

-- Add block_id column
ALTER TABLE sessions 
ADD COLUMN IF NOT EXISTS block_id UUID REFERENCES blocks(id) ON DELETE SET NULL;

-- Add min_difficulty column
ALTER TABLE sessions 
ADD COLUMN IF NOT EXISTS min_difficulty INTEGER CHECK (min_difficulty BETWEEN 1 AND 10);

-- Add max_difficulty column
ALTER TABLE sessions 
ADD COLUMN IF NOT EXISTS max_difficulty INTEGER CHECK (max_difficulty BETWEEN 1 AND 10);

-- Add comments for the new columns
COMMENT ON COLUMN sessions.concept_id IS 'Optional foreign key to concepts for filtering questions';
COMMENT ON COLUMN sessions.heading_id IS 'Optional foreign key to headings for filtering questions';
COMMENT ON COLUMN sessions.topic_id IS 'Optional foreign key to topics for filtering questions';
COMMENT ON COLUMN sessions.block_id IS 'Optional foreign key to blocks for filtering questions';
COMMENT ON COLUMN sessions.min_difficulty IS 'Optional minimum difficulty (1-10) for filtering questions';
COMMENT ON COLUMN sessions.max_difficulty IS 'Optional maximum difficulty (1-10) for filtering questions';
