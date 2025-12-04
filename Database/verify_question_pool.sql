-- Verification Script for Question Pool Functions

-- 1. Create test data if needed (assuming some exists, but let's check)
DO $$
DECLARE
    v_block_id UUID;
    v_topic_id UUID;
    v_heading_id UUID;
    v_concept_id UUID;
    v_question_id UUID;
    v_session_id UUID;
    v_count INTEGER;
BEGIN
    -- Get or create a test hierarchy
    SELECT id INTO v_block_id FROM blocks LIMIT 1;
    IF v_block_id IS NULL THEN
        INSERT INTO blocks (name, "order") VALUES ('Test Block', 1) RETURNING id INTO v_block_id;
    END IF;

    SELECT id INTO v_topic_id FROM topics WHERE block_id = v_block_id LIMIT 1;
    IF v_topic_id IS NULL THEN
        INSERT INTO topics (block_id, name, "order") VALUES (v_block_id, 'Test Topic', 1) RETURNING id INTO v_topic_id;
    END IF;

    SELECT id INTO v_heading_id FROM headings WHERE topic_id = v_topic_id LIMIT 1;
    IF v_heading_id IS NULL THEN
        INSERT INTO headings (topic_id, name, "order") VALUES (v_topic_id, 'Test Heading', 1) RETURNING id INTO v_heading_id;
    END IF;

    SELECT id INTO v_concept_id FROM concepts WHERE heading_id = v_heading_id LIMIT 1;
    IF v_concept_id IS NULL THEN
        INSERT INTO concepts (heading_id, name, "order") VALUES (v_heading_id, 'Test Concept', 1) RETURNING id INTO v_concept_id;
    END IF;

    -- Ensure we have at least one question
    SELECT id INTO v_question_id FROM questions WHERE concept_id = v_concept_id LIMIT 1;
    IF v_question_id IS NULL THEN
        INSERT INTO questions (concept_id, text, option_a, option_b, option_c, correct_option, explanation, difficulty)
        VALUES (v_concept_id, 'Test Question', 'A', 'B', 'C', 'a', 'Exp', 5)
        RETURNING id INTO v_question_id;
    END IF;

    -- Create a test session
    INSERT INTO lessons (name, "order") VALUES ('Test Lesson', 999) ON CONFLICT DO NOTHING;
    INSERT INTO sessions (lesson_id, name, "order", number_of_questions) 
    SELECT id, 'Test Session', 1, 5 FROM lessons WHERE name = 'Test Lesson' LIMIT 1
    RETURNING id INTO v_session_id;

    -- TEST 1: get_questions_by_criteria (Concept Level)
    SELECT COUNT(*) INTO v_count FROM get_questions_by_criteria(NULL, NULL, NULL, v_concept_id, NULL, NULL);
    RAISE NOTICE 'Test 1 (Concept Level): Found % questions (Expected >= 1)', v_count;

    -- TEST 2: get_questions_by_criteria (Heading Level)
    SELECT COUNT(*) INTO v_count FROM get_questions_by_criteria(NULL, NULL, v_heading_id, NULL, NULL, NULL);
    RAISE NOTICE 'Test 2 (Heading Level): Found % questions (Expected >= 1)', v_count;

    -- TEST 3: populate_session_question_pool
    PERFORM populate_session_question_pool(v_session_id, NULL, NULL, NULL, v_concept_id, NULL, NULL);
    
    SELECT COUNT(*) INTO v_count FROM session_question_pool WHERE session_id = v_session_id;
    RAISE NOTICE 'Test 3 (Populate Pool): Pool has % questions (Expected >= 1)', v_count;

    -- Clean up test session
    DELETE FROM lessons WHERE name = 'Test Lesson';
    -- (Cascades to sessions and pool)

END $$;
