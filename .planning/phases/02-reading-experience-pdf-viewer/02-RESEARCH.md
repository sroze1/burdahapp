# Phase 2: Reading Experience (PDF Viewer) - Research

**Researched:** 2026-07-25
**Domain:** Flutter PDF rendering (pdfrx/PDFium), gesture composition (swipe + pinch-zoom), RTL page-turn semantics
**Confidence:** MEDIUM

## Summary

Phase 2 delivers a book-like, page-by-page PDF reader for the bundled `burdah_khadija_ra.pdf` (56 pages, 1.3 MB, ~419×595pt portrait pages, no encryption, embedded fonts including Arabic-shaping fonts like Nabi/Aref Ruqaa/Lotus Linotype). The Phase 1 stack decision (`pdfrx ^2.4.7`) is confirmed current on the pub.dev registry (`2.4.7`, published 2026-07-09) and already present in `01-RESEARCH.md`'s package audit — this phase adds it to `pubspec.yaml` for the first time (it is **not yet a dependency**; `pdfrx` is absent from the current `pubspec.yaml`).

The critical architectural decision this research surfaces: `pdfrx` ships two distinct widgets with different jobs. `PdfViewer` is a continuous pan/zoom document viewer (Google-Photos-style), while `PdfPageView` is a single-page render widget meant to be composed inside your own scrollable (`PageView`/`ListView`). The phase's success criteria describe discrete "swipe left/right to turn a page, book-like" behavior with a hard requirement that pinch-zoom locks swipe and releases on reset — this is the classic Flutter "photo gallery" composition (`PageView.builder` + per-page zoom widget + `TransformationController`-driven physics lock), not `PdfViewer`'s built-in continuous-scroll+zoom mode. Plan for **`PageView.builder` + `PdfDocumentViewBuilder.asset` + `PdfPageView`**, not the top-level `PdfViewer` widget alone.

