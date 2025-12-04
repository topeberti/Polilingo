# Contenido {#contenido .TOC-Heading}

[Introduction [1](#_Toc215311116)](#_Toc215311116)

[Database [2](#database)](#database)

[Learning path tables [2](#learning-path-tables)](#learning-path-tables)

[Blocks, topcis, headings and concepts
[2](#blocks-topcis-headings-and-concepts)](#blocks-topcis-headings-and-concepts)

[Questions [3](#questions)](#questions)

[Lessons [3](#lessons)](#lessons)

[Lesson Prerequisites [4](#lesson-prerequisites)](#lesson-prerequisites)

[Sessions [4](#sessions)](#sessions)

[Session Question Pool
[5](#session-question-pool)](#session-question-pool)

[Learning path [5](#learning-path)](#learning-path)

[Algorithmic challenges
[5](#algorithmic-challenges)](#algorithmic-challenges)

[App logic tables [6](#app-logic-tables)](#app-logic-tables)

[Users [6](#users)](#users)

[User progress [7](#user-progress)](#user-progress)

[User Session History [7](#user-session-history)](#user-session-history)

[User Gamification Stats
[8](#user-gamification-stats)](#user-gamification-stats)

[Achievements/Badges [9](#achievementsbadges)](#achievementsbadges)

[User Achievements [9](#user-achievements)](#user-achievements)

[Leagues [9](#leagues)](#leagues)

[League Participants [10](#league-participants)](#league-participants)

[Friends [10](#friends)](#friends)

[Friendly Matches [10](#friendly-matches)](#friendly-matches)

[Challenge History [11](#challenge-history)](#challenge-history)

[Notifications [11](#notifications)](#notifications)

[Daily Activity Log [12](#daily-activity-log)](#daily-activity-log)

[App Configuration [12](#app-configuration)](#app-configuration)

[Database Indexes [13](#database-indexes)](#database-indexes)

[Security Considerations
[13](#security-considerations)](#security-considerations)

[Table creation order suggestion
[14](#table-creation-order-suggestion)](#table-creation-order-suggestion)

[Phase 1: Learning Path Structure
[14](#phase-1-learning-path-structure)](#phase-1-learning-path-structure)

[Phase 2: User System [14](#phase-2-user-system)](#phase-2-user-system)

[Phase 3: User Progress
[14](#phase-3-user-progress)](#phase-3-user-progress)

[Phase 4: Gamification
[14](#phase-4-gamification)](#phase-4-gamification)

[Phase 5: Social [15](#phase-5-social)](#phase-5-social)

[Phase 6: Other [15](#phase-6-other)](#phase-6-other)

[SQL files [15](#sql-files)](#sql-files)

[Learning Expert Dashboard
[15](#learning-expert-dashboard)](#learning-expert-dashboard)

[Overview [15](#overview)](#overview)

[Functional Requirements
[15](#functional-requirements)](#functional-requirements)

[1. Authentication & Security
[15](#authentication-security)](#authentication-security)

[2. Dashboard Home (Overview)
[15](#dashboard-home-overview)](#dashboard-home-overview)

[3. Syllabus Manager (Blocks/Topics/Headings/Concepts)
[16](#syllabus-manager-blockstopicsheadingsconcepts)](#syllabus-manager-blockstopicsheadingsconcepts)

[4. Question Bank Manager
[16](#question-bank-manager)](#question-bank-manager)

[5. Learning Path Builder (Lessons & Sessions)
[17](#learning-path-builder-lessons-sessions)](#learning-path-builder-lessons-sessions)

[6. Gamification & Logic Configurator
[17](#gamification-logic-configurator)](#gamification-logic-configurator)

[7. User Analytics (Read-Only)
[17](#user-analytics-read-only)](#user-analytics-read-only)

[Technical Stack Recommendation for Dashboard
[18](#technical-stack-recommendation-for-dashboard)](#technical-stack-recommendation-for-dashboard)

[Workflows [18](#workflows)](#workflows)

[Workflow 1: Adding a New Topic
[18](#workflow-1-adding-a-new-topic)](#workflow-1-adding-a-new-topic)

[Workflow 2: Creating a Lesson
[18](#workflow-2-creating-a-lesson)](#workflow-2-creating-a-lesson)

[Technical Requirements & UI Guidelines
[18](#technical-requirements-ui-guidelines)](#technical-requirements-ui-guidelines)

[1. Tech Stack Constraints
[19](#tech-stack-constraints)](#tech-stack-constraints)

[2. UI/UX Guidelines (Dashboard)
[19](#uiux-guidelines-dashboard)](#uiux-guidelines-dashboard)

[3. Algorithmic Logic Specifications
[19](#algorithmic-logic-specifications)](#algorithmic-logic-specifications)

[A. Spaced Repetition Logic (Simple Version)
[19](#a.-spaced-repetition-logic-simple-version)](#a.-spaced-repetition-logic-simple-version)

[]{#_Toc215311116 .anchor}

# Introduction {#introduction-1}

In this document we will explain in detail the design, requirements and
goals for the development of an app that uses a gamified learning style
as duolingo for the police statal exam in spain. We aim to create in
less than two months the first iteration of the app which consists in
three keypoints:

- **Database**: Creating a dataset with the exam questions and a
  database accessible by the backend to server questions to the
  frontend. The database will also have to store the information for the
  users and everything needed for the app.

- **App**: The app is divided in two keypoints:

  - **Frontend**: The appearance of the app, a modern and intuitive UI
    that makes learning fun and easy, an app with a strong social
    component with laderboards, leagues and friendly matches, a
    personally focused app with tailored sets of lessons based on the
    users weak and strong points, an app that encourages personal
    development with extra lesson challenges as, how many questions
    without failing in a row you can do, or lightning rounds.

  - **Backend**: A robust server that will serve the questions to the
    frontend, the information for the social activity and will carry all
    the logic and data management needed.

- **Learning path**: The order, quantity and frequency of questions
  delivered to the user, the learning experience, the types of lessons,
  etc. Will be designed by an expert in the field so the learning curve
  is smooth and ensures enjoyable and useful learning. The expert will
  decide the content of the lessons, their order and some parameters of
  the challenges.

This three keypoints will interact with each other's, the interaction
between the app and the database is obvious but a deeper introduction
for the other interactions must be said:

- **Database -- Learning path interaction:** The learning expert that
  will design the lessons is not computer fluent, and the questions and
  syllabus of this type of exams is quite volatile, so the learning
  expert will need to edit, add and delete questions from the database
  at any moment. As he will not learn how to use sql, a learning expert
  dashboard must be created apart of the app. A website with
  authentication that will be served by the server where the learning
  expert can see, edit add and delete questions from the database
  easily.

- **App -- Learning path interaction:** The app will only be a lesson
  delivery interface, the structure of a lesson will always be the same,
  a set of ordered sessions and a session is a set of random questions
  selected with certain parameters. The lessons are not going to be
  hardcoded, as we said earlier the syllabus is volatile and the
  learning expert needs to be able to modify the learning path easily.
  For this reason the lessons should be created, edited and deleted from
  the dashboard also, saved in the database and then the app will server
  them in the stipulated order. So the app will only be an skeleton
  ready to server lessons and the early mentioned challenges, which will
  have an algorithmic behavior but the parameters of that algorithms
  also have to be editable by the learning expert.

# Database

## Learning path tables

The database will be created in supabase for a clean and fast setup SQL.

The syllabus is organized by this hierarchy:

1)  Syllabus

    a)  Blocks

        i)  Topics

            (1) Headings

                (a) Concepts

                    (i) Questions

Each question belongs to a concept, that belongs to a heading, that
belongs to a topic, that belongs to a block.

### Blocks, topcis, headings and concepts

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

### Questions

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

### Lessons

For the lessons, the learning expert still has to design their
requirements but for now on they need this information:

- Name

- Order/Position: An integer defining the lesson sequence in the
  learning path.

- XP reward: Integer - Gamification element defining experience points
  earned upon completion.

- Status: enum (active, draft, archived) - Allows the learning expert to
  prepare lessons without making them live.

### Lesson Prerequisites

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

### Sessions

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
table between users, sessions, and questions with fields for:

- Timestamp

- User answer

- Correct/incorrect

- Time taken

This data is essential for the \"tailored sets of lessons based on the
users weak and strong points\" mentioned in your introduction and for
spaced repetition algorithms.

### Session Question Pool

Links sessions to their available questions:

- Session ID: Foreign key to Sessions

- Question ID: Foreign key to Questions

- Weight: Integer - nullable, for weighted_by_difficulty selection

- Added at: Timestamp

- Active: Boolean - Whether this question is currently in the pool

- Primary key: Composite of (Session ID, Question ID)

### Learning path

For the learning path global configuration, the following parameters are
needed:

- Retry penalty: Boolean or XP amount - Whether retrying a session
  affects XP rewards

- Spaced repetition intervals: Array of integers (days) - Defines when
  questions should be re-presented

These parameters can be edited by the learning expert from the dashboard
without changing the app code.

### Algorithmic challenges

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

## App logic tables

Tables that will be needed for the app functionality like users
profiles, history, gamification mechanics, social features, and
challenges.

### Users

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

### User progress

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

### User Session History

Detailed record of each session attempt (this is the many-to-many table
mentioned in Learning path section):

- History ID: Primary key

- User ID: Foreign key to Users

- Session ID: Foreign key to Sessions

- Lesson ID: Foreign key to Lessons

- Started at: Timestamp

- Completed at: Timestamp - nullable if session not finished

- Questions shown: Array of question IDs - Exact questions presented in
  this attempt

- User answers: Array of user responses - Corresponds to questions shown

- Correct answers: Array of booleans - Corresponds to questions shown

- Time per question: Array of integers (seconds) - Time taken per
  question

- Total score: Integer (percentage) - Overall session performance

- XP earned: Integer - XP from this session

- Passed: Boolean - Whether user met minimum passing score

- Question selection strategy used: enum - Which strategy was applied
  for this session

### User Gamification Stats

Tracks gamification metrics per user:

- User ID: Foreign key to Users (Primary key)

- Total XP: Integer - Lifetime experience points

- Current level: Integer - Calculated from total XP

- XP to next level: Integer - Points needed to level up

- Current streak: Integer (days) - Consecutive days of activity

- Longest streak: Integer (days) - Best streak ever achieved

- Last streak date: Date - Last day streak was maintained

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

### Achievements/Badges

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

### User Achievements

Tracks which achievements each user has unlocked:

- User ID: Foreign key to Users

- Achievement ID: Foreign key to Achievements

- Unlocked at: Timestamp

- Shown notification: Boolean - Whether user has seen the unlock
  notification

### Leagues

Weekly competitive leagues:

- League ID: Primary key

- League name: enum (bronze, silver, gold, diamond, obsidian)

- Start date: Timestamp - When this league week began

- End date: Timestamp - When this league week ends

- Promotion threshold: Integer - Minimum rank to move up a league

- Demotion threshold: Integer - Maximum rank to avoid moving down

- Active: Boolean - Whether this is the current active league period

### League Participants

Tracks users in each league period:

- Participant ID: Primary key

- User ID: Foreign key to Users

- League ID: Foreign key to Leagues

- XP earned this week: Integer - Points accumulated during league period

- Current rank: Integer - Position in league leaderboard

- Previous rank: Integer - Rank in last update (for showing movement)

- Promoted: Boolean - nullable, set at end of week

- Demoted: Boolean - nullable, set at end of week

### Friends

Social connections between users:

- Friendship ID: Primary key

- User ID 1: Foreign key to Users

- User ID 2: Foreign key to Users

- Status: enum (pending, accepted, blocked) - Friendship state

- Requested by: Foreign key to Users - Who initiated the friend request

- Created at: Timestamp

- Accepted at: Timestamp -- nullable

### Friendly Matches

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

### Challenge History

Records for special algorithmic challenges (lightning rounds, perfect
streaks, etc.):

- Challenge ID: Primary key

- Challenge Template ID: Foreign key to Challenge Templates - Links to
  which challenge type was played

- User ID: Foreign key to Users

- Started at: Timestamp

- Completed at: Timestamp - nullable

- Questions answered: Integer

- Correct answers: Integer

- Time taken: Integer (seconds)

- Score: Integer - Challenge-specific scoring

- XP earned: Integer

- New personal best: Boolean - Whether this beat user\'s previous record

### Notifications

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

### Daily Activity Log

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

### App Configuration

Global settings editable by learning expert from dashboard:

- Config key: Primary key, unique identifier (e.g.,
  \"daily_xp_goal_default\")

- Config value: Text or JSON - The actual value

- Data type: enum (integer, boolean, string, json, array) - Value type

- Description: What this configuration controls

- Category: enum (gamification, learning, social, challenges,
  notifications) - Grouping

- Last updated: Timestamp

### Database Indexes

For optimal performance, the following indexes should be created:

- Learning Path Tables:

  - Questions: (Concept ID, Difficulty, Status)

  - Questions: (Tags) - for tag-based filtering

  - Sessions: (Lesson ID, Order)

  - Lessons: (Order, Status)

- App Logic Tables:

  - User Session History: (User ID, Session ID, Started at)

  - User Progress: (User ID, Lesson ID, Status)

  - Daily Activity Log: (User ID, Activity date)

  - League Participants: (League ID, XP earned this week) - for
    leaderboard queries

  - Notifications: (User ID, Read at) - for unread counts

  - Friends: (User ID 1, Status), (User ID 2, Status) - for friend
    lookups

### Security Considerations

Since this database will be created in Supabase with direct client
access:

- Row Level Security (RLS) must be enabled on all user-related tables

- Users can only read/write their own data (User Progress, User Session
  History, User Gamification Stats, etc.)

- Learning path content (Questions, Lessons, Sessions, etc.) should be
  read-only for users

- The learning expert dashboard will need admin-level access through
  service role key

- Implement rate limiting on question fetching to prevent data scraping

## Table creation order suggestion

When creating in Supabase, follow this order to avoid foreign key
issues:

### Phase 1: Learning Path Structure

1)  Blocks

2)  Topics

3)  Headings

4)  Concepts

5)  Questions

6)  Lessons

7)  Sessions

8)  Session Question Pool (relationship table)

9)  Lesson Prerequisites (relationship table)

10) Challenge Templates

11) Learning Path Configuration

### Phase 2: User System

1)  Users

2)  Admin Users

### Phase 3: User Progress

1)  User Progress

2)  User Session History

3)  User Gamification Stats

4)  Daily Activity Log

### Phase 4: Gamification

1)  Achievements/Badges

2)  User Achievements

3)  Leagues

4)  League Participants

### Phase 5: Social

1)  Friends

2)  Friendly Matches

### Phase 6: Other

1)  Challenge History

2)  Notifications

3)  App Configuration

## SQL files

All sql files to create this database are in the folder ".\\Database"

# Learning Expert Dashboard

## Overview

The Learning Expert Dashboard is a web-based content management system
(CMS) designed specifically for the learning expert. It serves as the
control center for the app's content, logic parameters, and structure.

**Design Philosophy:** - **No-Code Interface:** No SQL or JSON knowledge
required. All interactions are via forms, drag-and-drop interfaces, and
visual switches. - **Safety First:** "Soft deletes" (archiving) instead
of permanent deletion, and confirmation prompts for critical actions. -
**Draft & Publish:** Content defaults to "Draft" status to prevent
incomplete lessons from appearing in the live app.

## Functional Requirements

### 1. Authentication & Security

- **Login Portal:** Secure email/password login.

### 2. Dashboard Home (Overview)

A high-level snapshot of the content database health.

- **Content Counters:** Display total number of Blocks, Topics,
  Concepts, and Questions, Lessons and Sessions

- **Health Alerts:**

  - "Concepts with less than 10 questions" (Alerts the expert to empty
    parts of the syllabus).

  - Lessons with less than 10 sessions.

### 3. Syllabus Manager (Blocks/Topics/Headings/Concepts)

A hierarchical tree-view interface to manage the categorization of
knowledge.

- **Tree View Navigation:**
  - A distinct visual hierarchy: *Block \> Topic \> Heading \> Concept*.
  - Users can expand/collapse sections to find specific concepts.
- **CRUD Operations:**
  - **Create:** Add new categories at any level.
  - **Edit:** Rename, change descriptions, or toggle Visibility
    (Active/Draft/Archived).

<!-- -->

- **Data Grid View:**
  - Search bar (search by text or ID).
  - Columns: ID, Text snippet, Difficulty, Status, Last Modified.

<!-- -->

- **Concept Stats:** Beside each Concept, show a small badge indicating
  how many questions define that concept (e.g., "Concept: Penal Code
  Art. 1 \[15 questions\]"). Same for headings and topics, topics and
  concetps, blocks and headings and lessons and sessions.

### 4. Drag and drop learning path reorder

- **Reorder:** **Drag-and-drop** functionality to change the
  `Order/Position` integer in the database visually.
  - A page for each sortable content
    (blocks,topics,headings,concepts,questions,lessons and sessions)
    that show contents in order from right to left with boxes
    representing the content. Boxes have a sticker in the right top
    corner with the order number, and arrows between the boxes.
  - The page will let you select a content thas has a child sortable
    content and show it. There will be buttons for each of them and when
    you select one it lets you select which of them. For example, if you
    click on topic, a list of all the topics will be shown, and when a
    topic is selected, then all its conpcets will be shown in a graph
    form as it is explained in the next points of this list.
  - The user must be able to drag and drop the boxes to reorder them and
    that will change the order in the database.
  - There will be a save button that will change the values of the order
    columns of each element that changed its position to the database.
  - Disclaimer: The possibility that two elements have the same order
    value or no value exists, as it is a nullable column in the
    database. Content with no value will be put the last in the order,
    and the ones with the same order can be ordered by id.
  - The boxes of contents with childs will have a button under them that
    will open the graph view of all its childs.

### 5. Question Bank Manager

The core interface for inputting the actual exam content.

- **Data Grid View:**
  - Search bar (search by text or ID).
  - Filters: By Concept, Difficulty, Status, or Source.
  - Columns: ID, Text snippet, Difficulty, Status, Last Modified.
- **Question Editor (Form):**
  - **Text Input:** Rich text support (bold/italics) for the question
    stem.
  - **Answers:** Three clear input fields (Option A, B, C) with a radio
    button to select the `Correct option`.
  - **Explanation:** Text area for the feedback users see after
    answering.
  - **Taxonomy Picker:** Cascading dropdowns to assign the question to a
    Concept (Block -\> Topic -\> Heading -\> Concept).
  - **Metadata:**
    - Difficulty Slider (1-10).
    - Source field.
    - Status Toggle (Active/Draft).
- **Bulk Import/Export:**
  - Feature to upload a **CSV/Excel file** to create hundreds of
    questions at once.
  - Feature to export current questions to Excel for offline review.
  - Feature to export a csv file with the columns to be filled to act as
    a skeleton to create a csv file to upload later

### 6. Learning Path Builder (Lessons & Sessions)

A linear, visual timeline interface to design the user's journey.

- **Lesson Management:**
  - **List View:** Ordered list of lessons. Drag-and-drop to update
    `Order/Position`.
  - **Lesson Editor:** Define Name, XP Reward, and Prerequisites (using
    a multi-select dropdown of existing lessons).
- **Session Builder (Inside a Lesson):**
  - Interface to add "Sessions" to a specific Lesson.
  - **Strategy Configuration:** A dropdown to select
    `Question selection strategy` (e.g., "Random").
  - **Question Pool Management:**
    - If strategy is "Specific Questions": A search-and-select interface
      to pick specific Question IDs from the bank.
    - If strategy is "Random" or "Weighted": Input fields for "Number of
      Questions" and filters (e.g., "From Concept X, Difficulty \> 5").

### 7. Challenge templates editor

- **Challenge Templates:**
  - Edit existing challenge types (Lightning Rounds, etc.).
  - Adjust `Time Limit`, `Number of Questions`, and `XP Multiplier` via
    sliders.
  - Toggle specific challenges Active/Inactive.

### 8. Gamification & Logic Configurator

A settings panel to tweak the algorithms without touching code. This
maps to the `App Configuration` and `Learning path configuration`
tables.

A list of the configurations to be edited in the dashboard (named by
config_key value):

- **App configuration rows**

  - friend_match_xp_reward

  - league_size

  - streak_reminder_time

- **Learning path configuration**

  - daily_xp_goal_default

  - league_demotion_threshold

  - league_promotion_threshold

  - league_week_start_day

  - minimum_passing_score

  - retry_penalty_enabled

  - retry_penalty_percentage

  - spaced_repetition_intervals

  - streak_freeze_cost

  - xp_per_correct_answer

All these tables have a data_type column, create the forms to edit them
based on the data_type.\
\
This configurations will be grouped by the category column in the page
so its intuitive.

### 9. User Analytics (Read-Only)

To help the expert understand user behavior and adjust content
accordingly. - **Hardest Questions:** A list of questions with the
lowest "Correct Answer %". (Allows the expert to review if the question
is poorly worded or just difficult). - **Stuck Points:** Which Lessons
have high drop-off rates? - **Search User:** Look up a specific user by
email/username to see their progress (useful for debugging user
reports).

## Technical Stack Recommendation for Dashboard

Since the backend is **Supabase**: - **Framework:** **React Admin** or
**Refine.dev**. - These frameworks are specifically built to create
Admin Dashboards on top of Supabase/PostgreSQL rapidly. - They provide
pre-built Data Grids, Forms, and Authentication wrappers, saving weeks
of development time compared to building from scratch. - **Hosting:**
Vercel (same as the frontend app) or Netlify.

## Workflows

### Workflow 1: Adding a New Topic

1.  Expert logs in.
2.  Navigates to "Syllabus".
3.  Selects the parent "Block".
4.  Clicks "Add Topic".
5.  Enters Name ("Constitution") and Description.
6.  Sets Status to "Draft".
7.  Saves.
8.  Uses Drag-and-Drop to place it between existing topics.

### Workflow 2: Creating a Lesson

1.  Navigates to "Learning Path".
2.  Clicks "New Lesson".
3.  Sets Title: "Intro to Constitution".
4.  Sets Prerequisite: "None".
5.  Adds Session 1:
    - Type: "Learning".
    - Strategy: "Random from Concept: Constitution".
    - Count: 10 questions.
6.  Adds Session 2:
    - Type: "Review".
    - Strategy: "Weighted by Difficulty".
    - Count: 5 questions.
7.  Sets Lesson Status to "Active".
8.  Saves.

## Technical Requirements & UI Guidelines

To ensure the developer works fast and the app looks professional
without needing a dedicated designer, we will stick to strict technical
standards.

### 1. Tech Stack Constraints

The developer must adhere to this stack to ensure compatibility with
Supabase and speed of delivery:

- **Frontend Framework:** React.js (Vite) or Next.js.
- **Dashboard Framework:** **React-Admin** or **Refine.dev**.
  - *Reasoning:* These frameworks plug directly into Supabase and
    generate the tables, forms, and filters automatically. Building this
    from scratch would take 3 weeks; using these tools takes 3 days.
- **CSS Framework:** Tailwind CSS (for the App) and Material UI (MUI)
  (for the Dashboard).
- **Database:** Supabase (PostgreSQL).
- **Hosting:** Vercel.

### 2. UI/UX Guidelines (Dashboard)

Since we are not providing custom Figma designs for the dashboard, the
developer should use standard **Material UI (MUI)** components.

- **Color Palette:**
  - **Primary:** Dark Blue (Police style) - Hex: `#1E3A8A`
  - **Secondary:** Gold/Yellow (Badge style) - Hex: `#F59E0B`
  - **Success:** Green - Hex: `#10B981` (for "Active" or "Correct")
  - **Danger:** Red - Hex: `#EF4444` (for "Archived" or "Errors")
- **Layout:** Standard Sidebar navigation (left) with a top header (user
  profile) and main content area.
- **Feedback:** Every "Save" or "Delete" action must show a "Toast"
  notification (e.g., "Question Saved Successfully") in the bottom right
  corner.

### 3. Algorithmic Logic Specifications

The developer needs to know exactly how to code the "magic" behind the
learning path.

### A. Spaced Repetition Logic (Simple Version)

We will use a simplified **Leitner System** logic for the MVP. \* **Box
1:** Every new question starts here. \* **Box 2:** If answered correctly
1 time. (Review in 1 day). \* **Box 3:** If answered correctly 2 times
in a row. (Review in 3 days). \* **Box 4:** If answered correctly 3
times in a row. (Review in 7 days). \* **Logic:** \* If User answers
**Correctly** -\> Move question to next Box. \* If User answers
**Incorrectly** -\> Reset question to **Box 1**.

#### B. "Weighted by Difficulty" Logic

When a session requires "Weighted Selection," the algorithm should works
as follows: 1. Fetch eligible questions from the pool. 2. Assign a
probability weight based on the difference between the **User's Level**
(calculated from Total XP) and the **Question Difficulty**. 3.
**Formula:** \* If Question Difficulty == User Level: High weight
(Standard chance). \* If Question Difficulty \> User Level: Medium
weight (Challenge). \* If Question Difficulty \< User Level: Low weight
(Review). \* *Note to Developer:* Use a standard weighted random
selection function (e.g., looking at the `difficulty` integer vs the
user's average performance).

#### C. XP Calculation Formula

Unless overridden by the Learning Expert, the default XP formula per
session is:
`Total XP = (Base XP per Question * Correct Answers) + (Streak Bonus) + (Time Bonus)`

- **Base XP:** 10 XP.
- **Streak Bonus:** +5 XP if current answer streak \> 5.
- **Time Bonus:** +2 XP per question if answered in under 10 seconds.

------------------------------------------------------------------------

#### Summary: Is it ready now?

**Yes.** With the addition of the text above, you can hand this to a
Full Stack Developer.

- **The Database section** tells them how to store data.
- **The Dashboard section** tells them what tools to build for you.
- **The Tech Requirements** tell them what tools to use.
- **The Logic section** tells them how the math works.

You are ready to go. Good luck with the development!
