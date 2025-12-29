# Challenges

This document outlines the structure and configuration of challenges in Polilingo.

## challenge_templates Table

The `challenge_templates` table defines the various types of algorithmic challenges available to users. These templates are configured by learning experts via the dashboard.

### Schema Definition

| Column | Type | Description |
| :--- | :--- | :--- |
| `id` | UUID | Unique identifier for the challenge template. |
| `name` | TEXT | Display name of the challenge as seen by the user. |
| `challenge_type` | TEXT | Algorithmic type: `lightning_round`, `review_weak_topics`, `review_mistakes`, `speed_run`, `accuracy_challenge`, `spaced_repetition_review`. |
| `description` | TEXT | Brief description of the challenge's objectives and rules. |
| `icon_url` | TEXT | URL to the graphic asset used for this challenge. |
| `time_limit` | INTEGER | Maximum duration in seconds. If `NULL`, the challenge is untimed. |
| `number_of_questions` | INTEGER | Total count of questions assigned to this challenge. |
| `question_selection_algorithm` | TEXT | The identifier for the logic used to select questions (e.g., from `pool_algorithms.py`). |
| `scoring_formula` | TEXT | Method for calculating final points: `standard`, `time_bonus`, `combo_multiplier`, `no_penalty`. |
| `xp_multiplier` | DECIMAL | Bonus multiplier applied to XP earned (e.g., `1.5` for 50% bonus). |
| `unlock_criteria` | JSONB | JSON conditions required to access the challenge, e.g., `{"min_lessons_completed": 5, "min_level": 3}`. |
| `cooldown_period` | INTEGER | Time in hours before the challenge can be played again by the same user. |
| `active` | BOOLEAN | Flag to enable or disable the challenge template. |
| `created_at` | TIMESTAMPTZ | Creation timestamp. |
| `updated_at` | TIMESTAMPTZ | Last modification timestamp. |

## Challenges

### Lightning Round

The `lightning_round` challenge is a timed challenge where users must answer as many questions as possible within a set time limit.
The user answers questions in a random order from a pool of all the questions that the user has already answered.

#### template table row

```json
{
    "name": "Ronda Relampago",
    "challenge_type": "lightning_round",
    "description": "Responde a tantas preguntas como puedas en un tiempo limitado.",
    "time_limit": 60,
    "number_of_questions": 10,
    "question_selection_algorithm": "random",
    "scoring_formula": "standard",
    "xp_multiplier": 1.2,
    "unlock_criteria": {"min_lessons_completed": 5, "min_level": 3},
    "cooldown_period": 0,
    "active": true,
    "created_at": "2022-01-01T00:00:00Z",
    "updated_at": "2022-01-01T00:00:00Z"
}
```
