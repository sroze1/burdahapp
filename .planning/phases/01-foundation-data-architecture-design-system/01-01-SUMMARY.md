---
phase: 01-foundation-data-architecture-design-system
plan: 01
status: checkpoint
started: 2026-07-24T00:00:00Z
completed: null
requirements_covered: [ARCH-02, ARCH-03, DSGN-02, DSGN-03]
---

## Summary

Walking skeleton for BurdahApp: scaffolded the Flutter project, wired the data layer (JSON catalog → repository → typed model), built the complete theme system (light and dark with Islamic green/gold/cream tokens), bundled calligraphic Arabic fonts offline, and created a design system test screen proving the full architecture end-to-end.

## Self-Check: PASSED

- flutter analyze: No issues found (zero errors)
- Burdah catalog JSON loads with khadija-ra entry
- Both light and dark ThemeData wired in MaterialApp
- GoogleFonts.config.allowRuntimeFetching = false set before runApp
- All 4 font files bundled (ScheherazadeNew Regular/Bold, Amiri Regular/Bold)
- PDF asset renamed to ASCII filename
- All 4 asset directories registered in pubspec.yaml

## What Was Built

### key-files.created
- lib/main.dart — App entry point with offline font config
- lib/app.dart — MaterialApp with light/dark theme
- lib/theme/app_colors.dart — Static hex color constants
- lib/theme/app_theme_extension.dart — BurdahColors ThemeExtension
- lib/theme/app_text_theme.dart — Typography with Scheherazade New and Amiri
- lib/theme/app_theme.dart — ThemeData assembly for both modes
- lib/data/models/burdah.dart — Burdah data model with fromJson
- lib/data/repositories/burdah_repository.dart — Abstract repository interface
- lib/data/repositories/asset_burdah_repository.dart — JSON-loading implementation
- lib/screens/design_system_test_screen.dart — Verification test screen
- assets/data/burdah_catalog.json — Burdah catalog manifest
- assets/pdfs/burdah_khadija_ra.pdf — ASCII-renamed PDF copy

## Deviations

None.

## Checkpoint

Task 2 (human-verify) pending: user must verify Arabic font shaping and color palette on a running device/emulator before this plan can be marked complete.