RTL page-turn direction (success criterion #3) is a real, easy-to-invert risk: Flutter's own `PageView.reverse` API docs confirm `reverse: true` flips scroll direction to right-to-left for `Axis.horizontal`. This must be set explicitly and verified visually — it is not automatic from ambient `Directionality` alone.

**Primary recommendation:** Add `pdfrx: ^2.4.7` to `pubspec.yaml`; build the reader as `PageView.builder(reverse: true, ...)` wrapping `PdfDocumentViewBuilder.asset(burdah.pdfAsset, builder: ...)` + `PdfPageView` per page, each page wrapped in a zoom-capable widget whose `TransformationController` toggles the outer `PageView`'s `physics` between normal and `NeverScrollableScrollPhysics` while `scale > 1.0`. Wrap the whole reader screen (not the individual page viewport) in `GeometricBorderFrame`/chrome so the border never competes with mid-screen swipe/pinch gesture area.

## User Constraints

No `02-CONTEXT.md` exists for this phase — `/gsd-discuss-phase` has not yet run for Phase 2. This research proceeds from `ROADMAP.md`'s phase description and success criteria only. Nothing here should be read as a locked user decision; the planner (or a subsequent discuss-phase pass) should confirm the RTL swipe-direction assumption and the border-chrome-vs-viewport tradeoff called out below before locking the plan.

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| READ-01 | User can view the Burdah of Sayyida Khadija RA as a page-by-page PDF with swipe navigation | Architecture Patterns (`PageView.builder` + `PdfPageView` composition); Standard Stack (`pdfrx`) |
| READ-02 | User can pinch-to-zoom on any PDF page for detail | Architecture Patterns (per-page `InteractiveViewer`/zoom + `TransformationController` swipe-lock pattern); Common Pitfalls #1 |
| READ-03 | PDF displays the original document faithfully (not extracted text) | Standard Stack rationale (PDFium-backed rendering, no text extraction); PDF metadata inventory below (embedded fonts, exact page size) |
| READ-04 | Arabic content renders correctly with proper RTL layout | Architecture Patterns (RTL page-turn direction via `PageView.reverse`); Common Pitfalls #2 |
| DSGN-04 | Reader screen has Islamic-themed UI chrome (geometric borders, styled navigation) | Architecture Patterns (chrome-vs-viewport placement of `GeometricBorderFrame`); reuses Phase 1 design system widgets directly |
| ARCH-01 | App works fully offline with bundled PDF assets | Architecture Patterns (`PdfDocumentViewBuilder.asset`/`PdfViewer.asset` — no network path); Environment Availability |
</phase_requirements>

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| PDF page rendering (rasterization via PDFium) | Client (Flutter/native plugin) | — | `pdfrx` renders through PDFium natively on-device; no server/CDN involved — pure client-tier, offline by construction |
| Page-turn (swipe) navigation | Client (Flutter widget tree) | — | Discrete `PageView` index state is local UI state, not app-wide state; no `provider`/`go_router` involvement needed inside the reader itself |
| Pinch-zoom / gesture-lock state | Client (Flutter widget tree) | — | Per-page `TransformationController` + physics toggle is local widget state scoped to the currently visible page |
| Reader screen chrome (geometric border, app bar) | Client (Flutter widget tree) | — | Reuses Phase 1's `GeometricBorderFrame`/theme extension — pure presentation, no new tier |
| Catalog → PDF asset path resolution | Client (data/repository layer, from Phase 1) | — | `Burdah.pdfAsset` is already resolved by `AssetBurdahRepository`; this phase only consumes it, does not add a new data-access tier |
| Route/screen entry point for the reader | Client (Flutter widget tree now; `go_router` in Phase 3) | — | Phase 2 builds the reader as a standalone widget; Phase 3 wires it into `go_router` per NAV-01–03. Build the widget to accept a `Burdah` (or `pdfAsset` string) constructor param now so Phase 3 slots it into a `GoRoute` builder without rework |

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| `pdfrx` | 2.4.7 [VERIFIED: pub.dev registry API, queried 2026-07-25 — `latest.version: "2.4.7"`, `published: 2026-07-09`] | PDF rendering via PDFium, page-level widgets (`PdfPageView`, `PdfDocumentViewBuilder`) | Same recommendation already locked in Phase 1's `01-RESEARCH.md` (publisher `espresso3389.jp` verified, actively maintained, MIT-style license). Renders via PDFium — the same engine Chrome uses — giving pixel-faithful reproduction of the original document (READ-03), not text extraction. |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `flutter` SDK `PageView`/`PageView.builder` | bundled with Flutter 3.44.8 [VERIFIED: `flutter --version` on this machine] | Discrete, snap-to-page horizontal scrolling with `reverse` support for RTL page order | Use as the outer swipe container; do not use `pdfrx`'s own `PdfViewer` for the primary page-turn interaction — that widget is built for continuous pan/zoom browsing, not discrete book-style page turns |
| `flutter` SDK `InteractiveViewer` / `TransformationController` | bundled with Flutter 3.44.8 | Per-page pinch-to-zoom with a controller you can inspect to detect `scale > 1.0` | Wrap each `PdfPageView` in this (or use `pdfrx`'s built-in per-page zoom if `PdfPageView` exposes it — verify the exact API at implementation time against the pinned `2.4.7` version) so zoom state can drive the outer `PageView`'s physics lock |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Custom `PageView` + `PdfPageView` composition | `pdfrx`'s top-level `PdfViewer` widget directly | `PdfViewer` gives continuous scroll+zoom with less code, but does not natively express "one page fills the viewport, swipe turns to the next page" — an open GitHub issue on the `pdfrx` repo (#170, "PageView Horizontal Scrolling") shows this exact gap has been raised by other users and marked a duplicate of prior discussion, implying it's a known, previously-addressed request rather than a first-class built-in mode. [CITED: github.com/espresso3389/pdfrx/issues/170] |
| `pdfrx` | `pdfx`, `syncfusion_flutter_pdfviewer` | Already assessed and rejected in Phase 1's `01-RESEARCH.md` Alternatives table — no new information changes that call for this phase. |

**Installation:**
```bash
flutter pub add pdfrx
```
This is the **first time** `pdfrx` is added — it is currently absent from `pubspec.yaml` (only `cupertino_icons`, `provider`, `google_fonts`, `flutter_svg`, `go_router` are present as of Phase 1 completion).

**Version verification:** Confirmed directly against the pub.dev registry API (`GET https://pub.dev/api/packages/pdfrx`) on 2026-07-25: latest version `2.4.7`, published 2026-07-09 — consistent with Phase 1's audit (`^2.4.7`, "published 14 days ago" as of 2026-07-24). No newer version has shipped since Phase 1 locked this dependency; safe to proceed with `^2.4.7`.

## Package Legitimacy Audit

> Note on tooling: `gsd-tools query package-legitimacy check` only supports `--ecosystem npm|pypi|crates`; this is a Dart/pub.dev package, so the automated seam could not run. Verification below was performed manually against the pub.dev registry API and cross-referenced against Phase 1's already-completed audit of the same package (`01-RESEARCH.md` Package Legitimacy Audit table, verdict `OK`/Approved).

| Package | Registry | Age | Downloads/Popularity | Source Repo | Verdict | Disposition |
|---------|----------|-----|----------------------|--------------|---------|-------------|
| `pdfrx` | pub.dev | Published 2026-07-09 (this release); package itself established, publisher `espresso3389.jp` verified per Phase 1 audit | 336 likes / 160 pub points (per Phase 1 audit, 2026-07-24) | github.com/espresso3389/pdfrx (confirmed reachable, README fetched directly during this research) | OK | Approved — already approved once in Phase 1; re-confirmed current here |

**Packages removed due to [SLOP] verdict:** none
**Packages flagged as suspicious [SUS]:** none

*No new packages beyond `pdfrx` are required for this phase's success criteria. `PageView`, `InteractiveViewer`, and `TransformationController` are Flutter SDK widgets, not external packages — no legitimacy audit applies to them.*

## Architecture Patterns

### System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│ Burdah Reader Screen (new, Phase 2)                                 │
│                                                                       │
│  Burdah (from Phase 1 repository) ──▶ pdfAsset: String path         │
│         │                                                            │
│         ▼                                                            │
│  PdfDocumentViewBuilder.asset(pdfAsset)  ── loads PDFium document    │
│         │  (offline, from app asset bundle — no network, ARCH-01)   │
│         ▼                                                            │
│  builder: (context, document) ──▶                                   │
│         │                                                            │
│         ▼                                                            │
│  PageView.builder(                                                  │
│    reverse: true,              ◄── RTL page-turn direction (READ-04)│
│    itemCount: document.pages.length,                                │
│    physics: <normal> | NeverScrollableScrollPhysics  ◄── zoom lock  │
│    itemBuilder: (context, index) ──▶                                │
│  )                                                                   │
│         │                                                            │
│         ▼                                                            │
│  Per-page zoom wrapper (InteractiveViewer + TransformationController)│
│         │  onInteractionUpdate ──▶ track current scale               │
│         │  scale > 1.0 ──▶ lock outer PageView physics (READ-02)     │
│         │  scale reset to 1.0 ──▶ release outer PageView physics    │
│         ▼                                                            │
│  PdfPageView(document: document, pageNumber: index + 1)             │
│         │  renders via PDFium — pixel-faithful, no text extraction  │
│         ▼                                                            │
│  Rendered page (Arabic calligraphy + layout intact, READ-03)        │
│                                                                       │
│  Wrapping the ENTIRE screen (not the swipe/zoom viewport):           │
│  GeometricBorderFrame (Phase 1 design system) ──▶ Islamic chrome    │
│  (DSGN-04) — kept outside the gesture-active area so the border     │
│  never competes with edge-swipe or pinch-zoom hit-testing.          │
└─────────────────────────────────────────────────────────────────────┘
```

### Recommended Project Structure
```
lib/
├── screens/
│   └── burdah_reader_screen.dart   # new — takes a Burdah (or pdfAsset path) constructor param
├── widgets/
│   ├── pdf_page_swiper.dart        # new — PageView.builder + PdfDocumentViewBuilder composition
│   └── zoomable_pdf_page.dart      # new — per-page InteractiveViewer/TransformationController + swipe-lock callback
├── data/                            # unchanged, reused from Phase 1
│   ├── models/burdah.dart
│   └── repositories/asset_burdah_repository.dart
└── theme/                           # unchanged, reused from Phase 1
```

### Pattern 1: Page-by-page swiper via `PdfDocumentViewBuilder` + `PageView.builder`
**What:** Load the PDF document once via `PdfDocumentViewBuilder.asset`, then drive a `PageView.builder` (not `ListView.builder`, despite the official README example using `ListView.builder` for a vertically-scrolling demo) so pages snap one-at-a-time on horizontal swipe.
**When to use:** This is the primary reader pattern for READ-01.
**Example:**
```dart
// Source: pdfrx official README (github.com/espresso3389/pdfrx),
// adapted from ListView.builder to PageView.builder for discrete
// book-like page turns. [CITED: raw README example verified via WebFetch]
PdfDocumentViewBuilder.asset(
  burdah.pdfAsset,
  builder: (context, document) => PageView.builder(
    reverse: true, // RTL page order — verify direction on-device (READ-04)
    itemCount: document?.pages.length ?? 0,
    physics: swipeLocked
        ? const NeverScrollableScrollPhysics()
        : const PageScrollPhysics(),
    itemBuilder: (context, index) => ZoomablePdfPage(
      document: document!,
      pageNumber: index + 1,
      onZoomChanged: (isZoomed) => setState(() => swipeLocked = isZoomed),
    ),
  ),
)
```

### Pattern 2: Swipe-lock during pinch-zoom
**What:** Wrap each `PdfPageView` in an `InteractiveViewer` (or `pdfrx`'s equivalent per-page zoom capability — confirm exact API surface against the pinned `2.4.7` version at implementation time, since the fetched documentation excerpts did not conclusively show whether `PdfPageView` has built-in zoom vs. requiring an outer `InteractiveViewer`). Track scale via a `TransformationController`; when scale exceeds `1.0`, notify the parent to switch the outer `PageView`'s `physics` to `NeverScrollableScrollPhysics`; when the user resets zoom back to `1.0` (e.g., double-tap-to-reset or pinch back down), release the lock.
**When to use:** Required for success criterion #2 — "swipe locked while zoomed, released on reset."
**Example:**
```dart
// General Flutter composition pattern (photo-gallery style), not
// pdfrx-specific — cross-referenced against a community writeup on
// resolving PageView/pinch-zoom gesture conflicts.
// [ASSUMED: composition validated by generic Flutter gesture-conflict
// pattern, not a pdfrx-documented API — verify TransformationController
// approach directly against pdfrx 2.4.7's actual widget tree at
// implementation time; fall back to the simpler "lock on >1 active
// pointer" technique below if TransformationController scale tracking
// conflicts with pdfrx's internal gesture detector.]
final controller = TransformationController();
controller.addListener(() {
  final scale = controller.value.getMaxScaleOnAxis();
  onZoomChanged(scale > 1.01); // small epsilon to avoid float jitter
});
InteractiveViewer(
  transformationController: controller,
  minScale: 1.0,
  maxScale: 4.0,
  child: PdfPageView(document: document, pageNumber: pageNumber),
)
```

### Pattern 3: RTL page-turn direction
**What:** Explicitly set `PageView.reverse: true` for `Axis.horizontal` scroll direction so that swiping follows Arabic book convention (page 1 at the "start"/right side, forward progression moves right-to-left).
**When to use:** Required for success criterion #3.
**Example:**
```dart
// Source: Flutter official API docs, PageView.reverse
// (api.flutter.dev/flutter/widgets/PageView/reverse.html):
// "if scrollDirection is Axis.horizontal, then the page view scrolls
// from left to right when reverse is false and from right to left
// when reverse is true." [CITED: api.flutter.dev]
PageView.builder(reverse: true, /* ... */)
```
**Critical caveat:** this is a UX-sensitive, easy-to-invert detail. Treat as a verification checkpoint, not a fire-and-forget flag — see Common Pitfalls #2 and the Assumptions Log.

### Anti-Patterns to Avoid
- **Using `pdfrx`'s `PdfViewer` widget as the primary swipe surface:** `PdfViewer` is built for continuous pan/zoom document browsing (like a PDF desktop viewer), not discrete book-style page turns. Retrofitting it to snap one page per swipe fights the widget's design intent — use the `PageView` + `PdfPageView` composition instead.
- **Wrapping the swipe/zoom gesture area in `GeometricBorderFrame`:** the border frame insets its child by a fixed padding and is designed to frame static content (per Phase 1's `01-PATTERNS.md`), not to sit directly under active pinch/swipe touch targets. Apply it to the screen chrome (app bar area, outer margin) rather than around the `PageView` itself, or the border's own gesture area could intercept edge swipes meant for page-turning.
- **Hardcoded `left`/`right` in the reader screen's own layout:** per CLAUDE.md's "What NOT to Use" table and Phase 1's established convention, use `EdgeInsetsDirectional`/`AlignmentDirectional` for any chrome (app bar actions, page-number indicator) added around the PDF viewport.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| PDF page rasterization | Custom PDFium bindings or a hand-rolled renderer | `pdfrx`'s `PdfPageView` / `PdfDocument` | PDFium is a large, security-sensitive native library (font parsing, embedded-object handling); `pdfrx` already wraps it correctly across Android/iOS with an actively maintained plugin |
| Text extraction from the Arabic calligraphic PDF | Any OCR/text-extraction pipeline | Nothing — out of scope per `REQUIREMENTS.md` ("Out of Scope: Text extraction from PDF — accuracy uncertain for Arabic calligraphic text") | Explicitly excluded; rendering the page as an image (not extracting glyphs) is the whole point of READ-03 |
| Pinch-zoom gesture math | Custom `GestureDetector`-based scale/pan tracking | `InteractiveViewer` + `TransformationController` | Flutter SDK's `InteractiveViewer` already handles multi-touch scale/pan physics, momentum, and boundary clamping correctly; hand-rolling this reintroduces well-known gesture-conflict bugs |

**Key insight:** Everything this phase needs is either already in the Flutter SDK (`PageView`, `InteractiveViewer`) or already vetted in Phase 1's stack decision (`pdfrx`). The only genuinely new composition work is wiring these three together correctly — there is no case here for a new third-party dependency beyond `pdfrx` itself.

## Common Pitfalls

### Pitfall 1: Zoom-lock state leaking across pages
**What goes wrong:** If swipe-lock state (`swipeLocked`/current scale) is tracked in the reader screen's top-level state rather than scoped per visible page, zooming in on page N and then somehow paging away (or the state not resetting) leaves the `PageView` locked or unlocked incorrectly on a different page.
**Why it happens:** `PageView.builder` recycles/rebuilds page widgets; a shared top-level "isZoomed" boolean can go stale if not reset on page change.
**How to avoid:** Reset zoom (and the lock flag) on `PageController.page` change (via a `PageController` listener or `onPageChanged`), and ensure each page's `TransformationController` is independent (e.g., keyed by page index, not a single shared controller).
**Warning signs:** Swiping to a new page while a previous page was zoomed in leaves the new page's swipe locked, or a freshly zoomed page doesn't lock the swipe at all.

### Pitfall 2: RTL page-turn direction inverted from user expectation
**What goes wrong:** `reverse: true` flips the *scroll* direction, but "which physical swipe gesture means 'next page'" for an Arabic book is a UX judgment call, not a pure technical fact — different reference apps disagree on whether "swipe left" or "swipe right" should feel like "turn to the next page" for RTL content. Getting this backwards is the kind of bug that looks fine to the developer (who wrote the code and knows the mapping) but immediately reads as "broken" to any Arabic-literate user opening the app.
**Why it happens:** The Flutter-level fact (`reverse: true` reverses scroll direction) is verified [CITED: api.flutter.dev], but the *product* fact (which swipe = "forward" in this specific reading context) is not something a documentation lookup can settle — it needs a human holding the device.
**How to avoid:** Treat this as an explicit UAT checkpoint per `STATE.md`'s existing Phase 2 blocker note ("PDF memory/gesture behavior... requires explicit device UAT, not simulator-only testing"). Have the plan include a manual verification step: open the reader, confirm page 1 (of 56) displays first, and confirm the swipe gesture that feels like "turning to the next page of an Arabic book" actually advances the page index forward.
**Warning signs:** Page order feels correct in isolation but "backwards" when compared side-by-side to a physical Arabic book or a reference app (e.g., a Quran app).

### Pitfall 3: Full-screen chrome fighting edge-swipe gesture area
**What goes wrong:** If `GeometricBorderFrame`'s content inset (24px per Phase 1's `01-UI-SPEC.md`) is applied directly around the `PageView`, the border's own `Stack`/`Positioned.fill` SVG layer sits visually behind the content but the *padding* around it still eats into the swipe-active area at the screen edges, and OS-level system-gesture zones (iOS edge-swipe-back, Android nav-gesture zones) can additionally conflict with a full-bleed horizontal `PageView`.
**Why it happens:** Phase 1's border frame was designed for static content (cards, test screens), not an interactive full-screen swiper — this is new territory this phase introduces.
**How to avoid:** Apply `GeometricBorderFrame` to the reader's outer chrome (e.g., around an `AppBar`-adjacent decorative margin, or as a static frame that does not overlay the live gesture area) rather than wrapping the `PageView` itself. Test edge-swipe behavior on both Android (back gesture) and iOS (edge-swipe-back) once a physical/simulator device is available.
**Warning signs:** Swiping near the left/right edge of the screen triggers system back-navigation instead of a page turn, or the border SVG visibly clips/overlaps the PDF page content.

### Pitfall 4: Large PDF memory pressure from eager rendering
**What goes wrong:** Rendering all 56 pages eagerly (e.g., via a non-lazy list) can spike memory, especially on lower-end Android devices, even though this specific PDF is small (1.3 MB total, ~419×595pt pages).
**Why it happens:** PDFium-based renderers rasterize each page to a bitmap at render time; holding many rendered bitmaps in memory simultaneously (rather than just the visible + adjacent pages) is a documented OOM vector in other Flutter PDF viewers (e.g., reported `OutOfMemoryError` issues in `syncfusion_flutter_pdfviewer`'s issue tracker for *large* PDFs). [ASSUMED: general PDFium-based-viewer pattern, not confirmed against this specific PDF/device combination — this project's PDF is far smaller than the OOM-triggering cases found, so risk is LOW but not zero on constrained devices.]
**How to avoid:** Rely on `PageView.builder`'s lazy `itemBuilder` (only builds visible + `allowImplicitScrolling`-adjacent pages) rather than a pre-built list of all 56 `PdfPageView` widgets. Do not manually pre-cache all pages.
**Warning signs:** Noticeable jank or memory growth in DevTools while rapidly swiping through many pages in a row.

## Code Examples

Verified patterns from official sources:

### Loading a bundled PDF asset (offline, ARCH-01)
```dart
// Source: pdfrx official README (raw.githubusercontent.com/espresso3389/pdfrx/master/packages/pdfrx/README.md)
// [CITED: official README, fetched directly 2026-07-25]
PdfViewer.asset('assets/hello.pdf') // simplest case — full continuous viewer

// For the page-by-page reader this phase needs, use the lower-level
// builder instead (adapted to PageView per Architecture Pattern 1 above):
PdfDocumentViewBuilder.asset(
  'asset/test.pdf',
  builder: (context, document) => /* PageView.builder(...) — see Pattern 1 */,
)
```

### Existing Phase 1 pattern this phase must reuse (theme-consumed chrome)
```dart
// Source: lib/widgets/geometric_border_frame.dart (already in this repo)
final borderStroke = Theme.of(context).extension<BurdahColors>()!.borderStroke;
// Apply GeometricBorderFrame to the reader's chrome layer, per Anti-Patterns above —
// not directly around the PageView.
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|---------------|--------|
| Platform-specific PDF renderers (iOS `PDFKit` bridge, Android `PdfRenderer` bridge, separately maintained per-platform) | Single PDFium-backed plugin (`pdfrx`) rendering identically across platforms | Ongoing trend as of 2026 in the Flutter PDF-viewer ecosystem (already noted in Phase 1's `01-RESEARCH.md`) | Guarantees the "faithful to the original document" requirement (READ-03) renders pixel-identically regardless of target OS |

**Deprecated/outdated:**
- `PdfViewerParams.minScale`/`maxScale` in `pdfrx` are marked deprecated in favor of a `sizeDelegateProvider`-based approach per the fetched API docs — confirm exact current API against the pinned `2.4.7` release at implementation time rather than copying older `pdfrx` tutorials that reference `minScale`/`maxScale` directly. [CITED: pub.dev API docs, `PdfViewerParams` class page]

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | `PdfPageView` requires an external `InteractiveViewer` wrapper for pinch-zoom (rather than exposing built-in zoom itself) | Architecture Patterns, Pattern 2 | If `PdfPageView`/`PdfDocumentViewBuilder` actually has built-in zoom, the planner may end up double-wrapping zoom handling (one from `pdfrx`, one from `InteractiveViewer`), causing gesture conflicts. Verify the exact `2.4.7` API surface (via `flutter pub deps` + local package docs, or the `example/viewer/` app in the `pdfrx` repo) before finalizing the plan's task breakdown. |
| A2 | Swiping "right-to-left" (with `reverse: true`) is the UX-correct "turn to next page" direction for this Arabic content | Architecture Patterns, Pattern 3; Common Pitfalls #2 | If the assumption is backwards, users will experience the reader as feeling "wrong"/mirrored even though it technically works — this needs a human UAT check, not just a code review, before shipping. |
| A3 | OOM risk from this specific 56-page/1.3MB PDF is low even without aggressive memory-management tuning | Common Pitfalls #4 | If wrong (e.g., an emulator/low-end device still shows jank), the plan should add explicit page-disposal/virtualization tuning as a task rather than assuming `PageView.builder`'s default laziness is sufficient. |
| A4 | `TransformationController`-based scale tracking (as opposed to the alternative "lock on >1 active pointer" technique found in a community writeup) is compatible with `pdfrx`'s internal gesture detection and won't be swallowed/intercepted by `pdfrx`'s own widget tree | Architecture Patterns, Pattern 2 | If `pdfrx` internally consumes pointer/scale events before they reach a wrapping `InteractiveViewer`'s controller, the swipe-lock logic silently never triggers — this should be smoke-tested early in implementation, not assumed to "just work" from the pattern alone. |

## Open Questions

1. **Does `pdfrx 2.4.7`'s `PdfPageView` expose any zoom/scale capability of its own?**
   - What we know: The package's top-level `PdfViewer` widget clearly supports pan/zoom (via `InteractiveViewer`-style params in `PdfViewerParams`). The fetched documentation excerpts did not confirm or deny whether the lower-level `PdfPageView` widget has any zoom behavior when used standalone (outside `PdfViewer`).
   - What's unclear: Whether wrapping `PdfPageView` in an external `InteractiveViewer` is additive (fine) or conflicting (fights with an internal gesture recognizer).
   - Recommendation: First implementation task should include a quick spike — render a single `PdfPageView` wrapped in `InteractiveViewer` and confirm pinch-zoom works cleanly before building the full `PageView.builder` composition around it.

2. **Should the geometric border frame appear on the reader screen at all, given the fullscreen/immersive nature of page-turning?**
   - What we know: DSGN-04 requires "Islamic geometric border/chrome styling from the Phase 1 design system" on the reader screen.
   - What's unclear: Whether "chrome" here means a persistent decorative border around the whole screen (competing with gesture space, per Pitfall 3) or a lighter treatment (e.g., a styled app bar + corner ornamentation) that leaves the PDF viewport fully unencumbered.
   - Recommendation: Default to a **lighter chrome treatment** (styled app bar, geometric accents at screen edges outside the swipe-active zone) rather than the full `GeometricBorderFrame` wrap used in Phase 1's test screen. Flag this for discuss-phase/UI-SPEC confirmation before locking the plan's UI details.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter SDK | All of Phase 2 | ✓ | 3.44.8 (stable) | — |
| Dart SDK | All of Phase 2 | ✓ | 3.12.2 | — |
| Android toolchain (SDK, emulator) | Primary dev/test target | ✓ | Android SDK 36.0.0; emulator "sdk gphone16k arm64" running Android 17 (API 37) | — |
| Xcode / iOS toolchain | iOS build+test of the reader | ✗ | Xcode installation incomplete on this machine | Consistent with `STATE.md`'s existing Phase 1 deferral ("iOS verification deferred") — develop and verify primarily on Android this phase; iOS-specific PDF-rendering/gesture verification must be explicitly re-run once Xcode is completed, before Phase 2 is considered fully done cross-platform (ARCH-02 is a Phase 1 requirement, not Phase 2, but PDF rendering fidelity should still be sanity-checked on iOS eventually) |
| Physical mid-range Android/iOS device | Gesture-timing and memory-pressure UAT (`STATE.md` blocker: "requires explicit device UAT, not simulator-only testing") | ✗ | Only an Android **emulator** is currently connected (`flutter devices` — no physical device) | No perfect fallback — emulator testing can proceed for logic/functional verification, but the STATE.md-documented blocker around real-device gesture/memory behavior remains open. Plan should include an explicit manual verification task once a physical device is available, not just emulator-based automated checks. |

**Missing dependencies with no fallback:**
- Physical mid-range device for gesture/memory UAT — emulator testing is a partial substitute, not equivalent, for the OOM and swipe-vs-zoom-timing concerns `STATE.md` already flags for this phase.

**Missing dependencies with fallback:**
- Xcode/iOS toolchain — fallback is Android-first development and testing this phase, matching the project's existing iOS-deferral pattern from Phase 1.

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-------------------|
| V2 Authentication | No | No auth in this app (per `REQUIREMENTS.md` Out of Scope: "User accounts/login") |
| V3 Session Management | No | Not applicable — no sessions |
| V4 Access Control | No | Not applicable — single-user local app |
| V5 Input Validation | Yes | The reader receives `Burdah.pdfAsset` (already validated non-empty/typed in Phase 1's `Burdah.fromJson`) and must handle `PdfDocument` load failure (corrupted/unreadable asset) with a defined error state — reuse the existing "Something's not right" copy pattern already established in `design_system_test_screen.dart`, per Phase 1's Security Domain precedent, rather than letting a load failure crash the screen uncaught |
| V6 Cryptography | No | PDF is not encrypted (confirmed via `pdfinfo`: `Encrypted: no`) and no crypto operations occur in this phase |

### Known Threat Patterns for this stack

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|----------------------|
| Malformed/corrupted PDF asset causing an uncaught exception on load | Denial of Service (crash) | Wrap `PdfDocumentViewBuilder`'s document-load path in error handling; show the app's existing error-state UI copy rather than an unhandled exception. Low residual risk here since the PDF is bundled at build time (not attacker-controlled at runtime) — same reasoning already applied to `pdfAsset` path traversal in Phase 1's threat table. |
| Native PDFium parsing vulnerabilities (memory-safety bugs in the underlying C++ PDF parser) | Tampering / Information Disclosure | Out of this project's direct control — mitigated by staying current on `pdfrx` version updates (which bundle PDFium updates) rather than pinning indefinitely. Not exploitable via user-supplied input in v1 since the only PDF loaded is the bundled, developer-controlled asset. |

## Sources

### Primary (HIGH confidence)
- None — no Context7/premium documentation MCP provider was available in this session (all `config` flags false in `.planning/config.json`: `brave_search`, `firecrawl`, `exa_search`, `tavily_search`, `ref_search`, `perplexity`, `jina` all disabled; `mcp__context7__*` tools were not available in this runtime either). All findings below are capped at MEDIUM confidence per the source hierarchy.

### Secondary (MEDIUM confidence)
- pdfrx official README, fetched directly via WebFetch from `raw.githubusercontent.com/espresso3389/pdfrx/master/packages/pdfrx/README.md` on 2026-07-25 — `PdfViewer.asset`/`PdfDocumentViewBuilder.asset`/`PdfPageView` code examples
- pdfrx `PdfViewerParams` API docs, `pub.dev/documentation/pdfrx/latest/pdfrx/PdfViewerParams-class.html`, fetched via WebFetch 2026-07-25 — gesture/zoom parameter names, deprecated `minScale`/`maxScale` note
- Flutter official API docs, `api.flutter.dev/flutter/widgets/PageView/reverse.html` — `reverse` parameter direction semantics for `Axis.horizontal`
- pub.dev registry API (`GET https://pub.dev/api/packages/pdfrx`, `GET https://pub.dev/api/packages/go_router`), queried directly via `curl` 2026-07-25 — current version/publish-date verification
- Local environment probes (`flutter --version`, `flutter doctor`, `flutter devices`, `pdfinfo`/`pdffonts` against the bundled PDF) — VERIFIED first-hand on this machine, 2026-07-25

### Tertiary (LOW confidence)
- WebSearch results on gesture-conflict resolution patterns (Medium article on `PageView`/pinch-zoom pointer-count technique) — general Flutter pattern, not `pdfrx`-specific, not independently cross-checked against an official source
- WebSearch/WebFetch summaries of `pdfrx` GitHub issue #170 ("PageView Horizontal Scrolling") — issue marked duplicate but the referenced original discussion was not independently located/read in this session
- WebSearch results on Flutter PDF-viewer OOM patterns (drawn from `syncfusion_flutter_pdfviewer` issue tracker, a different package) — directionally relevant to PDFium-based rendering in general, not confirmed against `pdfrx` or this project's specific PDF

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH for the `pdfrx`/version fact itself (VERIFIED via pub.dev registry API); MEDIUM overall since exact widget composition (`PdfPageView` vs `PdfViewer`) relies on WebFetch-sourced docs, not a live Context7 lookup
- Architecture: MEDIUM — core composition pattern (`PageView` + per-page zoom + physics lock) is a well-established generic Flutter pattern, but its specific interaction with `pdfrx`'s internal gesture handling is unverified (see Open Question 1 / Assumption A1/A4)
- Pitfalls: MEDIUM — RTL direction pitfall is CITED against official Flutter docs; OOM and chrome-placement pitfalls are reasoned from adjacent (non-`pdfrx`) evidence and flagged LOW/ASSUMED accordingly

**Research date:** 2026-07-25
**Valid until:** 2026-08-24 (30 days — Flutter/pdfrx ecosystem moves roughly monthly per Phase 1's own research notes; re-verify `pdfrx` version at plan/execution time if this window has passed)
