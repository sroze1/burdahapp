---
phase: 02-reading-experience-pdf-viewer
plan: 01
subsystem: ui
tags: [flutter, pdfrx, pdfium, pageview, interactiveviewer, gesture, rtl]

# Dependency graph
requires:
  - phase: 01-foundation-data-architecture-design-system
    provides: Burdah data model (id/title/titleArabic/pdfAsset/sortOrder), AssetBurdahRepository, BurdahColors theme extension, design system test screen conventions
provides:
  - Page-by-page PDF reader (BurdahReaderScreen) rendering the bundled Burdah PDF via PDFium
  - Double-tap-to-zoom gesture pattern with swipe-lock, reusable for any future PdfPageView-backed content
  - Constructor-injected screen ready for Phase 3 go_router wiring (accepts Burdah directly)
affects: [03-navigation-primary-user-flow]

# Tech tracking
tech-stack:
  added: [pdfrx ^2.4.7]
  patterns:
    - "PageView.builder(reverse:true) + PdfDocumentViewBuilder.asset + PdfPageView composition for book-like swipe reading (not pdfrx's top-level PdfViewer)"
    - "Double-tap-to-zoom (not continuous pinch-from-1x) via TransformationController + AnimationController, with InteractiveViewer's panEnabled/scaleEnabled gated on zoom state to avoid gesture-arena conflicts with the outer PageView"
    - "PdfDocumentViewBuilder's built-in errorBuilder/loadingBuilder used directly for load-failure and loading states, rather than a null-document + connectionState heuristic"

key-files:
  created:
    - lib/widgets/zoomable_pdf_page.dart
    - lib/widgets/pdf_page_swiper.dart
    - lib/screens/burdah_reader_screen.dart
  modified:
    - pubspec.yaml
    - pubspec.lock
    - lib/screens/design_system_test_screen.dart

key-decisions:
  - "Confirmed via direct pdfrx 2.4.7 source read (pub cache) that PdfPageView has no built-in zoom API — resolves RESEARCH.md Assumption A1 in favor of the external InteractiveViewer wrapper approach"
  - "Used PdfDocumentViewBuilder.asset's built-in errorBuilder/loadingBuilder params (discovered in source) instead of the plan's null-document heuristic — cleaner, package-native error/loading handling"
  - "Post-checkpoint deviation: switched from continuous pinch-to-zoom-from-1x to double-tap-to-zoom, because InteractiveViewer's ScaleGestureRecognizer claimed single-finger horizontal drags even at 1x scale and silently blocked all PageView swipe gestures (see Deviations)"

patterns-established:
  - "Reader/content screens accept their domain model (Burdah) via constructor, never re-fetch from the repository internally — keeps route wiring trivial for Phase 3's go_router"
  - "Gesture-conflicting widgets (InteractiveViewer over PageView) must gate their own gesture recognizers off entirely at rest state (panEnabled/scaleEnabled = false) rather than relying on scale-tracking alone to arbitrate the gesture arena"

requirements-completed: [READ-01, READ-02, READ-03, READ-04, DSGN-04, ARCH-01]

