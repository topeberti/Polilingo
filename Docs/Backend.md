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
