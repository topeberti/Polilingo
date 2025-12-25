## Learning Expert Dashboard

### Overview

The Learning Expert Dashboard is a web-based content management system
(CMS) designed specifically for the learning expert. It serves as the
control center for the app's content, logic parameters, and structure.

**Design Philosophy:** - **No-Code Interface:** No SQL or JSON knowledge
required. All interactions are via forms, drag-and-drop interfaces, and
visual switches. - **Safety First:** "Soft deletes" (archiving) instead
of permanent deletion, and confirmation prompts for critical actions. -
**Draft & Publish:** Content defaults to "Draft" status to prevent
incomplete lessons from appearing in the live app.

### Functional Requirements

#### 1. Authentication & Security

- **Login Portal:** Secure email/password login.

#### 2. Dashboard Home (Overview)

A high-level snapshot of the content database health.

- **Content Counters:** Display total number of Blocks, Topics,
  Concepts, and Questions, Lessons and Sessions

- **Health Alerts:**

  - "Concepts with less than 10 questions" (Alerts the expert to empty
    parts of the syllabus).

  - Lessons with less than 10 sessions.

#### 3. Syllabus Manager (Blocks/Topics/Headings/Concepts)

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

#### 4. Drag and drop learning path reorder

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

#### 5. Question Bank Manager

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

#### 6. Learning Path Builder (Lessons & Sessions)

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

#### 7. Challenge templates editor

- **Challenge Templates:**
  - Edit existing challenge types (Lightning Rounds, etc.).
  - Adjust `Time Limit`, `Number of Questions`, and `XP Multiplier` via
    sliders.
  - Toggle specific challenges Active/Inactive.

#### 8. Gamification & Logic Configurator

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

#### 9. User Analytics (Read-Only)

To help the expert understand user behavior and adjust content
accordingly. - **Hardest Questions:** A list of questions with the
lowest "Correct Answer %". (Allows the expert to review if the question
is poorly worded or just difficult). - **Stuck Points:** Which Lessons
have high drop-off rates? - **Search User:** Look up a specific user by
email/username to see their progress (useful for debugging user
reports).

### Technical Stack Recommendation for Dashboard

Since the backend is **Supabase**: - **Framework:** **React Admin** or
**Refine.dev**. - These frameworks are specifically built to create
Admin Dashboards on top of Supabase/PostgreSQL rapidly. - They provide
pre-built Data Grids, Forms, and Authentication wrappers, saving weeks
of development time compared to building from scratch. - **Hosting:**
Vercel (same as the frontend app) or Netlify.
