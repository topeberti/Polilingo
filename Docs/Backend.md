# Main App backend

Use python.

## Core API Endpoints

### Autentication

#### **Overview**

Develop a backend authentication module integrated with Supabase Auth.
The backend must expose API endpoints for signup, login, logout, session retrieval, OAuth (Google), password reset, and account deletion.
This specification defines required behavior only, without prescribing implementation details.

#### **1. POST /auth/signup**

**Purpose:**
Create a new user account.

**Requirements:**

- Create a new user in Supabase Auth using email and password.
- Trigger Supabase’s built-in email verification process.
- Do not create an authenticated session until email is verified.
- Return a structured success response or a meaningful error.

**Input:**

- Email
- Password

---

#### **2. POST /auth/login**

**Purpose:**
Authenticate an existing user.

**Requirements:**

- Validate credentials using Supabase Auth.
- On success, provide a valid session using Supabase-issued tokens.
- Return basic user information.
- If email is unverified, return a dedicated error.

**Input:**

- Email
- Password

---

#### **2.1 POST /auth/refresh**

**Purpose:**
Refresh a user session using a refresh token.

**Requirements:**

- Accept a valid refresh token.
- Validate the refresh token with Supabase and issue new access/refresh tokens.
- Return the new session data.

**Input:**

- refresh_token

---

#### **3. POST /auth/logout**

**Purpose:**
Terminate the current session.

**Requirements:**

- Invalidate or remove the active Supabase session.
- Clear any session tokens or identifiers.
- Return a success confirmation.

---

#### **4. GET /auth/user**

**Purpose:**
Retrieve the currently authenticated user.

**Requirements:**

- Extract and validate the session.
- Attempt silent session refresh if necessary.
- Return basic user information (id, email, metadata).
- If authentication fails, return an error.

---

#### **5. POST /auth/password/reset/request**

**Purpose:**
Initiate password reset flow.

**Requirements:**

- Accept a user email.
- Trigger Supabase’s built-in password reset email.
- Return a confirmation response.
- Do not reveal whether the email exists (avoid user enumeration).

**Input:**

- Email

---

#### **6. POST /auth/password/reset/confirm**

**Purpose:**
Complete the password reset process.

**Requirements:**

- Accept a reset token/code and a new password.
- Validate the reset token through Supabase.
- Set the new password.
- Return confirmation of successful reset or an error.

**Input:**

- Reset token/code
- New password

---

#### **7. DELETE /auth/user**

**Purpose:**
Delete the authenticated user’s account.

**Requirements:**

- Require a valid authenticated session.
- Permanently delete the user from Supabase Auth.
- Delete associated profile records (if a profile table exists).
- Terminate the session.
- Return a confirmation response.

---

#### **Additional Functional Requirements**

##### **Email Verification**

- User accounts must be verified through Supabase's email verification system before login is allowed.

##### **User Profile Metadata**

- Support optional metadata during signup.
- If additional fields beyond Supabase Auth's built-in fields are needed, they must be stored in a separate profile table keyed by the Supabase user ID.

##### **Error Handling**

All endpoints must return structured error responses containing:

- A machine-readable error code
- A human-readable error message

##### **Rate Limiting**

- Apply rate limiting to high-risk endpoints (signup, login, password reset request).
- Specific thresholds are not mandated — only that rate limiting exists.

##### **Session Management**

- Manage and refresh Supabase-issued access and refresh tokens.
- Sessions must remain secure and must not be exposed in insecure formats.
- Support silent session refresh on `/auth/user`.

---

#### **Non-Functional Requirements**

##### **Security**

- All authentication-related communication must use secure transport.
- Tokens, secrets, or reset codes must never appear in URLs or logs.
- The backend must conform to Supabase Auth security guidelines.

##### **Consistency**

- All API endpoints must follow consistent JSON structures for success and error states.

### User Management

#### **1 POST /users/create**

**Purpose:**
Create a new user and load it in the users table in the public schema.

**Requirements:**

- User must be logged in.
- Fields to fill in the user table:
  - email: Autofilled with the login email.
  - username: Filled by the user, not nullable. Minimum length: 3 characters. Maximum length: 20 characters. Allowed characters: a-z, A-Z, 0-9, _.  No symbols at the start, No consecutive repeated symbols like .. or --. Lowercased before stored. Reserved: admin, teacher, student, guest,support,root,system,moderator,bot,settings,api,login. Offensive word filtering using LDNOOBW list, they can be fetched from <https://github.com/LDNOOBW/naughty-words-js>. Checking that is not already used in the database.
  - full_name: Filled by the user, not nullable
  - profile_picture_url: Filled by the user, nullable
  - preferred_study_time: Filled by the user, nullable
  - daily_goal: Filled by the user, nullable
  - notification_preferences: Filled by the user, nullable

