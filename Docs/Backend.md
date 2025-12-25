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

#### **7. POST /auth/password/reset/request**

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

#### **8. POST /auth/password/reset/confirm**

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

#### **9. DELETE /auth/user**

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

### Syllabus fetching

#### **1 GET /syllabus/blocks/fetch**

**Purpose:**
Fetch any number of blocks from the database by their ids.

**Requirements:**

- User must be logged in.
- Block must exist in the database.

**Inputs**

- Block ids list separated by commas

**Outputs**

- Block objects list

#### **2 GET /syllabus/topics/fetch**

**Purpose:**
Fetch any number of topics from the database by their ids.

**Requirements:**

- User must be logged in.
- Topic must exist in the database.

**Inputs**

- Topic ids list separated by commas

**Outputs**

- Topic objects list

#### **3 GET /syllabus/headings/fetch**

**Purpose:**
Fetch any number of headings from the database by their ids.

**Requirements:**

- User must be logged in.
- Heading must exist in the database.

**Inputs**

- Heading ids list separated by commas

**Outputs**

- Heading objects list

#### **4 GET /syllabus/concepts/fetch**

**Purpose:**
Fetch any number of concepts from the database by their ids.

**Requirements:**

- User must be logged in.
- Concept must exist in the database.

**Inputs**

- Concept ids list separated by commas

**Outputs**

- Concept objects list

#### **5 GET /syllabus/questions/fetch**

**Purpose:**
Fetch any number of questions from the database by their ids.

**Requirements:**

- User must be logged in.
- Question must exist in the database.

**Inputs**

- Question ids list separated by commas

**Outputs**

- Question objects list

#### **6  GET /syllabus/blocks/query**

**Purpose:**
Returns a list of blocks ids that match the given query.

The columns used to filter the query will be:

name: The query can ask for the blocks that contain or that have exactly the same name.
description: The query can ask for the blocks that contain or that have exactly the same description.
order: The query can ask for the blocks that have exactly the same order, blocks that have an order greater than the one asked for or blocks that have an order less than the one asked for.
status: The query always asks for active blocks, the request does not let the user ask for inactive blocks.

**Requirements:**

- User must be logged in.

**Inputs**

- name_text: The text to search for in the name.
- name_exact: Boolean that indicates if the name must be exactly the same as the one asked for.
- description_text: The text to search for in the description.
- description_exact: Boolean that indicates if the description must be exactly the same as the one asked for.
- order_number: The order to search for.
- order_greater: Boolean that indicates if the order must be greater than the one asked for.
- order_less: Boolean that indicates if the order must be less than the one asked for.

**Outputs**

- Block ids list

#### **7 GET /syllabus/topics/query**

**Purpose:**
Returns a list of topics ids that match the given query.

The columns used to filter the query will be:

block_ids: The query can ask for the topics that have exactly the same block_ids from a list of block ids separated by commas.
name: The query can ask for the topics that contain or that have exactly the same name.
description: The query can ask for the topics that contain or that have exactly the same description.
order: The query can ask for the topics that have exactly the same order, topics that have an order greater than the one asked for or topics that have an order less than the one asked for.
status: The query always asks for active topics, the request does not let the user ask for inactive topics.

**Requirements:**

- User must be logged in.

**Inputs**

- block_ids: The list of block ids separated by commas.
- name_text: The text to search for in the name.
- name_exact: Boolean that indicates if the name must be exactly the same as the one asked for.
- description_text: The text to search for in the description.
- description_exact: Boolean that indicates if the description must be exactly the same as the one asked for.
- order_number: The order to search for.
- order_greater: Boolean that indicates if the order must be greater than the one asked for.
- order_less: Boolean that indicates if the order must be less than the one asked for.

**Outputs**

- Topic ids list

#### **8 GET /syllabus/headings/query**

**Purpose:**
Returns a list of headings ids that match the given query.

The columns used to filter the query will be:

topic_ids: The query can ask for the headings that have exactly the same topic_ids from a list of topic ids separated by commas.
name: The query can ask for the headings that contain or that have exactly the same name.
description: The query can ask for the headings that contain or that have exactly the same description.
order: The query can ask for the headings that have exactly the same order, headings that have an order greater than the one asked for or headings that have an order less than the one asked for.
status: The query always asks for active headings, the request does not let the user ask for inactive headings.

**Requirements:**

- User must be logged in.

**Inputs**

