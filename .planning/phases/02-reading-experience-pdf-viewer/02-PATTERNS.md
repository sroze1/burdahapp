# Phase 2: Reading Experience (PDF Viewer) - Pattern Map

**Mapped:** 2026-07-25
**Files analyzed:** 3 (new)
**Analogs found:** 3 / 3 (all role-match; no exact prior screen/widget of this type exists yet — this is the first interactive/stateful screen and first non-trivial custom widgets in the codebase)

## Context

This is a small, young Flutter codebase (Phase 1 complete). There is no prior PDF viewer, no prior `PageView`, no prior gesture-driven widget, and no prior `StatefulWidget` screen with local interaction state beyond the throwaway `DesignSystemTestScreen`'s `FutureBuilder`. Analogs below are therefore **role-match, not exact-match** — they establish the project's conventions (theme consumption, error-state copy, `EdgeInsetsDirectional`, doc-comment style, constructor-injection of data) that the new files must follow, not a pre-existing PDF/gesture pattern to literally copy.

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|--------------------|------|-----------|-----------------|----------------|
| `lib/screens/burdah_reader_screen.dart` | screen (route entry point) | request-response (async doc load) + event-driven (page/zoom state) | `lib/screens/design_system_test_screen.dart` | role-match (screen structure, theme consumption, error-state copy) |
| `lib/widgets/pdf_page_swiper.dart` | component (composed widget) | streaming/lazy-render (PageView.builder over PDFium pages) | `lib/widgets/geometric_border_frame.dart` | role-match (widget class shape, theme-driven styling, doc-comment conventions) |
| `lib/widgets/zoomable_pdf_page.dart` | component (gesture/interaction widget) | event-driven (scale/pointer callbacks) | `lib/widgets/gold_cta_button.dart` | role-match (StatelessWidget-with-callback shape; closest to a controller-driven interactive widget) |
| `pubspec.yaml` (modified) | config | — | n/a (see `01-RESEARCH.md`/`CLAUDE.md` install command) | n/a |
| `lib/app.dart` (modified, Phase 3 territory but noted) | provider/route wiring | — | existing `lib/app.dart` | exact (already read; do not touch reader-widget wiring beyond constructor-param readiness per RESEARCH.md) |

## Pattern Assignments

### `lib/screens/burdah_reader_screen.dart` (screen, request-response + event-driven)

**Analog:** `lib/screens/design_system_test_screen.dart`

