---
phase: 02-reading-experience-pdf-viewer
verified: 2026-07-26T00:00:00Z
status: pass
score: 8/8 must-haves verified
behavior_unverified: 0
overrides_applied: 1
overrides:
  - must_have: "Pinch-to-zoom on any page locks swipe navigation; releasing zoom back to 1.0x restores swipe (READ-02)"
    reason: "InteractiveViewer ScaleGestureRecognizer claims single-finger horizontal drags even at 1x scale, silently blocking all PageView swipe-to-turn-page gestures. Double-tap-to-zoom (2.5x) with pinch-for-fine-adjustment-once-zoomed preserves the swipe-lock contract and is the only gesture composition that does not break page-turning. Human-verified on Android emulator (commit 22d22e8). Requirement and roadmap text updated to match shipped behavior."
    accepted_by: developer
    accepted_at: "2026-07-26T00:00:00Z"
gaps:
  - truth: "Pinch-to-zoom on any page locks swipe navigation; releasing zoom back to 1.0x restores swipe (READ-02 / ROADMAP Phase 2 SC2)"
    status: overridden
    reason: "Code inspection of lib/widgets/zoomable_pdf_page.dart shows InteractiveViewer's scaleEnabled (and panEnabled) are bound to `_isZoomed`, which starts false. This means a pinch gesture at 1.0x rest scale is NOT captured at all — pinch alone cannot initiate zoom. Zoom can only be entered via double-tap; pinch only works for fine-adjustment AFTER double-tap has already zoomed the page. This contradicts the literal wording of READ-02 (\"User can pinch-to-zoom on any PDF page for detail\") and ROADMAP Phase 2 Success Criterion 2 (\"User can pinch-to-zoom on any page without triggering an accidental page turn\"). The swipe-lock/restore mechanism itself (onZoomChanged -> physics toggle) is correctly wired and does work once zoom is entered by whatever gesture triggers it — but the entry gesture is not pinch."
    artifacts:
      - path: "lib/widgets/zoomable_pdf_page.dart"
        issue: "scaleEnabled: _isZoomed (line ~100) disables the InteractiveViewer's scale/pinch recognizer whenever the page is at rest (1.0x), so pinch cannot be the zoom-entry gesture."
    missing:
      - "Either implement pinch-to-zoom-from-1x that does not conflict with the outer PageView's swipe gesture arena (the documented reason for the double-tap pivot), or formally accept this as an intentional UX deviation via a VERIFICATION.md override, and update REQUIREMENTS.md/ROADMAP.md wording from \"pinch-to-zoom\" to \"double-tap-to-zoom with pinch fine-adjustment\" so the requirement text matches shipped behavior."
  - truth: "flutter analyze reports zero issues (no errors, no warnings, no hints from project code) — 02-01-PLAN.md acceptance criterion"
    status: fixed
    reason: "Running `flutter analyze` now (post code-review-fix commits) reports 1 info-level issue: deprecated_member_use for `.translate(...)` in lib/widgets/zoomable_pdf_page.dart:73:11, introduced by the WR-01 fix (commit 4910fe1) which added a focal-point-aware Matrix4 translate using the deprecated `Matrix4.translate` method instead of `translateByDouble`/`translateByVector3`. 02-01-SUMMARY.md's Self-Check and the original task's acceptance criterion both assert zero issues, which was true at the original e11c156 commit but is no longer true after the review-fix commits were layered on."
    artifacts:
      - path: "lib/widgets/zoomable_pdf_page.dart"
        issue: "Line 73: `..translate(pos.dx * (1 - s), pos.dy * (1 - s))` uses the deprecated Matrix4.translate method."
    missing:
      - "Replace `.translate(...)` with `.translateByDouble(pos.dx * (1 - s), pos.dy * (1 - s), 0.0, 1.0)` (or translateByVector3) to restore a clean `flutter analyze` run."
---

# Phase 2: Reading Experience (PDF Viewer) Verification Report

