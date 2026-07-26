---
phase: 03-navigation-primary-user-flow
plan: 01
status: complete
started: 2026-07-26
completed: 2026-07-26
commits:
  - 323d558
  - d1833a8
  - d333bf6
requirements_covered: [NAV-01, NAV-02, NAV-03]
deviations:
  - type: enhancement
    description: "Added salaam greeting text (Arabic/transliteration/English) to reveal screen with breathing glow animation"
    impact: none
    approved: true
  - type: scope-change
    description: "Home screen simplified to single burdah button (Arabic + English title) navigating directly to reveal, skipping list screen"
    impact: none
    approved: true
---

## Summary

Wired the complete navigation flow end-to-end using go_router with Provider-based DI and gentle fade transitions. The app now presents a single gold button (Arabic and English title) on the home screen that navigates directly to a transitional reveal experience before opening the PDF reader.

## What Was Built

### Task 1: Core Navigation (commit 323d558)
- `lib/router/app_router.dart` — GoRouter with 4 fade-transitioned routes (/, /burdahs, /burdahs/:id, /burdahs/:id/reveal)
- `lib/screens/home_screen.dart` — Minimal home with gold CTA button
- `lib/screens/burdah_list_screen.dart` — Burdah list sourced from repository via Provider
- `lib/widgets/burdah_list_row.dart` — ListTile row with RTL Arabic title
- `lib/main.dart` — Provider<BurdahRepository> wrapping app root
- `lib/app.dart` — Switched to MaterialApp.router

### Task 2: Transitional Reveal (commit d1833a8)
- `lib/screens/burdah_reveal_screen.dart` — 2-second reveal with fade-in/glow/fade-out
- `lib/widgets/transitional_reveal_image.dart` — Reusable animation widget
- `lib/data/models/burdah.dart` — Added optional transitionImageAsset field
- `assets/images/khadija_resting_place.jpeg` — Moved from project root
- `assets/data/burdah_catalog.json` — Added transitionImageAsset to khadija-ra entry
- `pubspec.yaml` — Added flutter_animate dependency and assets/images/ registration

### Task 3: User-Directed Refinements (commit d333bf6)
- Reveal screen: added salaam greeting (Arabic/transliteration/English) below image
- Reveal animation: separated effects — image gets 40% saturation boost, text gets breathing golden-cream glow
- Reveal timing: extended to ~4 seconds (600ms fade-in, 800ms ramp, 2000ms breathing hold, 600ms fade-out)
- Home screen: simplified to single gold button with Arabic + English title, navigates directly to reveal

## Key Files Created

- `lib/router/app_router.dart`
- `lib/screens/home_screen.dart`
- `lib/screens/burdah_list_screen.dart`
- `lib/screens/burdah_reveal_screen.dart`
- `lib/widgets/burdah_list_row.dart`
- `lib/widgets/transitional_reveal_image.dart`
- `assets/images/khadija_resting_place.jpeg`

## Self-Check: PASSED

- All routes use CustomTransitionPage with FadeTransition
- Provider DI wired at app root, no direct repository instantiation in screens
- pushReplacement used for reveal→reader (back skips reveal)
- context.mounted guard present before navigation after animation
- flutter analyze: zero issues
- Verified on Pixel 8 emulator: full flow works end-to-end