All of this parameters have a default value in the database, so the user can create his user row without passing them in the request.

#### **2 POST /users/update**

**Purpose:**
Edit a the user profile. Each authenticated user has only one row in the users table.

**Requirements:**

- User must be logged in.
- Fields that can be updated in the database
  - full_name: Filled by the user, not nullable
  - profile_picture_url: Filled by the user, nullable
  - preferred_study_time: Filled by the user, nullable
  - daily_goal: Filled by the user, nullable
  - notification_preferences: Filled by the user, nullable

#### **3 DELETE /users/delete**

**Purpose:**
Delete the authenticated user's profile.

**Requirements:**

- User must be logged in.

#### **4 GET /users/profile**

**Purpose:**
Get the authenticated user's profile.

**Requirements:**

- User must be logged in.

**Inputs:**

- user_id: The id of the user.

**Outputs:**

- user: The user profile, which includes information from various tables:
  - users: The user table, with this fields:
    - username
    - email
    - full_name
    - profile_picture_url
    - preferred_study_time
    - daily_goal
  - user_gamification_stats: The gamification stats, with this fields:
    - total_xp
    - current_level
    - xp_to_next_level
    - current_streak
    - longest_streak
    - last_streak_date
    - total_lessons_completed
    - total_questions_answered
    - total_correct_answers
    - total_sessions_completed
    - lives: Stored lives count.
    - last_life_lost_at: Timestamp of the last life lost.
    - current_lives: Real-time calculated lives (taking into account refills).
    - next_life_at: Timestamp for the next life refill (if applicable).

### History

#### **1 GET /history/questions/answered**

**Purpose:**
Returns a list of questions that the user has answered, including the full question data, the number of times the user has answered the question and the number of times the user has answered the question correctly.

**Requirements:**

- User must be logged in.

**Inputs:**

- user_id: The id of the user.

**Outputs:**

- List of jsons of full question data, the number of times the user has answered the question and the number of times the user has answered the question correctly.

#### **2 GET /history/sessions/passed**

**Purpose:**
Returns a list of sessions that the user has completed, including the full session data.

**Requirements:**

- User must be logged in.

**Inputs:**

- user_id: The id of the user.

**Outputs:**

- List of jsons of full session data.

#### **3 GET /history/lessons/passed**

**Purpose:**
Returns a list of lessons that the user has completed, including the full lesson data.

**Requirements:**

- User must be logged in.

**Inputs:**

- user_id: The id of the user.

**Outputs:**

- List of jsons of full lesson data.

#### **4 GET /history/lessons/next**

**Purpose:**
Returns the next lesson that the user has to complete, including the full lesson data.

**Requirements:**

- User must be logged in.

**Inputs:**

- user_id: The id of the user.

**Outputs:**

- Next lesson full data.

#### **5 GET /history/sessions/next**

**Purpose:**
Returns the next session that the user has to complete, including the full session data.

**Requirements:**

- User must be logged in.

**Inputs:**

- user_id: The id of the user.

**Outputs:**

- Next session full data.

#### **6 GET /history/sessions/available**

**Purpose:**
Returns an ordered list of sessions that the user can complete, including the full session data. Be aware that sessions belong to lessons, so the lessons must be returned as well. The list is ordered by two criteria: first by the lesson order and then by the session order. The list of sessions that the user can complete is the list of sessions that the user has already passed and the next session that the user has to complete.

**Requirements:**

- User must be logged in.

**Inputs:**

- user_id: The id of the user.

**Outputs:**

- List of jsons of full session data and list of jsons of full lesson data.

### Learning

#### **1 GET /learning/session/questions**

**Purpose:**
Given a session id, returns the questions that the user has to answer in that session.

To do this, the question_selection_strategy field in the session table is used to select the questions following this steps:

1. Fetch the session using the session id.
2. Fetch the question ids that match the session parameters, concept_id, heading_id, topic_id, block_id, min_difficulty and max_difficulty.
3. Fetch any other questions ids needed depending on the question_selection_strategy.
4. Execute the question_selection_strategy to select the question ids.
5. Fetch the questions using the question ids.
6. Return the questions in the order given by the question_selection_strategy but returning only this fields: id, question, a, b, c.