coverage:
  - id: D1
    description: "User can swipe through all 56 pages of the bundled Burdah PDF one page at a time"
    requirement: "READ-01"
    verification:
      - kind: manual_procedural
        ref: "02-01-PLAN.md checkpoint task — human verification on Android emulator (sdk gphone16k arm64)"
        status: pass
    human_judgment: true
    rationale: "Swipe feel/correctness on a real device/emulator requires human confirmation; flutter analyze cannot verify gesture UX."
  - id: D2
    description: "Zoom (now double-tap-triggered, not continuous pinch-from-1x) locks swipe navigation; exiting zoom restores swipe"
    requirement: "READ-02"
    verification:
      - kind: manual_procedural
        ref: "02-01-PLAN.md checkpoint task — human verification on Android emulator, post-gesture-conflict-fix (commit 22d22e8)"
        status: pass
    human_judgment: true
    rationale: "Gesture-lock behavior (double-tap in/out, swipe locked while zoomed) requires interactive human confirmation, not just static analysis."
  - id: D3
    description: "PDF pages render as rasterized images via PDFium — no text extraction, original Arabic calligraphy preserved"
    requirement: "READ-03"
    verification:
      - kind: manual_procedural
        ref: "02-01-PLAN.md checkpoint task — human visual verification of page 1 rendering"
        status: pass
    human_judgment: true
    rationale: "Visual fidelity of rendered calligraphy is a human judgment call, not machine-verifiable."
  - id: D4
    description: "Page-turn direction follows RTL convention — swipe left advances forward"
    requirement: "READ-04"
    verification:
      - kind: manual_procedural
        ref: "02-01-PLAN.md checkpoint task — user confirmed: 'Swiping left advances pages correctly (RTL direction confirmed)'"
        status: pass
    human_judgment: true
    rationale: "This was RESEARCH.md's highest-risk item (Pitfall 2) — explicitly called for human UAT, not a code-level check."
  - id: D5
    description: "Reader screen displays Islamic-themed chrome (styled AppBar, gold-accented Arabic subtitle) outside the gesture-active viewport"
    requirement: "DSGN-04"
    verification:
      - kind: unit
        ref: "flutter analyze — zero issues; grep confirms no GeometricBorderFrame wrapping PdfPageSwiper"
        status: pass
      - kind: manual_procedural
        ref: "02-01-PLAN.md checkpoint task — human visual verification of AppBar chrome"
        status: pass
    human_judgment: false
  - id: D6
    description: "PDF loads exclusively from the bundled asset path with zero network calls"
    requirement: "ARCH-01"
    verification:
      - kind: unit
        ref: "flutter analyze + code review — PdfDocumentViewBuilder.asset(widget.pdfAsset) is the only load path, no http/network imports in new files"
        status: pass
    human_judgment: true
    rationale: "Airplane-mode re-open was listed as an optional checkpoint step in 02-01-PLAN.md; the user's approval covered the checklist as a whole but did not explicitly restate this step. Code-level check (asset-only load path, no network dependency) passes; flag for confirmation if airplane-mode behavior is ever observed to differ."

# Metrics
duration: 65min
completed: 2026-07-25
status: complete
---

# Phase 2 Plan 1: Reading Experience (PDF Viewer) Summary

**Page-by-page Burdah PDF reader built on pdfrx/PDFium with PageView.builder + double-tap-to-zoom gesture composition, RTL page order, and Islamic-themed AppBar chrome.**

## Performance

- **Duration:** ~65 min (task 1 implementation + verification, spanning a human checkpoint pause)
- **Started:** 2026-07-25T17:54:26Z
- **Completed:** 2026-07-25T20:59:00Z
- **Tasks:** 2 (1 tracer/auto + 1 checkpoint:human-verify)
- **Files modified:** 6 (3 created, 3 modified)

## Accomplishments
- Added `pdfrx ^2.4.7` and built the full PDF reading experience as a single vertical slice: `ZoomablePdfPage` (per-page zoom), `PdfPageSwiper` (swipe composition + error/loading states), `BurdahReaderScreen` (themed chrome + Phase-3-ready constructor)
- Confirmed via direct package source inspection that `PdfPageView` has no built-in zoom, resolving an open research question before it became a runtime surprise
- Wired temporary navigation from the Phase 1 design system test screen (`GoldCtaButton` → `BurdahReaderScreen`) for end-to-end verification
- Human-verified on Android emulator: RTL swipe direction correct, zoom/swipe-lock working, PDF renders faithfully — after a post-checkpoint gesture-conflict fix (see Deviations)

## Task Commits

Each task was committed atomically:

1. **Task 1: End-to-end PDF reading — swipe, zoom-lock, RTL, Islamic chrome** - `e11c156` (feat)
2. **Task 2: Checkpoint — verify PDF reading experience on emulator** - human-verify checkpoint, approved with follow-up fix - `22d22e8` (fix, applied during checkpoint pause)

**Plan metadata:** _(this commit)_ (docs: complete plan)

## Files Created/Modified
- `lib/widgets/zoomable_pdf_page.dart` - Per-page zoom wrapper; double-tap to enter/exit zoom, pinch/pan for fine adjustment once zoomed, reports zoom state to parent
- `lib/widgets/pdf_page_swiper.dart` - PageView.builder(reverse:true) over PdfDocumentViewBuilder.asset, physics locks on zoom, resets lock on page change, error/loading states via pdfrx's native builders
- `lib/screens/burdah_reader_screen.dart` - Reader screen: themed AppBar (title + gold-accented Arabic subtitle), SafeArea, full-bleed PdfPageSwiper body, accepts `Burdah` constructor param
- `lib/screens/design_system_test_screen.dart` - `GoldCtaButton` now navigates to `BurdahReaderScreen` with the first loaded burdah (temporary Phase 1 → Phase 2 wiring, replaced by go_router in Phase 3)
- `pubspec.yaml` / `pubspec.lock` - Added `pdfrx: ^2.4.7` and its resolved dependency tree