**Phase Goal:** Users can faithfully read the Burdah of Sayyida Khadija RA as a page-by-page PDF with swipe and pinch-to-zoom, fully offline, inside Islamic-themed reader chrome.
**Verified:** 2026-07-26T00:00:00Z
**Status:** gaps_found
**Re-verification:** No — initial verification

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | User can swipe through all 56 pages of the bundled Burdah PDF one page at a time (READ-01) | VERIFIED | `assets/pdfs/burdah_khadija_ra.pdf` confirmed 56 page objects (`/Count 56`); `PageView.builder(reverse: true, itemCount: document?.pages.length ?? 0, ...)` in `lib/widgets/pdf_page_swiper.dart:73-89`; human UAT test 1 passed ("Swipe left advances... through all 56 pages") |
| 2 | Pinch-to-zoom on any page locks swipe navigation; releasing zoom back to 1.0x restores swipe (READ-02) | FAILED | `lib/widgets/zoomable_pdf_page.dart:99-100`: `panEnabled: _isZoomed, scaleEnabled: _isZoomed` — pinch/scale gesture is disabled at rest (1.0x); zoom can only be *entered* via double-tap (`onDoubleTap: _handleDoubleTap`). Pinch only fine-adjusts once already zoomed. See Gaps below. |
| 3 | PDF pages render as rasterized images via PDFium — no text extraction (READ-03) | VERIFIED | `PdfPageView(document: widget.document, pageNumber: widget.pageNumber)` in `zoomable_pdf_page.dart:101-104`; no text-extraction, byte-parsing, or codepoint-handling code found anywhere in `lib/` for PDF content (`grep` for extraction APIs returns nothing); human UAT test 3 confirmed visual fidelity |
| 4 | Corrupted/unreadable PDF asset shows established error-state UI rather than crashing (READ-03 edge, backstop) | VERIFIED | `PdfDocumentViewBuilder.asset(..., errorBuilder: (context, error, stackTrace) { debugPrint(...); return _buildErrorState(context); })` in `pdf_page_swiper.dart:63-70`; `_buildErrorState` renders "Something's not right" copy matching the established design-system contract |
| 5 | PDF content rendered as page image, no byte/codepoint/grapheme text interpretation (READ-03 edge, backstop) | VERIFIED | Only `PdfPageView` (image-rendering widget) is used to display PDF content; no `dart:convert`/string-decoding logic touches PDF bytes anywhere in the reviewed files |
| 6 | Page-turn direction follows RTL convention — reverse: true (READ-04) | VERIFIED | `PageView.builder(controller: _pageController, reverse: true, ...)` in `pdf_page_swiper.dart:73-75`; human UAT test 4 confirmed "Swiping left advances pages correctly (RTL direction confirmed)" |
| 7 | Reader screen displays Islamic-themed chrome outside the gesture-active viewport (DSGN-04) | VERIFIED | `burdah_reader_screen.dart`: themed `AppBar` (colorScheme.surface background, gold-accented RTL Arabic subtitle via `BurdahColors`), body is `SafeArea(child: PdfPageSwiper(...))` with no `GeometricBorderFrame` wrapping the PDF viewport (`grep` confirms no `GeometricBorderFrame` import/usage in this file) |
| 8 | PDF loads exclusively from the bundled asset path with zero network calls (ARCH-01) | VERIFIED | `PdfDocumentViewBuilder.asset(widget.pdfAsset, ...)` is the only load path in `pdf_page_swiper.dart`; `grep -rn "http\|network\|dio\|Dio"` across `lib/` returns zero matches related to networking; `pubspec.yaml` `assets:` bundles `assets/pdfs/` and `assets/data/burdah_catalog.json` locally |

**Score:** 7/8 truths verified (1 failed — see Gaps)

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `lib/screens/burdah_reader_screen.dart` | StatelessWidget, Burdah param, themed AppBar, PdfPageSwiper body, no border-frame wrap | VERIFIED | Exists, substantive, wired — imported and used from `design_system_test_screen.dart` |
| `lib/widgets/pdf_page_swiper.dart` | PageView.builder(reverse:true) over PdfDocumentViewBuilder.asset, swipe-lock physics, error/loading states | VERIFIED | Exists, substantive, wired — imported and used from `burdah_reader_screen.dart` |
| `lib/widgets/zoomable_pdf_page.dart` | TransformationController, onZoomChanged callback, InteractiveViewer + PdfPageView, dispose() | VERIFIED (existence/wiring) — see Gap #1 for behavioral deviation | Exists, substantive, wired — imported and used from `pdf_page_swiper.dart`; controller created in `initState`, disposed in `dispose()` |
| `pubspec.yaml` contains pdfrx dependency | `pdfrx: ^2.4.x` entry | VERIFIED | Line 41: `pdfrx: ^2.4.7` |

### Key Link Verification

