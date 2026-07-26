---
phase: 02-reading-experience-pdf-viewer
plan: 02
subsystem: pdf-reader-gesture-handling
tags: [gap-closure, deprecation-fix, verification-override, documentation]
dependency-graph:
  requires:
    - 02-01-SUMMARY.md (ZoomablePdfPage, double-tap-to-zoom implementation)
  provides:
    - Clean flutter analyze baseline (zero issues)
    - Formally-accepted double-tap-to-zoom deviation across REQUIREMENTS/ROADMAP/VERIFICATION
  affects:
    - Phase 2 verification status (gaps_found -> pass)
tech-stack:
  added: []
  patterns:
    - "vector_math Matrix4.translateByDouble(tx, ty, tz, tw) is a 4-arg call (not 3) — mirrors the deprecated translate(x,y,z) internally calling translateByDouble(x,y,z,1.0)"
key-files:
  created: []
  modified:
    - lib/widgets/zoomable_pdf_page.dart
    - .planning/REQUIREMENTS.md
    - .planning/ROADMAP.md
    - .planning/phases/02-reading-experience-pdf-viewer/02-VERIFICATION.md
decisions:
  - "Formally accepted double-tap-to-zoom (not pinch-from-1x) as the shipped READ-02 behavior via a VERIFICATION.md override, rather than re-engineering pinch-from-1x to coexist with PageView's swipe gesture arena"
metrics:
  duration: 8 min
  completed: 2026-07-26
status: complete
---

# Phase 02 Plan 02: Gap Closure — Deprecated API Fix & Deviation Formalization Summary

Fixed a deprecated `Matrix4.translate()` call left over from a prior code-review fix, and formally recorded the intentional double-tap-to-zoom deviation from the original "pinch-to-zoom" requirement wording so Phase 2 verification passes cleanly at 8/8.

## What Was Built

**Task 1 — Deprecated API fix:** Replaced `..translate(pos.dx * (1 - s), pos.dy * (1 - s))` with `..translateByDouble(pos.dx * (1 - s), pos.dy * (1 - s), 0.0, 1.0)` in `lib/widgets/zoomable_pdf_page.dart`'s double-tap zoom animation. `flutter analyze` now reports "No issues found" (previously 1 `deprecated_member_use` info hint).

**Task 2 — Deviation formalization:** Updated three planning artifacts to match shipped behavior (double-tap-to-zoom with pinch fine-adjustment, not continuous pinch-from-1x):
- `.planning/REQUIREMENTS.md` READ-02 text
- `.planning/ROADMAP.md` Phase 2 Success Criterion 2 text
- `.planning/phases/02-reading-experience-pdf-viewer/02-VERIFICATION.md` frontmatter: `status: gaps_found` → `pass`, `score: 7/8` → `8/8`, `overrides_applied: 0` → `1`, added an `overrides` entry with the gesture-arena rationale, and updated both gap entries' `status` fields (`overridden`, `fixed`).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] `translateByDouble` requires 4 positional arguments, not 3**
- **Found during:** Task 1
- **Issue:** The plan's action text specified `translateByDouble(pos.dx * (1 - s), pos.dy * (1 - s), 0.0)` — 3 arguments. Running `flutter analyze` after this exact edit produced a compile error: `4 positional arguments expected by 'translateByDouble', but 3 found`. Inspection of `vector_math`'s `Matrix4` source confirmed `translateByDouble(double tx, double ty, double tz, double tw)` is a 4-arg method, and the deprecated `translate(x, y, z)` it replaces internally forwards to `translateByDouble(x, y, z, 1.0)`.
- **Fix:** Added the missing `tw` argument: `..translateByDouble(pos.dx * (1 - s), pos.dy * (1 - s), 0.0, 1.0)`.
- **Files modified:** `lib/widgets/zoomable_pdf_page.dart`
- **Commit:** 85f5c9e

Or otherwise: no other deviations — Task 2 executed exactly as written.

## Verification Results

- `flutter analyze` → "No issues found!" (zero errors, warnings, info hints)
- `grep -c 'double-tap-to-zoom' .planning/REQUIREMENTS.md .planning/ROADMAP.md` → both files contain the phrase (verify count = 2)
- `.planning/phases/02-reading-experience-pdf-viewer/02-VERIFICATION.md` frontmatter now shows `status: pass`, `score: 8/8 must-haves verified`, `overrides_applied: 1`, with a populated `overrides` array

## Known Stubs

None.

## Self-Check: PASSED

- FOUND: lib/widgets/zoomable_pdf_page.dart (line 73 contains `translateByDouble`)
- FOUND: commit 85f5c9e (fix: deprecated Matrix4.translate)
- FOUND: commit 42a4a30 (docs: formalize deviation)
- FOUND: `.planning/REQUIREMENTS.md` READ-02 line contains "double-tap-to-zoom"
- FOUND: `.planning/ROADMAP.md` Phase 2 SC2 contains "double-tap-to-zoom"
- FOUND: `.planning/phases/02-reading-experience-pdf-viewer/02-VERIFICATION.md` contains `status: pass`, `score: 8/8 must-haves verified`, `overrides_applied: 1`
