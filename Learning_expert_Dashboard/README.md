# Polilingo - Learning Expert Dashboard

A comprehensive content management system (CMS) for managing Polilingo's learning content, built with React-Admin and Supabase.

## Features

- **Syllabus Management**: Hierarchical organization of Blocks → Topics → Headings → Concepts
- **Question Bank**: Full CRUD operations for exam questions with bulk import/export
- **Learning Path Builder**: Design lessons and sessions with multiple question selection strategies
- **Gamification Settings**: Configure XP rewards, challenges, and spaced repetition parameters
- **Analytics**: View hardest questions, lesson drop-off rates, and user progress
- **Authentication**: Secure login with Supabase Auth

## Tech Stack

- **Frontend**: React 18 + TypeScript
- **Build Tool**: Vite
- **Admin Framework**: React-Admin 5
- **UI Components**: Material UI (MUI)
- **Backend/Database**: Supabase (PostgreSQL)
- **Styling**: Material UI Theme System

## Getting Started

### Prerequisites

- Node.js 18+ and npm
- A Supabase project with the Polilingo database schema

### Installation

1. Clone the repository and navigate to the dashboard directory:
```bash
cd Learning_expert_Dashboard
```

2. Install dependencies:
```bash
npm install
```

3. Configure environment variables:
   - Copy `.env.example` to `.env`
   - Update with your Supabase credentials:
```env
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key
```

4. Start the development server:
```bash
npm run dev
```

The dashboard will open at `http://localhost:3000`

## Project Structure

```
src/
├── components/           # Custom UI components
│   ├── analytics/       # Reports and analytics
│   ├── config/          # Settings panels
│   ├── layout/          # Dashboard layout
│   ├── lessons/         # Lesson management
│   ├── questions/       # Question bank components
│   └── syllabus/        # Syllabus tree view
├── providers/           # Data providers
│   └── supabaseDataProvider.ts
├── resources/           # React-Admin resource definitions
│   ├── blocks.tsx
│   ├── challenges.tsx
│   ├── concepts.tsx
│   ├── headings.tsx
│   ├── lessons.tsx
│   ├── questions.tsx
│   ├── sessions.tsx
│   └── topics.tsx
├── App.tsx              # Main application
├── authProvider.ts      # Authentication logic
├── main.tsx             # Entry point
└── theme.ts             # MUI theme configuration
```

## Usage

### Managing the Syllabus

1. Navigate to **Blocks** to create top-level organizational units
2. Add **Topics** under blocks
3. Create **Headings** under topics
4. Define **Concepts** under headings
5. Add **Questions** linked to specific concepts

### Creating Questions

- Use the **Questions** resource for single question creation/editing
- Questions include:
  - Question text
  - Three answer options (A, B, C)
  - Correct answer selection
  - Explanation
  - Difficulty level (1-10)
  - Source attribution
  - Status (Active/Draft)

### Building Learning Paths

1. Create **Lessons** with XP rewards
2. Add **Sessions** to lessons
3. Configure question selection strategies:
   - Random
   - Weighted by Difficulty
   - Adaptive
   - Spaced Repetition

### Configuring Gamification

- Navigate to **Settings** to adjust global parameters
- Edit **Challenge Templates** for lightning rounds and special challenges
- Configure XP multipliers and retry penalties

## Database Requirements

The dashboard expects the following Supabase tables:

**Learning Path Tables:**
- `blocks`, `topics`, `headings`, `concepts`
- `questions`
- `lessons`, `sessions`
- `session_question_pool`
- `challenge_templates`

Refer to `Docs/doc.md` in the main project for the complete database schema.

## Authentication

The dashboard uses Supabase Auth for secure login:
- Email/password authentication
- Role-based permissions (admin roles)
- Session management

## Development

### Build for Production

```bash
npm run build
```

### Preview Production Build

```bash
npm run preview
```

### Linting

```bash
npm run lint
```

## Deployment

Deploy to Vercel, Netlify, or any static hosting service:

1. Build the project: `npm run build`
2. Deploy the `dist` folder
3. Set environment variables in your hosting platform

## Future Enhancements

- Full drag-and-drop tree view for syllabus management
- CSV/Excel bulk import implementation
- Advanced analytics with charts and graphs
- Real-time collaboration features
- Question preview mode
- Automated difficulty scoring

## Support

For issues or questions, refer to the main Polilingo documentation or contact the development team.

## License

Private project - All rights reserved