**Requirements:**

- User must be logged in.

**Inputs:**

- session_id: The id of the session.

**Outputs:**

- List of JSON objects of questions (id, question, a, b, c).

#### **2 POST /learning/session/start**

**Purpose:**
Start a session by creating a new row in user_session_history table setting the session_id, user_id, started_at, and status fields.

**Requirements:**

- User must be logged in.
- **Automatic Abandonment:** Before starting a new session, the system automatically checks for any existing sessions for the current user with `status = 'started'` and marks them as `abandoned`. This ensures only one session is active at a time and handles force-closed apps.
- **Lesson History Tracking:** Starting a session automatically ensures an entry in `user_lessons_history` exists for the parent lesson. If it doesn't exist, it is created.

**Inputs:**

- session_id: The id of the session.

**Outputs:**

- history_id: The id of the created user session history row.
- status: The initial status of the session (usually 'started').
- lives_remaining: The number of lives the user currently has.
- next_life_at: The time when the next life will be refilled.

#### **3 POST /learning/session/finish**

**Purpose:**
Finish a session by updating the user_sessions_history table setting the completed_at field, the passed field, and updating the status to 'completed'.

**Requirements:**

- User must be logged in.
- **Lesson Completion:** When the last session of a lesson (the one with the highest `order`) is finished and passed, the parent lesson in `user_lessons_history` is automatically marked as completed and passed.

**Inputs:**

- history_id: The id of the user session history row.
- passed: Boolean value indicating if the session was passed or not.

**Outputs:**

- None.

#### **4 POST /learning/question/answer**

**Purpose:**
Answer a question given the question id and the answer(a,b or c).

Steps:

1. Fetch the question using the question id.
2. Check if the answer is correct.
3. Update the user_questions_history table using the inputs, setting the answered_at field at the current time and the correct field at true if the answer is correct.
4. Return if the answer is correct and lives status.

**Lives System Enforcement:**

- Before processing the answer, the system checks if the user has `current_lives > 0`.
- If a user has 0 lives, it returns a `403 Forbidden` error.
- If the answer is incorrect, one life is deducted and the `last_life_lost_at` timestamp is updated to the current time.

**Requirements:**

- User must be logged in.

**Inputs:**

- question_id: The id of the question.
- answer: The answer(a,b or c).
- session_id: The id of the session.
- started_at: The time when the question started to fill started_at column in user_questions_history table.
- asked_for_explanation: Boolean value indicating if the user asked for explanation to fill asked_for_explanation column in user_questions_history table.

**Outputs:**

- `correct`: Boolean value indicating if the answer is correct or not.
- `explanation`: The explanation text from the question table.
- `correct_answer`: The correct option (a, b, or c) for the question.
- `xp_gained`: The amount of XP gained for this answer.
- `lives_remaining`: The number of lives remaining after this answer.
- `next_life_at`: The time when the next life will be refilled.

---

### Gamification and Activity Tracking

Note: **Streaks and Daily Activity Tracking** (sessions, lessons, questions) are handled automatically at the database level via PostgreSQL triggers. Any operation that updates the history tables (`user_questions_history`, `user_session_history`, `user_lessons_history`, `user_challenges_history`) will automatically:

1. Update the user's `current_streak` and `longest_streak`.
2. Log the activity in the `daily_activity_log` table.

### Hearts/Lives System

The system implements a life-based progression similar to Duolingo:

- **Max Lives:** Default is 5 (configurable).
- **Refill Interval:** Default is 1 life every 4 hours (configurable).
- **Consumption:** 1 life is lost on every incorrect answer in the `/learning/question/answer` endpoint.
- **Real-time Refill:** Lives are calculated on the fly by measuring the time elapsed since `last_life_lost_at`. This is reflected in `current_lives` across profile and learning responses.
- **Blocking:** Users cannot answer questions if they have 0 lives.

### Recent Fixes

#### **Corrected Session Ordering in Learning Path (2025-12-30)**

- **Issue:** The `available` and `next` session endpoints previously relied solely on `sessions.order`, ignoring lesson sequence. This caused sessions in subsequent lessons to be missed.
- **Fix:** Refactored `get_next_session`, `get_available_sessions`, and `get_next_lesson` to use a composite sort key `(lesson.order, session.order)`. This ensures correct progression across lesson boundaries.
