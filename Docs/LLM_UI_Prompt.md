# Polilingo UI/UX Design Prompt

**Project Name:** Polilingo
**Project Goal:** A gamified mobile app to help students prepare for the Spanish State Police Exam (Oposiciones Cuerpo Nacional de Policía / Guardia Civil).

## 1. Core Concept & Aesthetic

- **Gamification:** The app uses a "heart" (lives) system, XP, levels, and streaks to motivate users.
- **Style:** Premium, modern, and high-energy.
- **Design Tokens:**
  - **Palette:** Vibrant accent colors (Police Blue #1A237E, Energetic Gold #FFD600) balanced with soft HSL-based neutrals.
  - **Visual Language:** Glassmorphism, smooth gradients, rounded corners, and subtle micro-animations.
  - **Typography:** Modern Sans-Serif (e.g., Inter, Outfit, or Montserrat).
  - **Modes:** Must support both Light and cohesive Dark Mode.

## 2. Technical Context

- **Backend:** FastAPI with Supabase (Database & Auth).
- **Frontend Architecture:** Modern component-based architecture (React Native or Flutter).
- **Communication:** The frontend interacts with a REST API for authentication, profile management, and learning logic.

## 3. Key Screen Requirements

### A. Onboarding & Authentication

- **Welcome Screen:** High-impact entrance with login/signup options.
- **Auth Screens:** Email/Password and Social (Google) login.
- **Profile Setup:**
  - Username selection (unique).
  - Full name input.
  - Daily Goal selection (Casual: 10XP, Regular: 30XP, Serious: 50XP, Insane: 100XP).

### B. The Learning Path (Main Hub)

- **Structure:** The curriculum is divided into **Lessons**, each contains multiple **Sessions**.
- **UI:** A vertical path or "map" where sessions are represented by icons/nodes.
- **Status:** Nodes change state: Locked (grayscale), Available (colored), Completed (Gold/Checkmark).
- **Top Bar Statistics:**
  - **Streak:** Fire icon with current day count.
  - **Lives:** Heart icon showing (Current Lives / Max 5). Lives refill every 4 hours.
  - **Level/XP:** Level badge and a progress bar showing XP to next level.

### C. Practice & Challenges (Alternative Tab)

- **Error Review:** A special area to review questions answered incorrectly in the past.
- **Challenges:** Lightning rounds, timed tests, or "survival" mode (no life loss allowed).

### D. The Learning Interface (Session Runner)

- **Progression:** Header with a progress bar and an "X" to exit.
- **Question Layout:**
  - Question text (Police exam questions can be long and technical).
  - Multiple choice options (A, B, C).
  - Lives remaining indicator.
- **Interaction Flow:**
    1. User selects an option and clicks "Check".
    2. **Success:** Feedback pop-up (Green) + Gain XP.
    3. **Failure:** Feedback pop-up (Red) + Lose 1 Heart + **Show Explanation Button**.
    4. **Retry Round:** Questions missed during the session are automatically queued for the end of the session.
- **Session End:** Summary screen showing XP gained, accuracy percentage, and streak update.

### E. User Profile & Social

- **Profile Card:** Avatar, Username, Join Date.
- **Statistics Grid:** Total XP, Best Streak, Lessons Completed, Questions Answered (Total/Correct).
- **Leaderboards:** Weekly ranking with other users.

## 4. Specific UX Behaviors to Design

- **The "Life" Refill:** If lives = 0, the user is blocked from starting sessions. Show a "Refill countdown" timer inside the heart icon.
- **The Explanation Modal:** On wrong answers, users should easily expand a detailed legal/technical explanation for the correct answer.
- **XP Transitions:** Animate the XP progress bar filling up after each correct answer or at session end.
