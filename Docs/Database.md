## Database

### Learning path tables

The database will be created in supabase for a clean and fast setup SQL.

The syllabus is organized by this hierarchy:

1) Syllabus

    a)  Blocks

        i)  Topics

            (1) Headings

                (a) Concepts

                    (i) Questions

Each question belongs to a concept, that belongs to a heading, that
belongs to a topic, that belongs to a block.

#### Blocks, topcis, headings and concepts

The information needed for blocks, topics, headings and concepts is:

- ID

- Name

- Foreign key to their parent

- Description: nullable

- Order/Position: An integer to define the sequence in which blocks,
  topics, headings, and concepts appear. This is critical since your
  hierarchy is ordered and the learning path needs to present content in
  a specific sequence.

- Status/Visibility: A boolean or enum field (e.g., active, draft,
  archived) to control whether content is visible to users. This allows
  the learning expert to prepare content without publishing it
  immediately.

A table for each with this columns is needed.

#### Questions

> The information needed for questions is:

- Question ID

- Concept ID: Foreign key to Concepts - Which concept this question
  belongs to

- Text: Question text

- Option A

- Option B

- Option C: These exams only have three possible answers\" (clearer
  phrasing)

- Correct option: Has to be a, b or c

- Explanation: A concise and easy explanation to understand the answer

- Difficulty: An integer number that will represent the difficulty of
  the question

- Source: From what source was the question extracted.

#### Lessons

For the lessons, the learning expert still has to design their
requirements but for now on they need this information:

- Name

- Order/Position: An integer defining the lesson sequence in the
  learning path.

- XP reward: Integer - Gamification element defining experience points
  earned upon completion.

- Status: enum (active, draft, archived) - Allows the learning expert to
  prepare lessons without making them live.

#### Lesson Prerequisites

Defines prerequisite relationships between lessons:

- Lesson ID: Foreign key to Lessons - The lesson that has a prerequisite

- Prerequisite Lesson ID: Foreign key to Lessons - The lesson that must
  be completed first

- Required: Boolean - Whether this prerequisite is mandatory or just
  recommended

- Created at: Timestamp

- Primary key: Composite of (Lesson ID, Prerequisite Lesson ID)

This enables complex skill trees (a lesson can have multiple
prerequisites, and can be a prerequisite for multiple lessons).

#### Sessions

For the sessions, the learning expert still has to design their
requirements but for now on they need this information:

- Name

- Foreign key to the lesson it belongs

- Number of questions: Number of questions to be sampled from the pool

- Order/Position: An integer defining the session order within the
  lesson.

- Question selection strategy: enum (random, weighted_by_difficulty,
  adaptive, spaced_repetition) - Defines how questions are sampled from
  the pool. Even if you start with \"random\", this parameter lets the
  learning expert experiment with different strategies later.

Note: Sessions need to track which specific questions were shown to each
user and their responses. This requires a many-to-many relationship
table between users, sessions, and questions.

This data is essential for the \"tailored sets of lessons based on the
users weak and strong points\" mentioned in your introduction and for
spaced repetition algorithms.

#### Session Question Pool

Links sessions to their available questions:

- Session ID: Foreign key to Sessions

- Question ID: Foreign key to Questions

- Weight: Integer - nullable, for weighted_by_difficulty selection

- Added at: Timestamp

- Active: Boolean - Whether this question is currently in the pool

- Primary key: Composite of (Session ID, Question ID)

#### Learning path

For the learning path global configuration, the following parameters are
needed:

- Retry penalty: Boolean or XP amount - Whether retrying a session
  affects XP rewards

- Spaced repetition intervals: Array of integers (days) - Defines when
  questions should be re-presented

These parameters can be edited by the learning expert from the dashboard
without changing the app code.

#### Algorithmic challenges

For the algorithmic challenges available in the app (lightning rounds,
review sessions, etc.):

- Challenge Template ID: Primary key