- topic_ids: The list of topic ids separated by commas.
- name_text: The text to search for in the name.
- name_exact: Boolean that indicates if the name must be exactly the same as the one asked for.
- description_text: The text to search for in the description.
- description_exact: Boolean that indicates if the description must be exactly the same as the one asked for.
- order_number: The order to search for.
- order_greater: Boolean that indicates if the order must be greater than the one asked for.
- order_less: Boolean that indicates if the order must be less than the one asked for.

**Outputs**

- Heading ids list

#### **9 GET /syllabus/concepts/query**

**Purpose:**
Returns a list of concepts ids that match the given query.

The columns used to filter the query will be:

heading_ids: The query can ask for the concepts that have exactly the same heading_ids from a list of heading ids separated by commas.
name: The query can ask for the concepts that contain or that have exactly the same name.
description: The query can ask for the concepts that contain or that have exactly the same description.
order: The query can ask for the concepts that have exactly the same order, concepts that have an order greater than the one asked for or concepts that have an order less than the one asked for.
status: The query always asks for active concepts, the request does not let the user ask for inactive concepts.

**Requirements:**

- User must be logged in.

**Inputs**

- heading_ids: The list of heading ids separated by commas.
- name_text: The text to search for in the name.
- name_exact: Boolean that indicates if the name must be exactly the same as the one asked for.
- description_text: The text to search for in the description.
- description_exact: Boolean that indicates if the description must be exactly the same as the one asked for.
- order_number: The order to search for.
- order_greater: Boolean that indicates if the order must be greater than the one asked for.
- order_less: Boolean that indicates if the order must be less than the one asked for.

**Outputs**

- Concept ids list

#### **10 GET /syllabus/questions/query**

**Purpose:**
Returns a list of questions ids that match the given query.

The columns used to filter the query will be:

concept_ids: The query can ask for the questions that have exactly the same concept_ids from a list of concept ids separated by commas.
difficulty: The query can ask for the questions that have exactly the same difficulty.
difficulty_greater: The query can ask for the questions that have a difficulty greater than the one asked for.
difficulty_less: The query can ask for the questions that have a difficulty less than the one asked for.
status: The query always asks for active questions, the request does not let the user ask for inactive questions.

**Requirements:**

- User must be logged in.

**Inputs**

- concept_ids: The list of concept ids separated by commas.
- difficulty_number: The difficulty to search for.
- difficulty_greater: Boolean that indicates if the difficulty must be greater than the one asked for.
- difficulty_less: Boolean that indicates if the difficulty must be less than the one asked for.

**Outputs**

- Question ids list

### Learning Path fetching

#### **1 GET /learning-path/lessons/fetch**

**Purpose:**
Returns a list of lessons given a list of lesson ids.

**Requirements:**

- User must be logged in.

**Inputs**

- lesson_ids: The list of lesson ids separated by commas.

**Outputs**

- Lessons list

#### **2 GET /learning-path/sessions/fetch**

**Purpose:**
Returns a list of sessions given a list of session ids.

**Requirements:**

- User must be logged in.

**Inputs**

- session_ids: The list of session ids separated by commas.

**Outputs**

- Sessions list

#### **3 GET /learning-path/lessons/query**

**Purpose:**
Returns a list of lessons ids that match the given query.

The columns used to filter the query will be:

name: The query can ask for the lessons that contain or that have exactly the same name.
order: The query can ask for the lessons that have exactly the same order, lessons that have an order greater than the one asked for or lessons that have an order less than the one asked for.
xp_reward: The query can ask for the lessons that have exactly the same xp_reward, lessons that have an xp_reward greater than the one asked for or lessons that have an xp_reward less than the one asked for.
status: The query always asks for active lessons, the request does not let the user ask for inactive lessons.

**Requirements:**

- User must be logged in.

**Inputs**

- name_text: The text to search for in the name.
- name_exact: Boolean that indicates if the name must be exactly the same as the one asked for.
- order_number: The order to search for.
- order_greater: Boolean that indicates if the order must be greater than the one asked for.
- order_less: Boolean that indicates if the order must be less than the one asked for.
- xp_reward_number: The xp_reward to search for.
- xp_reward_greater: Boolean that indicates if the xp_reward must be greater than the one asked for.
- xp_reward_less: Boolean that indicates if the xp_reward must be less than the one asked for.

**Outputs**

- Lesson ids list

#### **4 GET /learning-path/sessions/query**

**Purpose:**
Returns a list of sessions ids that match the given query.

The columns used to filter the query will be:

