# BurdahApp

## What This Is

A beautiful Islamic poetry reading app for Android and iOS, built with Flutter. It presents a curated collection of Burdah poems in an elegant Turkish/Ghazali-inspired geometric design, starting with the Burdah of Sayyida Khadija RA. The app opens with an animated Bismillah splash screen accompanied by Qari Abdul Basit's recitation.

## Core Value

Users can read Burdah poems in a beautiful, distraction-free experience that honors the sacred nature of the texts.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] Animated splash screen with "Bismillahirrahmaanirraheem" text animation
- [ ] Splash audio: first 6.1 seconds of Qari Abdul Basit's Al-Fatiha recitation
- [ ] Smooth fade transition from splash to main screen
- [ ] Main screen with prominent "Burdah" button
- [ ] Burdah list page showing available burdah poems
- [ ] Burdah of Sayyida Khadija RA as first entry
- [ ] Page-by-page PDF viewer with swipe navigation (book-like reading)
- [ ] Pinch-to-zoom on PDF pages
- [ ] Islamic geometric design with Turkish/Ghazali color palette
- [ ] Calligraphic typography throughout
- [ ] Works on both Android (Play Store) and iOS (App Store)
- [ ] Architecture extensible for adding more burdahs in the future

### Out of Scope

- Scrollable text extraction from PDF — accuracy uncertain, defer to future
- Audio playback of burdah recitations — not requested for v1
- User accounts or login — not needed
- In-app purchases or monetization — not applicable
- Search within burdah text — future enhancement
- Bookmarking or highlighting — future enhancement

## Context

- The PDF content is in Arabic with the title: "بردة أم المؤمنين سيدتنا خديجة المسماة المكنز المكنون والدر المصون في سيرة صاحبة المعلاة وساكنة الحجون"
- The splash audio file is "Surah Al-Fatiha By Qari Abdul Basit 'Abd us-Samad.mp3" — only the first 6.1 seconds (Bismillah portion) will be used
- The user does not have mobile development tools installed — environment setup is part of the project
- Design inspiration: Turkish/Ghazali Islamic geometric patterns, think turquoise, deep blue, gold, burgundy tones with ornamental geometric borders
- The app should feel reverent and elegant, matching the sacred nature of the content

## Constraints

- **Platform**: Flutter — single codebase for Android + iOS
- **Content format**: PDF viewing (not text extraction) for accuracy
- **Audio**: Pre-trimmed 6.1s clip bundled with app
- **RTL support**: Arabic content requires right-to-left layout support
- **Extensibility**: Data structure must support adding more burdahs without code changes

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Flutter over React Native | Best for custom animations, beautiful UI, single codebase, excellent PDF libraries | — Pending |
| PDF viewer over text extraction | Preserves original calligraphy/layout; text extraction accuracy uncertain | — Pending |
| Page-by-page over scroll | Book-like reading experience more appropriate for sacred poetry | — Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-07-24 after initialization*