- Challenge name: Display name (e.g., \"Lightning Round\", \"Review Weak
  Points\", \"Perfect Streak Challenge\")

- Challenge type: enum (lightning_round, review_weak_topics,
  review_mistakes, speed_run, accuracy_challenge,
  spaced_repetition_review) - Category

- Description: What this challenge does and when it\'s available

- Icon URL: Challenge icon for UI

- Time limit: Integer (seconds) - nullable for untimed challenges

- Number of questions: Integer - How many questions to serve

- Question selection algorithm: enum (random, weakest_topics,
  recent_mistakes, spaced_repetition, difficulty_ascending,
  high_frequency) - How questions are chosen

- Scoring formula: enum (standard, time_bonus, combo_multiplier,
  no_penalty) - How score is calculated

- XP multiplier: Float - Bonus multiplier for XP rewards (e.g., 1.5x for
  lightning rounds)

- Unlock criteria: JSON - nullable, conditions to access this challenge
  (e.g., {\"min_lessons_completed\": 5} or {\"min_level\": 3})

- Cooldown period: Integer (hours) - nullable, time before challenge can
  be replayed

- Active: Boolean - Whether this challenge is currently available

- Order/Position: Integer - Display order in challenges menu

### App logic tables

Tables that will be needed for the app functionality like users
profiles, history, gamification mechanics, social features, and
challenges.

#### Users

The core user profile information:

- User ID: Primary key, unique identifier

- Username: Unique, for display in leaderboards and social features

- Email: Unique, for authentication

- Password hash: Encrypted password storage

- Full name: nullable - Optional real name

- Profile picture URL: nullable - Avatar/photo

- Date joined: Timestamp of account creation

- Last active: Timestamp of last app usage

- Preferred study time: nullable - Time of day for notification
  reminders (e.g., \"18:00\")

- Daily goal: Integer - Target XP or lessons per day (default:
  configurable globally)

- Notification preferences: JSON or boolean fields - Controls for streak
  reminders, friend activity, league updates

- Account status: enum (active, suspended, deleted) - Account state

#### User progress

Tracks individual user advancement through the learning path:

- User ID: Foreign key to Users

- Lesson ID: Foreign key to Lessons

- Status: enum (not_started, in_progress, completed, locked) - Current
  lesson state

- Current session: Integer - Which session within the lesson the user is
  on

- Completion percentage: Integer (0-100) - Progress within the lesson

- Started at: Timestamp - nullable, when user first opened this lesson

- Completed at: Timestamp - nullable, when user finished this lesson

- XP earned: Integer - XP gained from this lesson

- Stars earned: Integer (0-3) - Performance rating for this lesson

- Best score: Integer (percentage) - Highest score achieved across all
  attempts

- Attempts: Integer - Number of times lesson was attempted

#### User Session History

Detailed record of each session attempt (this is the many-to-many table
mentioned in Learning path section):

- History ID: Primary key

- User ID: Foreign key to Users

- Session ID: Foreign key to Sessions

- Passed: Boolean - Whether user met minimum passing score

- Status: enum (started, completed, abandoned) - Current state of the session. Defaults to 'started'.

#### User Questions History

Detailed record of each question answered within a session or challenge:

- ID: Primary key

- User ID: Foreign key to Users

- User Session History ID: Foreign key to User Session History - nullable (one of this or Challenge History ID is required)

- User Challenges History ID: Foreign key to User Challenges History - nullable

- Question ID: Foreign key to Questions

- Started at: Timestamp

- Answered at: Timestamp - nullable

- Asked for explanation: Boolean

- Answer: enum (a, b, c) - User response

- Correct: Boolean

#### User Gamification Stats

Tracks gamification metrics per user:

- User ID: Foreign key to Users (Primary key)

- Total XP: Integer - Lifetime experience points

- Current level: Integer - Calculated from total XP

- XP to next level: Integer - Points needed to level up

- Streak freeze count: Integer - Number of streak freezes available
  (power-up that protects streak)

- Total lessons completed: Integer

- Total questions answered: Integer

- Total correct answers: Integer

- Accuracy rate: Float (percentage) - Overall correctness

- Current league: enum (bronze, silver, gold, diamond, obsidian) -
  League tier

- League position: Integer - Rank within current league

- League points this week: Integer - XP earned in current week (resets
  weekly)

- Lightning round high score: Integer - Best performance in lightning
  challenge

- Perfect streak record: Integer - Most consecutive correct answers
  without a mistake

**Note on Streaks:** Streak tracking is automated via database triggers. Any user activity (answering questions, passing sessions/lessons) will automatically update the `current_streak`, `longest_streak`, and `last_streak_date`.

#### Achievements/Badges

Defines available achievements in the system:

- Achievement ID: Primary key

- Name: Achievement title (e.g., \"First Steps\", \"Week Warrior\",
  \"Perfect 10\")

- Description: What the achievement represents

- Icon URL: Badge image

- Type: enum (streak, completion, accuracy, challenge, social,
  special) - Category

- Unlock criteria: JSON - Conditions to earn this badge (e.g.,
  {\"streak_days\": 7} or {\"lessons_completed\": 10})

- XP reward: Integer - Bonus XP for unlocking

- Rarity: enum (common, rare, epic, legendary) - Badge tier

- Order/Position: Integer - Display order in achievement list

- Active: Boolean - Whether this achievement is currently earnable

#### User Achievements

Tracks which achievements each user has unlocked:

- User ID: Foreign key to Users

- Achievement ID: Foreign key to Achievements

- Unlocked at: Timestamp

- Shown notification: Boolean - Whether user has seen the unlock
  notification

#### Leagues

Weekly competitive leagues:

- League ID: Primary key

- League name: enum (bronze, silver, gold, diamond, obsidian)

- Start date: Timestamp - When this league week began

- End date: Timestamp - When this league week ends

- Promotion threshold: Integer - Minimum rank to move up a league

- Demotion threshold: Integer - Maximum rank to avoid moving down

- Active: Boolean - Whether this is the current active league period

#### League Participants

Tracks users in each league period:

- Participant ID: Primary key

- User ID: Foreign key to Users

- League ID: Foreign key to Leagues

- XP earned this week: Integer - Points accumulated during league period

- Current rank: Integer - Position in league leaderboard

- Previous rank: Integer - Rank in last update (for showing movement)

- Promoted: Boolean - nullable, set at end of week

- Demoted: Boolean - nullable, set at end of week

#### Friends

Social connections between users:

- Friendship ID: Primary key

- User ID 1: Foreign key to Users

- User ID 2: Foreign key to Users

- Status: enum (pending, accepted, blocked) - Friendship state

- Requested by: Foreign key to Users - Who initiated the friend request

- Created at: Timestamp

- Accepted at: Timestamp -- nullable

#### Friendly Matches

Head-to-head challenges between friends:

- Match ID: Primary key

- Challenger ID: Foreign key to Users

- Opponent ID: Foreign key to Users

- Session ID: Foreign key to Sessions - Which session to compete on

- Status: enum (pending, in_progress, completed, declined) - Match state

- Created at: Timestamp

- Started at: Timestamp - nullable

- Completed at: Timestamp - nullable

- Challenger score: Integer - nullable until completed

- Opponent score: Integer - nullable until completed

- Winner ID: Foreign key to Users - nullable until completed

- XP reward: Integer - Bonus XP for winner

#### User Challenges History

Records for special algorithmic challenges (lightning rounds, perfect
streaks, etc.):

- Challenge ID: Primary key

- Challenge Template ID: Foreign key to Challenge Templates - Links to
  which challenge type was played

- User ID: Foreign key to Users

- Started at: Timestamp

- Completed at: Timestamp - nullable

- Status: enum (started, completed, abandoned) - Current state of the challenge attempt.

#### User Lessons History

Records for individual lesson attempts and completions:

- History ID: Primary key
- Lesson ID: Foreign key to Lessons
- User ID: Foreign key to Users
- Started at: Timestamp
- Completed at: Timestamp - nullable
- Passed: Boolean - Whether user met minimum passing score

#### Notifications

System and social notifications for users:

- Notification ID: Primary key

- User ID: Foreign key to Users

- Type: enum (streak_reminder, friend_request, league_update,
  achievement_unlock, match_challenge, level_up) - Notification category

- Title: Notification heading

- Message: Notification body text

- Related entity ID: Integer - nullable, reference to related item
  (e.g., friend request ID, match ID)

- Related entity type: enum - nullable, type of related entity

- Created at: Timestamp

- Read at: Timestamp - nullable

- Action URL: nullable - Deep link within app (e.g.,
  \"app://matches/123\")

#### Daily Activity Log

Tracks daily user engagement for streak calculation and analytics:

- Log ID: Primary key

- User ID: Foreign key to Users

- Activity date: Date

- Sessions completed: Integer

- Lessons completed: Integer

- Questions answered: Integer

- Correct answers: Integer

- XP earned: Integer

- Time spent: Integer (minutes) - Total active time

- Streak maintained: Boolean - Whether activity counted toward streak

**Automated Activity Tracking:** The `daily_activity_log` is automatically updated via database triggers whenever a user:

1. Answers a question (`user_questions_history`) -> Increments `questions_answered` and `correct_answers`.
2. Completes a session (`user_session_history`) -> Increments `sessions_completed` if `passed` is true.
3. Completes a lesson (`user_lessons_history`) -> Increments `lessons_completed` if `passed` is true.
4. Completes a challenge (`user_challenges_history`) -> Increments `sessions_completed` (challenges are counted as sessions) if `passed` is true.

#### App Configuration

Global settings editable by learning expert from dashboard:

- Config key: Primary key, unique identifier (e.g.,
  \"daily_xp_goal_default\")

- Config value: Text or JSON - The actual value

- Data type: enum (integer, boolean, string, json, array) - Value type

- Description: What this configuration controls

- Category: enum (gamification, learning, social, challenges,
  notifications) - Grouping

- Last updated: Timestamp

#### Database Indexes

For optimal performance, the following indexes should be created:

- Learning Path Tables:

  - Questions: (Concept ID, Difficulty, Status)

  - Questions: (Tags) - for tag-based filtering

  - Sessions: (Lesson ID, Order)

  - Lessons: (Order, Status)

- App Logic Tables:

  - User Session History: (User ID, Session ID, Started at)

  - User Progress: (User ID, Lesson ID, Status)

  - User Lessons History: (User ID, Lesson ID, Started at)

  - Daily Activity Log: (User ID, Activity date)

  - League Participants: (League ID, XP earned this week) - for
    leaderboard queries

  - Notifications: (User ID, Read at) - for unread counts

  - Friends: (User ID 1, Status), (User ID 2, Status) - for friend
    lookups

#### Security Considerations

Since this database will be created in Supabase with direct client
access:

- Row Level Security (RLS) must be enabled on all user-related tables

- **Performance Optimization**: RLS policies should wrap `auth.uid()` calls in a subquery `(SELECT auth.uid())` to prevent row-by-row re-evaluation and improve query performance.

- **Consolidated Policies**: Avoid multiple permissive policies for the same role and action on a single table. Consolidate logic into single policies for better maintainability and performance.

- Users can read/write their own data (User Progress, User Session
  History, User Gamification Stats, etc.) including updates

- Learning path content (Questions, Lessons, Sessions, etc.) should be
  read-only for users

- The learning expert dashboard will need admin-level access through
  service role key

- Implement rate limiting on question fetching to prevent data scraping

### Table creation order suggestion

When creating in Supabase, follow this order to avoid foreign key
issues:

#### Phase 1: Learning Path Structure

1) Blocks

2) Topics

3) Headings

4) Concepts

5) Questions

6) Lessons

7) Sessions

8) Session Question Pool (relationship table)

9) Lesson Prerequisites (relationship table)

10) Challenge Templates

11) Learning Path Configuration
    - `retry_penalty_enabled` (boolean)
    - `retry_penalty_percentage` (integer)
    - `spaced_repetition_intervals` (array)
    - `minimum_passing_score` (integer)
    - `daily_xp_goal_default` (integer)
    - `xp_per_correct_answer` (integer) - Default: 10
    - `base_xp_per_level` (integer) - Base XP increment for the first level.
    - `xp_level_multiplier` (decimal) - Multiplier to scale difficulty per level.

#### Phase 2: User System

1) Users

2) Admin Users

#### Phase 3: User Progress

1) User Progress

2) User Session History

3) User Gamification Stats

4) Daily Activity Log

#### Phase 4: Gamification

1) Achievements/Badges

2) User Achievements

3) Leagues

4) League Participants

#### Phase 5: Social

1) Friends

2) Friendly Matches

#### Phase 6: Other

1) Challenge History

2) Notifications

3) App Configuration

### SQL files

All sql files to create this database are in the folder ".\\Database"
