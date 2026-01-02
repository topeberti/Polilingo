# Authentication UI Documentation

This document describes the user interface and flow for the authentication module in the Polilingo mobile application.

> **Note**: For detailed information about colors, typography, and visual effects, see [Theme.md](Theme.md).

---

## 1. Welcome Screen

The entry point of the application.

- **Visuals**: Features a large badge illustration with a "floating" animation and a gold glow.
- **Tagline**: "Prepare to Serve." (with a gold gradient on "Serve").
- **Actions**:
  - **START YOUR TRAINING**: Primary call-to-action (CTA) leading to the **Signup** screen.
  - **I already have an account**: Outlined button leading to the **Login** screen.

## 2. Signup Screen

Simplified registration process focused on speed and error prevention.

- **Objective**: Create a new account using only email and password.
- **Fields**:
  - **Email**: Standard email entry.
  - **Password**: Secure entry (6+ characters).
  - **Confirm Password**: Matching check to prevent typos.
- **Validation**:
  - Client-side check for password matching.
  - Client-side check for minimum password length.
- **Success Flow**: Redirects to Login with a request for email verification.

## 3. Login Screen

Secure access to the user's training profile.

- **Fields**: Email and Password.
- **Validation**: Ensures email is verified before allowing access.
- **Navigation**: Link to password recovery and a "Back to Signup" option.

## 4. Profile Setup Screen

First-time configuration for new users after their first login.

- **Identity**: Users choose their training **Username**. (Note: Full Name is optional and currently hidden to streamline the process).
- **Daily Training Goal**: A selection of intensity levels:
  - **Casual**: 10 XP (5m/day)
  - **Regular**: 30 XP (15m/day)
  - **Serious**: 50 XP (30m/day)
  - **Insane**: 100 XP (60m/day)
- **UI Components**: Interactive goal cards that highlight when selected.

---

## Technical Implementation Notes

- **Theme**: Consistent use of `AppColors` for branding.
- **Animations**: Use of `TweenAnimationBuilder` for smooth transitions.
- **Responsiveness**: Use of `SafeArea` and `SingleChildScrollView` to support various screen sizes.
