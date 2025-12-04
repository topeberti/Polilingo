-- ============================================================================
-- POLILINGO DATABASE SETUP - MASTER FILE
-- ============================================================================
-- This file executes all schema creation scripts in the correct order
-- to set up the complete Polilingo database in Supabase.
--
-- Usage: Run this file in Supabase SQL Editor to create the entire database
-- ============================================================================

-- Phase 1: Learning Path Structure
\i 01_learning_path_hierarchy.sql
\i 02_questions.sql
\i 03_lessons_and_sessions.sql
\i 04_challenge_templates.sql
\i 05_learning_path_config.sql

-- Phase 2: User System
\i 06_users.sql

-- Phase 3: User Progress
\i 07_user_progress.sql

-- Phase 4: Gamification
\i 08_gamification.sql

-- Phase 5: Social Features
\i 09_social.sql

-- Phase 6: Other Tables
\i 10_notifications_and_config.sql

-- Phase 7: Performance Optimization
\i 11_indexes.sql


-- Phase 8: Security
\i 12_security_policies.sql

-- Phase 9: Question Pool Functions
\i 14_question_pool_functions.sql

-- Phase 10: Admin Setup (Optional - Run manually when needed)
-- \i 13_admin_setup.sql

-- ============================================================================
-- Setup complete!
-- To promote a user to content admin, run 13_admin_setup.sql manually
-- ============================================================================
