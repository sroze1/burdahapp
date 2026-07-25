---
phase: 02-reading-experience-pdf-viewer
fixed_at: 2026-07-25T23:55:00Z
review_path: .planning/phases/02-reading-experience-pdf-viewer/02-REVIEW.md
iteration: 1
findings_in_scope: 6
fixed: 6
skipped: 0
status: all_fixed
---

# Phase 02: Code Review Fix Report

**Fixed at:** 2026-07-25T23:55:00Z
**Source review:** .planning/phases/02-reading-experience-pdf-viewer/02-REVIEW.md
**Iteration:** 1

**Summary:**
- Findings in scope: 6 (WR-01 through WR-06 — fix_scope: critical_warning, 0 Critical findings existed)
- Fixed: 6
- Skipped: 0

Note: this run's first action was completing an interrupted cleanup from a
prior fixer invocation. That prior run had already committed WR-01, WR-02,
and WR-03 correctly but was interrupted before its `git worktree remove` /
branch fast-forward step, leaving an orphan worktree, an orphan branch, and
a stale recovery sentinel. This run recovered that state (fast-forwarded
`master` to capture the three pre-existing commits, removed the orphan
worktree and branch, cleared the sentinel) before fixing the remaining
findings (WR-04, WR-05, WR-06) in its own fresh worktree.

## Fixed Issues

### WR-01: Double-tap zoom always anchors on the top-left corner, not the tap location

**Files modified:** `lib/widgets/zoomable_pdf_page.dart`
**Commit:** `4910fe1`
**Applied fix:** Captured the tap position via `onDoubleTapDown` into a new `_doubleTapPosition` field, and rewrote `_handleDoubleTap`'s zoom-in branch to build a focal-point-aware `Matrix4` (translate toward the tap point before scaling) instead of a pure origin-anchored scale.
**Status:** Fixed by a prior interrupted run; verified correct and recovered onto `master` in this run.

### WR-02: `onZoomChanged` callback fires on every transform frame, not just on state transitions

**Files modified:** `lib/widgets/zoomable_pdf_page.dart`
**Commit:** `a3b34f3`
**Applied fix:** Moved the `widget.onZoomChanged(zoomed)` call inside the `if (_isZoomed != zoomed)` guard so it only fires on actual zoom-state transitions, matching its documented contract.
**Status:** Fixed by a prior interrupted run; verified correct and recovered onto `master` in this run.

### WR-03: PDF/catalog load errors are silently discarded with no logging

**Files modified:** `lib/widgets/pdf_page_swiper.dart`, `lib/screens/design_system_test_screen.dart`
**Commit:** `29255f3`
**Applied fix:** Added `debugPrint` calls in the `errorBuilder` (PDF load failure, including stack trace) and in the `FutureBuilder`'s `hasError` branch (catalog load failure), preserving the existing user-facing error UI.
**Status:** Fixed by a prior interrupted run; verified correct and recovered onto `master` in this run.

### WR-04: Force-unwrapped `ThemeExtension` lookup risks a crash with no fallback

**Files modified:** `lib/screens/burdah_reader_screen.dart`, `lib/screens/design_system_test_screen.dart`
**Commit:** `3533567`
**Applied fix:** Replaced `Theme.of(context).extension<BurdahColors>()!` in both screens with a null-safe lookup: read into `themeBurdahColors`, `assert` it is non-null (surfaces a theme-configuration bug immediately in debug builds), then fall back to the existing `BurdahColors.light` static constant if null so a release build never crashes on a missing extension.

### WR-05: Arabic subtitle in the AppBar has no overflow protection inside a fixed-height slot

**Files modified:** `lib/screens/burdah_reader_screen.dart`
**Commit:** `c7728cb`
**Applied fix:** Added `maxLines: 1` and `overflow: TextOverflow.ellipsis` to the Arabic title `Text` widget inside the 32px `PreferredSize` AppBar slot, preventing overflow/clipping for longer or diacritic-heavy titles.

### WR-06: State field mutated as a side effect inside a `FutureBuilder` builder callback

**Files modified:** `lib/screens/design_system_test_screen.dart`
**Commit:** `d5e93a9`
**Applied fix:** Removed the `_loadedBurdahs = burdahs;` assignment (and its justifying comment) from inside the `FutureBuilder`'s `builder` callback. The future is now chained with `.then((burdahs) => _loadedBurdahs = burdahs)` in `initState`, so the assignment happens once as a genuine side effect outside the build phase, restoring build purity.

## Skipped Issues

None — all six in-scope warnings were fixed.

---

_Fixed: 2026-07-25T23:55:00Z_
_Fixer: Claude (gsd-code-fixer)_
_Iteration: 1_