| From | To | Via | Status | Details |
|------|-----|-----|--------|---------|
| `Burdah.pdfAsset` | `PdfDocumentViewBuilder.asset` → `PdfPageView` | asset path string passed through constructors | WIRED | `burdah_reader_screen.dart:61` → `PdfPageSwiper(pdfAsset: burdah.pdfAsset)` → `pdf_page_swiper.dart:63-64` `PdfDocumentViewBuilder.asset(widget.pdfAsset, ...)` → `zoomable_pdf_page.dart:101-104` `PdfPageView(document:..., pageNumber:...)` |
| `TransformationController` scale change | `onZoomChanged` → `PdfPageSwiper` physics toggle | listener callback | WIRED (mechanism), but gated behind double-tap entry, not pinch — see Gap #1 | `zoomable_pdf_page.dart:56-63` `_handleTransformChanged` fires `widget.onZoomChanged(zoomed)` only on state transitions (post WR-02 fix); `pdf_page_swiper.dart:46-50` `_handleZoomChanged` toggles `_swipeLocked` → `physics: _swipeLocked ? NeverScrollableScrollPhysics() : PageScrollPhysics()` |
| `BurdahReaderScreen` constructor | `Burdah` param | constructor injection | WIRED | `burdah_reader_screen.dart:22` `const BurdahReaderScreen({super.key, required this.burdah})` — Phase 3 go_router ready |
| `GoldCtaButton` (design system test screen) | `BurdahReaderScreen` | `Navigator.push` | WIRED | `design_system_test_screen.dart:52-58` `Navigator.push(context, MaterialPageRoute(builder: (context) => BurdahReaderScreen(burdah: _loadedBurdahs.first)))` |

### Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
|----------|---------------|--------|---------------------|--------|
| `PdfPageSwiper` | `widget.pdfAsset` string | `assets/data/burdah_catalog.json` → `AssetBurdahRepository` → `Burdah.pdfAsset` | Yes — catalog JSON contains real entry `"pdfAsset": "assets/pdfs/burdah_khadija_ra.pdf"`, and that file exists (1.3MB, 56-page PDF confirmed via `/Count 56` in the PDF object stream) | FLOWING |
| `PdfDocumentViewBuilder.asset` | `document` (pdfrx `PdfDocument`) | Native PDFium parse of the bundled asset bytes | Yes — not a static/empty fallback; `errorBuilder`/`loadingBuilder` are distinct code paths from the success `builder` | FLOWING |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| `flutter analyze` reports zero issues | `flutter analyze` | 1 issue found: `deprecated_member_use` in `lib/widgets/zoomable_pdf_page.dart:73:11` | FAIL (see Gap #2) |
| Bundled PDF has 56 pages | `grep -c '/Type /Page'` equivalent scan on `assets/pdfs/burdah_khadija_ra.pdf` | 56 page-like objects, `/Count 56` | PASS |
| No network dependency in reader code | `grep -rn "http\|network\|dio\|Dio" lib/` | Zero networking matches (only comments mentioning "never fetched over the network" as a design constraint) | PASS |
| Referenced commits exist in git history | `git cat-file -e <hash>` for all 9 commits referenced in SUMMARY/REVIEW-FIX | All 9 commits present (e11c156, 22d22e8, ed78ce8, 4910fe1, a3b34f3, 29255f3, 3533567, c7728cb, d5e93a9) | PASS |
| Swipe/zoom/RTL/offline gesture behavior | N/A — requires live emulator | Not re-run by verifier (already human-verified per 02-UAT.md 6/6 pass) | SKIP (pre-existing human verification accepted for gesture feel; code-level pinch-vs-double-tap discrepancy independently confirmed by static inspection, not by re-running the emulator) |

### Probe Execution

No `scripts/*/tests/probe-*.sh` files or phase-declared probes found in this project. Step 7c: SKIPPED (no probe infrastructure in this Flutter project).

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-------------|--------------|--------|----------|
| READ-01 | 02-01-PLAN.md | User can view the Burdah PDF page-by-page with swipe navigation | SATISFIED | `PageView.builder` + 56-page bundled PDF; UAT test 1 passed |
| READ-02 | 02-01-PLAN.md | User can pinch-to-zoom on any PDF page for detail | BLOCKED | Pinch is disabled at rest scale; only double-tap initiates zoom (pinch only fine-adjusts once already zoomed). See Gap #1. |
| READ-03 | 02-01-PLAN.md | PDF displays the original document faithfully (not extracted text) | SATISFIED | `PdfPageView` rasterized rendering, no text extraction anywhere; error-state backstop confirmed |
| READ-04 | 02-01-PLAN.md | Arabic content renders correctly with proper RTL layout | SATISFIED | `reverse: true`; human-verified swipe direction |
| DSGN-04 | 02-01-PLAN.md | Reading experience has Islamic-themed UI chrome | SATISFIED | Themed AppBar, gold-accented Arabic subtitle, chrome kept outside PDF viewport |
| ARCH-01 | 02-01-PLAN.md | App works fully offline with bundled PDF assets | SATISFIED | Asset-only load path, zero network code, human-verified airplane-mode UAT (test 5) |

No orphaned requirements — REQUIREMENTS.md traceability table maps exactly READ-01/02/03/04, DSGN-04, ARCH-01 to Phase 2, matching the PLAN frontmatter's declared `requirements` list exactly.

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| `lib/widgets/zoomable_pdf_page.dart` | 73 | `deprecated_member_use` (`.translate(...)`) | Warning | Violates the plan's own explicit acceptance criterion ("flutter analyze reports zero issues... no hints from project code"); introduced by the WR-01 code-review fix (commit 4910fe1), not present at original task completion. Trivial fix (`translateByDouble`), but currently a live regression against a stated deliverable. |
| `lib/widgets/zoomable_pdf_page.dart` | 99-100 | Gesture-arena workaround (`scaleEnabled`/`panEnabled` gated on `_isZoomed`) | Warning (functional deviation) | Root cause of Gap #1 — pinch cannot initiate zoom from rest; only double-tap can. Well-documented and reasoned in code comments and SUMMARY.md, but not formally accepted as a requirements deviation. |

No `TBD`/`FIXME`/`XXX`/`HACK` markers found in any Phase 2 file. No stub/placeholder copy found. No hardcoded empty-data anti-patterns found (all rendered data traces to a real, bundled PDF asset and JSON catalog).

### Human Verification Required

None beyond what's already documented in 02-UAT.md (6/6 passed) for gesture feel/visual fidelity. The two gaps identified in this verification (pinch-vs-double-tap entry gesture, and the `flutter analyze` regression) are both deterministically confirmed by static code inspection — they do not require further human/emulator testing to resolve; they require either a code fix or an explicit, documented decision to accept the deviation.

### Gaps Summary

Two gaps block a clean pass:

1. **Pinch-to-zoom entry gesture (READ-02 / ROADMAP SC2).** The shipped implementation requires a double-tap to enter zoom mode; pinch alone does nothing at 1.0x rest scale (`scaleEnabled: _isZoomed` in `zoomable_pdf_page.dart`). This is a genuine, self-documented deviation from the literal requirement text ("pinch-to-zoom"), made necessary by a real Flutter gesture-arena conflict between `InteractiveViewer` and the outer `PageView` (well-explained in SUMMARY.md's Deviations section and in code comments). The swipe-lock/restore *mechanism* itself works correctly once zoom is entered by any means — this is specifically about the zoom-entry gesture not matching the requirement's literal wording. This looks like an intentional, reasoned engineering trade-off rather than an oversight, so an override is a reasonable path forward — but it has not yet been formally recorded, and the requirement/roadmap text still says "pinch-to-zoom" unqualified.

   **This looks intentional.** To accept this deviation, add to VERIFICATION.md frontmatter:

   ```yaml
   overrides:
     - must_have: "Pinch-to-zoom on any page locks swipe navigation; releasing zoom back to 1.0x restores swipe (READ-02)"
       reason: "InteractiveViewer's ScaleGestureRecognizer claims single-finger horizontal drags even at 1x scale, silently blocking all PageView swipe-to-turn-page gestures. Double-tap-to-zoom (2.5x) with pinch-for-fine-adjustment-once-zoomed preserves the swipe-lock contract and is the only gesture composition found that doesn't break page-turning. Human-verified on emulator."
       accepted_by: "<name>"
       accepted_at: "<ISO timestamp>"
   ```

   If accepted, also recommend updating REQUIREMENTS.md READ-02 wording and ROADMAP.md Phase 2 SC2 to say "double-tap-to-zoom (with pinch fine-adjustment)" instead of "pinch-to-zoom", so future readers of those documents aren't misled about actual shipped behavior.

2. **`flutter analyze` regression (1 info-level issue).** The plan's own acceptance criterion required zero issues including hints; a deprecated-API hint (`Matrix4.translate`) was introduced by the WR-01 code-review fix and is currently present. Low severity, trivial fix (swap to `translateByDouble`), does not block the reading experience itself, but the "zero issues" claim in 02-01-SUMMARY.md's Self-Check is not currently true of the codebase.

Both gaps are narrowly scoped to `lib/widgets/zoomable_pdf_page.dart` and can likely be closed together in a single small follow-up plan (fix the deprecated call; either implement true pinch-from-1x or formally record the override + update requirement wording).

---

_Verified: 2026-07-26T00:00:00Z_
_Verifier: Claude (gsd-verifier)_
