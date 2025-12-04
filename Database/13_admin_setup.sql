-- ============================================================================
-- ADMIN USER SETUP SCRIPT
-- ============================================================================
-- This script helps promote users to content_admin role
-- Run this AFTER a user has signed up through Supabase Auth
-- ============================================================================

-- ============================================================================
-- STEP 1: Verify the user exists in the auth.users table
-- ============================================================================
-- Run this query to find the user's UUID
-- Replace 'rober261105@gmail.com' with the actual email

SELECT id, email FROM auth.users WHERE email = 'rober261105@gmail.com';

-- ============================================================================
-- STEP 2: Promote user to content_admin role
-- ============================================================================
-- Once you have confirmed the user exists, run this to promote them
-- Replace the email with the actual admin email

UPDATE users 
SET role = 'content_admin' 
WHERE email = 'rober261105@gmail.com';

-- ============================================================================
-- STEP 3: Verify the role was updated
-- ============================================================================
-- Run this to confirm the user now has content_admin role

SELECT id, username, email, role, account_status 
FROM users 
WHERE email = 'rober261105@gmail.com';

-- ============================================================================
-- Additional Admin Management Queries
-- ============================================================================

-- List all admin users
SELECT id, username, email, role, date_joined, last_active
FROM users 
WHERE role IN ('content_admin', 'super_admin')
ORDER BY date_joined;

-- Promote another user to content_admin (template)
-- UPDATE users SET role = 'content_admin' WHERE email = 'newadmin@example.com';

-- Demote user back to regular user (template)
-- UPDATE users SET role = 'user' WHERE email = 'user@example.com';

-- Promote user to super_admin (template)
-- UPDATE users SET role = 'super_admin' WHERE email = 'superadmin@example.com';

-- ============================================================================
-- IMPORTANT NOTES
-- ============================================================================
-- 1. Users must first sign up through Supabase Auth (creates auth.users entry)
-- 2. The signup process should also create a corresponding entry in the users table
-- 3. Only then can you promote them using this script
-- 4. Content admins can manage all learning content but NOT user data
-- 5. Super admins have full access to everything (use sparingly)
-- ============================================================================