**Imports pattern** (lines 1-8):
```dart
import 'package:flutter/material.dart';

import '../data/models/burdah.dart';
import '../data/repositories/asset_burdah_repository.dart';
import '../theme/app_theme_extension.dart';
import '../widgets/geometric_border_frame.dart';
import '../widgets/geometric_card_frame.dart';
import '../widgets/gold_cta_button.dart';
```
Follow this relative-import convention (`../data/...`, `../theme/...`, `../widgets/...`) for the reader screen. It will additionally need `../widgets/pdf_page_swiper.dart` and (per RESEARCH.md's constructor-readiness note for Phase 3) accept a `Burdah` in its constructor rather than resolving one internally.

**StatefulWidget scaffold pattern** (lines 17-32):
```dart
class DesignSystemTestScreen extends StatefulWidget {
  const DesignSystemTestScreen({super.key});

  @override
  State<DesignSystemTestScreen> createState() =>
      _DesignSystemTestScreenState();
}

class _DesignSystemTestScreenState extends State<DesignSystemTestScreen> {
  late final Future<List<Burdah>> _burdahsFuture;

  @override
  void initState() {
    super.initState();
    _burdahsFuture = AssetBurdahRepository().getAll();
  }
```
The reader screen should follow this exact `StatefulWidget` + `State` naming/structure convention (`_BurdahReaderScreenState`), but constructor-inject the `Burdah` (per RESEARCH.md Architectural Responsibility Map) instead of resolving the repository itself — the repository-resolution responsibility stays in Phase 1's `AssetBurdahRepository`/upstream caller.

**Theme consumption pattern** (lines 35-37):
```dart
final textTheme = Theme.of(context).textTheme;
final burdahColors = Theme.of(context).extension<BurdahColors>()!;
```
Use identically in the reader screen for any chrome text/colors (app bar title, page-number indicator).

**Error-state copy pattern** (lines 58-81) — REQUIRED for RESEARCH.md's V5 Input Validation control (PDF load failure must not crash uncaught):
```dart
if (snapshot.hasError) {
  // UI-SPEC Copywriting Contract — error state.
  return Padding(
    padding: const EdgeInsetsDirectional.symmetric(vertical: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Something's not right",
          style: textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "This couldn't be loaded. Please restart the "
          'app, or reinstall it if the problem continues.',
          style: textTheme.bodyMedium,
        ),
      ],
    ),
  );
}
```
Wrap `PdfDocumentViewBuilder.asset`'s document-load path (or the outer `FutureBuilder`/error boundary around it) with this exact copy — do not invent new error copy. This satisfies RESEARCH.md's "Malformed/corrupted PDF asset" threat mitigation.

**Directionality/RTL pattern** (lines 137-143, 149-156, 158-164):
```dart
Directionality(
  textDirection: TextDirection.rtl,
  child: Text(
    '...',
    style: textTheme.displaySmall,
  ),
),
```
Any Arabic UI label (e.g., `titleArabic`) on the reader screen's chrome follows this explicit `Directionality` wrap — do not rely on ambient directionality alone, matching RESEARCH.md's caution that `PageView.reverse` also must be set explicitly, not assumed from ambient RTL.

**Padding convention** (used throughout, e.g. line 43, 54, 61-63): always `EdgeInsetsDirectional`, never `EdgeInsets.only(left:/right:)`. Applies directly to CLAUDE.md's "What NOT to Use" table and RESEARCH.md's Anti-Patterns note re: reader chrome layout.

---

### `lib/widgets/pdf_page_swiper.dart` (component, streaming/lazy-render)

**Analog:** `lib/widgets/geometric_border_frame.dart`

**Class shape / doc-comment convention** (lines 1-27):
```dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_theme_extension.dart';

/// Full-screen Islamic star-tessellation border frame (D-05, D-06, D-08).
///
/// Wraps [child] with the star-tessellation pattern rendered from
/// `assets/images/svg/star_tessellation_frame_full.svg`, ...
class GeometricBorderFrame extends StatelessWidget {
  const GeometricBorderFrame({super.key, required this.child});

  final Widget child;

  static const double _contentInset = 24;

  @override
  Widget build(BuildContext context) {
    ...
  }
}
```
`PdfPageSwiper` should follow the same shape: a `StatelessWidget` (or `StatefulWidget` if it owns the `PageController`/lock-state — likely needed, see RESEARCH.md Pitfall 1) with a leading doc-comment citing the relevant requirement IDs (READ-01, READ-04) and explaining *why* the composition is built the way it is (mirroring how `GeometricBorderFrame`'s doc-comment explains the `colorFilter`-not-`color` choice and the `BoxFit.contain` choice).

**Core composition pattern — apply RESEARCH.md's Pattern 1 verbatim, styled to match this file's constant-naming convention** (`_contentInset`-style private static consts for magic numbers):
```dart
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
(Source: `02-RESEARCH.md` Pattern 1, adapted from the `pdfrx` README's `ListView.builder` example.)

**Theme consumption for chrome, not gesture area** (line 30-31 of `geometric_border_frame.dart`):
```dart
final borderStroke =
    Theme.of(context).extension<BurdahColors>()!.borderStroke;
```
Per RESEARCH.md's Anti-Patterns section, `GeometricBorderFrame` itself must NOT wrap `PdfPageSwiper`'s gesture-active `PageView` — apply it only to the reader screen's outer chrome layer (app bar/margin), consistent with the "content inset" doc-comment already on this analog file describing it as designed for static content.

---

### `lib/widgets/zoomable_pdf_page.dart` (component, event-driven)

**Analog:** `lib/widgets/gold_cta_button.dart`

**Callback-driven StatelessWidget shape** (lines 17-25):
```dart
class GoldCtaButton extends StatelessWidget {
  const GoldCtaButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;
```
`ZoomablePdfPage` follows the same required-named-param + callback constructor convention:
```dart
class ZoomablePdfPage extends StatefulWidget {
  const ZoomablePdfPage({
    super.key,
    required this.document,
    required this.pageNumber,
    required this.onZoomChanged,
  });

  final PdfDocument document;
  final int pageNumber;
  final ValueChanged<bool> onZoomChanged;
  ...
}
```
Note: must be `StatefulWidget` (not `StatelessWidget` like the analog) because it owns a `TransformationController` — this is a legitimate deviation from the analog's exact class type, but the constructor/param-doc style should still match.

**Core gesture pattern — apply RESEARCH.md's Pattern 2 verbatim:**
```dart
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
(Source: `02-RESEARCH.md` Pattern 2 — cross-referenced against a community gesture-conflict writeup; flagged `[ASSUMED]`, verify against pinned `pdfrx 2.4.7` at implementation time per RESEARCH.md Open Question 1 / Assumption A1/A4.)

**Doc-comment convention to copy** (lines 5-16 of `gold_cta_button.dart` — explains *why* a design choice was made, citing UI-SPEC/RESEARCH.md sources):
```dart
/// Gold-filled call-to-action button (D-02).
///
/// Background fill reads [BurdahColors.gold] from the current theme.
/// ...
```
`ZoomablePdfPage`'s doc-comment should similarly cite READ-02 and RESEARCH.md Pitfall 1 (per-page-independent zoom state, reset on page change).

---

## Shared Patterns

### Theme extension access
**Source:** `lib/theme/app_theme_extension.dart` consumed via `Theme.of(context).extension<BurdahColors>()!` — used identically in `design_system_test_screen.dart` (line 37), `geometric_border_frame.dart` (line 31), and `gold_cta_button.dart` (line 36).
**Apply to:** `burdah_reader_screen.dart` for any chrome coloring (app bar, page-indicator).

### `EdgeInsetsDirectional`/RTL-safe layout
**Source:** used throughout `design_system_test_screen.dart` (e.g. lines 43, 54, 61-63, 87-89, 106-108) and `geometric_border_frame.dart` (line 44).
**Apply to:** ALL new files in this phase — every padding/alignment on chrome must use `EdgeInsetsDirectional`/`AlignmentDirectional`, per CLAUDE.md's "What NOT to Use" table and RESEARCH.md's explicit Anti-Pattern warning for this phase.

### Error-state copy contract ("Something's not right")
**Source:** `lib/screens/design_system_test_screen.dart` lines 58-81 (copywriting contract, UI-SPEC-sourced).
**Apply to:** `burdah_reader_screen.dart`'s PDF-document-load error path (RESEARCH.md Security Domain V5 requirement — corrupted/unreadable PDF asset must show this copy, not crash uncaught).

### Data model / constructor-injection convention
**Source:** `lib/data/models/burdah.dart` (immutable, `required` named fields) + `lib/data/repositories/asset_burdah_repository.dart` (exception-wrapping on load failure via `CatalogLoadException`).
**Apply to:** `burdah_reader_screen.dart` should accept a `Burdah` (already resolved upstream) in its constructor, per RESEARCH.md's Architectural Responsibility Map row on route/screen entry points — do not re-fetch from `AssetBurdahRepository` inside the reader screen itself; that stays Phase 1/Phase 3's job. Follow `CatalogLoadException`'s pattern of a small custom `Exception` class if a `PdfLoadException`-equivalent wrapper is needed for the PDF document load path.

## No Analog Found

| File | Role | Data Flow | Reason |
|------|------|-----------|--------|
| `lib/widgets/pdf_page_swiper.dart` (gesture-composition/physics-lock logic specifically) | component | streaming/lazy-render + event-driven | No prior `PageView`, `PdfDocumentViewBuilder`, or cross-widget physics-lock state exists in the codebase. RESEARCH.md's Pattern 1/2 code examples (cited from the `pdfrx` README and a generic Flutter gesture-conflict writeup) are the primary source for this file's core logic — the codebase analog above only supplies structural/stylistic conventions (imports, doc-comments, theme access), not the PDF/gesture logic itself. |
| `lib/widgets/zoomable_pdf_page.dart` (TransformationController + InteractiveViewer/pdfrx interaction specifically) | component | event-driven | Same reasoning — no prior interactive/gesture widget exists. Follow RESEARCH.md Pattern 2 and Assumption A1/A4's implementation-time verification spike (Open Question 1) rather than a codebase analog for the zoom-lock mechanics. |

## Metadata

**Analog search scope:** `lib/screens/`, `lib/widgets/`, `lib/data/`, `lib/theme/`, `lib/app.dart` (entire `lib/` tree — small codebase, exhaustively searched)
**Files scanned:** 12 (`.dart` files in `lib/`)
**Pattern extraction date:** 2026-07-25