lesson_ids: The query can ask for the sessions that have exactly the same lesson_ids from a list of lesson ids separated by commas.
name: The query can ask for the sessions that contain or that have exactly the same name.
order: The query can ask for the sessions that have exactly the same order, sessions that have an order greater than the one asked for or sessions that have an order less than the one asked for.
number of questions: The query can ask for the sessions that have exactly the same number of questions, sessions that have a number of questions greater than the one asked for or sessions that have a number of questions less than the one asked for.
question selection strategy: The query can ask for the sessions that have exactly the same question selection strategy.
concept_ids: The query can ask for the sessions that have exactly the same concept_ids from a list of concept ids separated by commas.
heading_ids: The query can ask for the sessions that have exactly the same heading_ids from a list of heading ids separated by commas.
topic_ids: The query can ask for the sessions that have exactly the same topic_ids from a list of topic ids separated by commas.
block_ids: The query can ask for the sessions that have exactly the same block_ids from a list of block ids separated by commas.
minimum difficulty: The query can ask for the sessions that have a minimum difficulty.
maximum difficulty: The query can ask for the sessions that have a maximum difficulty.

**Requirements:**

- User must be logged in.

**Inputs**

- lesson_ids: The list of lesson ids separated by commas.
- name_text: The text to search for in the name.
- name_exact: Boolean that indicates if the name must be exactly the same as the one asked for.
- order_number: The order to search for.
- order_greater: Boolean that indicates if the order must be greater than the one asked for.
- order_less: Boolean that indicates if the order must be less than the one asked for.
- number_of_questions_number: The number of questions to search for.
- number_of_questions_greater: Boolean that indicates if the number of questions must be greater than the one asked for.
- number_of_questions_less: Boolean that indicates if the number of questions must be less than the one asked for.
- question_selection_strategy: The question selection strategy to search for.
- concept_ids: The list of concept ids separated by commas.
- heading_ids: The list of heading ids separated by commas.
- topic_ids: The list of topic ids separated by commas.
- block_ids: The list of block ids separated by commas.
- minimum_difficulty_number: The minimum difficulty to search for.
- maximum_difficulty_number: The maximum difficulty to search for.

**Outputs**

- Session ids list

### History

#### **1 GET /history/questions/answered**

**Purpose:**
Returns a list of questions ids that the user has answered, the number of times the user has answered the question and the number of times the user has answered the question correctly. Therefore queries the user_questions_history table where the user_id is the user that is logged in, then counts the number of rows for each question id and the number of rows where the correct column is true for each question id.

**Requirements:**

- User must be logged in.

**Inputs:**

- user_id: The id of the user.

**Outputs:**

- List of jsons of question ids, the number of times the user has answered the question and the number of times the user has answered the question correctly.

#### **2 GET /history/sessions/passed**

**Purpose:**
Returns a list of sessions ids that the user has completed. Therefore queries the user_session_history table where the user_id is the user that is logged in and filters the rows where the passed column is true.

**Requirements:**

- User must be logged in.

**Inputs:**

- user_id: The id of the user.

**Outputs:**

- List of jsons of session ids.

#### **3 GET /history/lessons/passed**

**Purpose:**
Returns a list of lessons ids that the user has completed. Therefore queries the user_lessons_history table where the user_id is the user that is logged in and filters the rows where the passed column is true.

**Requirements:**

- User must be logged in.

**Inputs:**

- user_id: The id of the user.

**Outputs:**

- List of jsons of lesson ids.

#### **4 GET /history/lessons/next**

**Purpose:**
Returns the next lesson id that the user has to complete. Therefore queries the user_lessons_history table where the user_id is the user that is logged in and filters the rows where the passed column is True. Then queries the lessons table where the id is the lesson_id of the row where the passed column is True. And finally queries the lessons table where the order is greater than the order of the lesson_id of the row where the passed column is True and returns the lesson id that has the lowest order number to effectively return the next lesson id. If the user has not completed any lesson, returns the lesson id that has the lowest order number.

**Requirements:**

- User must be logged in.

**Inputs:**

- user_id: The id of the user.

**Outputs:**

- Next lesson id

#### **5 GET /history/sessions/next**

**Purpose:**
Returns the next session id that the user has to complete. Therefore queries the user_sessions_history table where the user_id is the user that is logged in and filters the rows where the passed column is True. Then queries the sessions table where the id is the session_id of the row where the passed column is True. And finally queries the sessions table where the order is greater than the order of the session_id of the row where the passed column is True and returns the session id that has the lowest order number to effectively return the next session id. If the user has not completed any session, returns the session id that has the lowest order number.

**Requirements:**

- User must be logged in.

**Inputs:**

- user_id: The id of the user.

**Outputs:**

- Next session id