## Decisions Made
- Used `PdfDocumentViewBuilder.asset`'s built-in `errorBuilder`/`loadingBuilder` (found by reading the pinned package source) instead of the plan's null-document + `connectionState` heuristic — same "Something's not right" copy, cleaner integration with pdfrx's own document-load lifecycle.
- Confirmed `PdfPageView` (pdfrx 2.4.7) exposes no zoom of its own — `InteractiveViewer` wrapping is correct and necessary, not redundant (resolves RESEARCH.md Assumption A1 / Open Question 1).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed InteractiveViewer/PageView gesture-arena conflict blocking all page-turn swiping**
- **Found during:** Task 2 checkpoint — discovered during interactive human verification on the Android emulator, after the initial checkpoint request was issued
- **Issue:** The plan's original design (Task 1, action step 2) wrapped every page in an always-active `InteractiveViewer` (pinch-to-zoom live from 1x scale). In practice, `InteractiveViewer`'s `ScaleGestureRecognizer` claimed single-finger horizontal drag gestures even at 1x scale (not just when actively zoomed), which put it in the same gesture arena as the outer `PageView` and silently swallowed swipe-to-turn-page gestures. This was not anticipated by RESEARCH.md's Assumption A4 spike recommendation, which focused on scale-tracking correctness, not gesture-arena precedence at rest.
- **Fix:** Rebuilt `ZoomablePdfPage`'s gesture model: `InteractiveViewer`'s `panEnabled`/`scaleEnabled` are now both `false` whenever the page is not zoomed, making `InteractiveViewer` fully passive and letting `PageView` own all single-finger gestures. Zoom is now entered/exited via **double-tap** (animated to 2.5x and back, via `TransformationController` + `AnimationController`), and once zoomed, pinch/pan are enabled for fine adjustment. The `onZoomChanged` swipe-lock contract to `PdfPageSwiper` is unchanged.
- **Files modified:** `lib/widgets/zoomable_pdf_page.dart`
- **Verification:** Human-verified on the Android emulator post-fix — user confirmed "Double-tap zoom in/out works" and "Swipe locks while zoomed" in the checkpoint approval.
- **Committed in:** `22d22e8`

**Note on must_haves impact:** The plan's must-have truth "Pinch-to-zoom on any page locks swipe navigation; releasing zoom back to 1.0x restores swipe (READ-02)" is still satisfied in spirit and in the swipe-lock mechanism — the trigger to *enter* zoom changed from continuous pinch-from-1x to double-tap (pinch still works for fine adjustment once zoomed), because the originally-specified continuous-pinch approach was gesture-arena-incompatible with the outer swipe `PageView`. This is a UX-level change worth a quick look if a future phase revisits reader interactions.

---

**Total deviations:** 1 auto-fixed (1 bug)
**Impact on plan:** Necessary correctness fix — without it, swipe-to-turn-page did not work at all at 1x zoom. No scope creep; the fix stayed entirely within `zoomable_pdf_page.dart` and preserved the existing `onZoomChanged` contract with `PdfPageSwiper`.

## Issues Encountered
- `InteractiveViewer` claiming single-finger swipe gestures at 1x scale was not surfaced by `flutter analyze` or the automated acceptance criteria — only interactive human testing on the emulator caught it. This validates RESEARCH.md's original caution (Open Question 1 / Assumption A4) that pdfrx/Flutter gesture composition needed a live device check, not just a code review.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- `BurdahReaderScreen` already accepts a `Burdah` constructor parameter and has zero dependency on `AssetBurdahRepository` internally — Phase 3's `go_router` wiring (NAV-01–03) can slot it directly into a `GoRoute` builder without rework.
- The temporary `GoldCtaButton` → `Navigator.push` wiring in `design_system_test_screen.dart` should be removed or left as-is (harmless dead-end) once Phase 3 replaces it with the real navigation flow.
- No blockers for Phase 3.

---
*Phase: 02-reading-experience-pdf-viewer*
*Completed: 2026-07-25*
