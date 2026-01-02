# Theme & Design System Documentation

This document describes the complete design system and theming architecture for the Polilingo mobile application.

## Design Philosophy

Polilingo uses a **premium, mission-critical aesthetic** designed to inspire discipline, focus, and professionalism. The visual language draws from law enforcement and tactical themes while maintaining modern app design standards.

---

## Color Palette

### Primary Colors

- **Primary Blue**: `#1A237E` - Deep police blue, used for primary UI elements and branding
- **Accent Gold**: `#FFD700` - Energetic gold for call-to-action elements and highlights
- **Gold Light**: `#FFF176` - Lighter variant for gradients and subtle accents

### Background Colors

- **Background Dark**: `#121320` - Primary dark background
- **Background Light**: `#F6F6F8` - Light mode background (if applicable)
- **Surface Dark**: `#1E1F30` - Elevated surfaces in dark mode
- **Surface Light**: `#FFFFFF` - White surfaces for light mode

### Status Colors

- **Success**: `#4CAF50` - Green for positive feedback
- **Error**: `#E53935` - Red for errors and warnings
- **Warning**: `#FFA000` - Amber for caution states

### Text Colors

- **Text Primary Dark**: `#FFFFFF` - White text on dark backgrounds
- **Text Primary Light**: `#121320` - Dark text on light backgrounds
- **Text Secondary Dark**: `#B0BEC5` - Muted text on dark backgrounds
- **Text Secondary Light**: `#757575` - Muted text on light backgrounds

### Gradients

- **Hero Gradient**:
  - Top: `#2B36A8`
  - Middle: `#1A227F` (60%)
  - Bottom: `#0D1020`
  - Primary gradient used in welcome and authentication screens

---

## Typography

### Font Family

**Inter** (via Google Fonts) - Modern, professional sans-serif font with excellent legibility.

### Type Scale

| Style | Size | Weight | Use Case |
|-------|------|--------|----------|
| Display Large | 32px | 800 (ExtraBold) | Hero headlines, main titles |
| Headline Medium | 24px | 700 (Bold) | Section headers |
| Title Large | 20px | 600 (SemiBold) | Card titles, subtitles |
| Body Large | 16px | 400 (Regular) | Primary body text |
| Body Medium | 14px | 400 (Regular) | Secondary text, captions |

### Text Styling

- **Letter Spacing**: Increased spacing (1.2) on buttons for emphasis
- **Line Height**: 1.1 for headlines, default for body text

---

## Visual Effects

### Glassmorphism

Used throughout the app for modern, semi-transparent panels:

- Background opacity: 0.08
- Border: 1px white at 12% opacity
- Blur effect via backdrop filter

### Shadows & Glows

- **Gold Glow**: Used on featured elements (badge illustrations)
  - Color: `AppColors.accentGold` at 20% opacity
  - Blur radius: 60px
  - Spread: 10px

- **Decorative Blurred Circles**: Background elements for depth
  - Positioned off-screen (creating partial visibility)
  - Large radius (300-500px)
  - Low opacity (20-40%)

### Animations

- **Tween Animations**: Smooth transitions using `TweenAnimationBuilder`
- **Duration**: 2 seconds for hero elements
- **Easing**: Default cubic curves

---

## Component Styling

### Buttons

#### Elevated Button (Primary CTA)

- Background: `AppColors.accentGold`
- Foreground: `AppColors.primary`
- Minimum size: Full width × 56px height
- Border radius: 12px
- Font size: 18px, bold, letter-spacing: 1.2

#### Outlined Button (Secondary CTA)

- Border: White at 24% opacity
- Foreground: White
- Minimum size: Full width × 56px height
- Border radius: 12px
- Font size: 16px

### Text Fields

- Background: White at 5-8% opacity
- Border: White at 12% opacity
- Border radius: 12px
- Padding: 16px horizontal and vertical
- Label color: White at 70% opacity
- Input text: White

### Cards & Panels

- Background: White at 3-8% opacity
- Border radius: 16-24px
- Border: White at 12% opacity (for emphasis)
- Padding: 16-24px

---

## Implementation Files

### Flutter Code

- **Colors**: [`lib/core/app_colors.dart`](file:///c:/Users/berti/Documents/Polilingo/Mobile/Polilingo/polilingo_app/lib/core/app_colors.dart)
- **Theme**: [`lib/core/app_theme.dart`](file:///c:/Users/berti/Documents/Polilingo/Mobile/Polilingo/polilingo_app/lib/core/app_theme.dart)

### Usage Example

```dart
import 'package:polilingo_app/core/app_colors.dart';
import 'package:polilingo_app/core/app_theme.dart';

// Apply theme
MaterialApp(
  theme: AppTheme.darkTheme,
  // ...
);

// Use colors
Container(
  decoration: BoxDecoration(
    gradient: AppColors.heroGradient,
  ),
);
```

---

## Accessibility Considerations

- **Contrast Ratios**: All text-background combinations meet WCAG AA standards
- **Touch Targets**: All interactive elements are minimum 56px in height
- **Visual Hierarchy**: Clear distinction between primary, secondary, and tertiary elements
