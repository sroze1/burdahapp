# Phase 1: Foundation, Data Architecture & Design System - Research

**Researched:** 2026-07-24
**Domain:** Flutter project scaffolding, data-driven catalog architecture, Islamic geometric/calligraphic design system
**Confidence:** MEDIUM (package versions VERIFIED against pub.dev directly; Arabic-shaping and contrast findings VERIFIED via direct calculation/primary GitHub sources; architectural recommendations CITED/ASSUMED per community best practice — this is greenfield, so nothing is verified against this project's actual code yet)

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

- **D-01:** Cream-white base with deep Islamic green (#0A642B) accents — green appears on headers, navigation bars, buttons, and borders. The white should be slightly warm/tinted (not sterile #FFFFFF) so the green feels natural. — **Reversibility:** reversible — palette values live in ThemeData, changeable without structural rework.
- **D-02:** Gold accents throughout — dividers, icon highlights, border trim, and buttons. Illuminated-manuscript aesthetic. Gold as a secondary accent color alongside the primary green.
- **D-03:** Both light AND dark themes for v1 — dark mode uses deep green (#0A642B) as the dark background with lighter text and adjusted gold/accent tones. — **Reversibility:** costly — building both themes from the start is easier than retrofitting dark mode later, but it doubles the theme surface to test.
- **D-04:** The color palette shifts from the original Turkish/Ghazali brief (turquoise, deep blue, burgundy) to an Islamic green + gold + white palette. This is the user's deliberate choice. **IMPORTANT for planner:** `REQUIREMENTS.md` DSGN-03 still literally reads "turquoise, deep-blue, gold, burgundy" — that text is superseded by D-04/CONTEXT.md and by `01-UI-SPEC.md`'s locked hex values. Plan against the green+gold palette below, not the literal DSGN-03 wording.
- **D-05:** Border frames only — geometric patterns frame screens and cards, content area stays clean. Patterns should not compete with the sacred text.
- **D-06:** Interlocking star tessellations — classic 8-point or 12-point Islamic geometric stars.
- **D-07:** SVG assets for pattern implementation — crisp at any resolution, recolorable via theme for dark mode support. Use `flutter_svg` to render. — **Reversibility:** reversible — SVGs can be replaced with `CustomPainter` later if animation is desired.
- **D-08:** Two border widget variants needed: full-screen frame (wraps entire screen) AND card-sized frame (wraps individual content cards like burdah list items).

### Claude's Discretion

- **Exact hex values:** Resolved and locked in `01-UI-SPEC.md` (see Color section below) — gold `#C9A227` (light) / `#E3C067` (dark), warm-white `#FAF6EA`, text colors, dark-mode variants.
- **Calligraphic font selection:** Resolved and locked in `01-UI-SPEC.md` — **Scheherazade New** (display/heading) + **Amiri** (body/label), verified via the phase's own test screen before locking. This research surfaces a real, documented Flutter shaping bug affecting Scheherazade New that the test screen must specifically probe (see Common Pitfalls).
- **Catalog data model shape:** Not yet resolved structurally — this research proposes a concrete JSON schema and repository interface (see Architecture Patterns).
- **Design references:** User has limited exposure to Islamic design traditions — downstream agents should make confident choices grounded in established Islamic geometric/calligraphic principles rather than seeking more visual input.

### Deferred Ideas (OUT OF SCOPE)

None — discussion stayed within phase scope.

</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| ARCH-02 | App runs on both Android and iOS from a single Flutter codebase | Environment Availability audit (below) shows **no Flutter/Xcode/Android toolchain is installed on this machine** — this is a hard blocker the plan must address in Wave 0, not an assumption. Standard Stack section pins the verified-current Flutter SDK. |
| ARCH-03 | Burdah catalog is data-driven (JSON manifest) so new burdahs can be added without code changes | Architecture Patterns section proposes a concrete JSON manifest schema + repository pattern (`BurdahRepository` interface + `AssetBurdahRepository` implementation) sourced from Flutter's standard `rootBundle.loadString` + `fromJson` pattern. |
| DSGN-01 | Islamic geometric patterns throughout (style updated by D-04 to Islamic-green aesthetic, not Turkish/Ghazali) | Architecture Patterns section covers `flutter_svg` recoloring (`colorFilter`/`colorMapper`) for the 8/12-point star tessellation border widgets (D-06/D-07/D-08). |
| DSGN-02 | App uses calligraphic Arabic fonts for text elements | Common Pitfalls section documents a real, previously-open Flutter GitHub issue where Scheherazade New/Lateef fail to join a specific ligature (`الآ`) while Amiri renders it correctly — directly informs what the Phase 1 test screen must verify before the font choice is locked. |
| DSGN-03 | Color palette (superseded by D-04 — green/gold/cream, not turquoise/blue/burgundy) | Computed WCAG contrast ratios for the locked gold/cream/green combinations (see Common Pitfalls) — several combinations fail AA text contrast and must be restricted to decorative/large-scale use only. |

</phase_requirements>

## Summary

This phase has no prior codebase to build on — it is the Flutter project's genesis. Three things need to be true when it's done: (1) the project builds on both mobile targets, (2) a JSON-driven catalog + repository layer proves the "add a burdah without touching code" architecture, and (3) a verified design system (palette, fonts, geometric border widgets) exists for every later screen to consume.

The single biggest risk this research surfaces is **environment readiness**: this machine currently has no Flutter SDK, no Xcode (only Command Line Tools), no Android SDK, and no Java runtime installed. ARCH-02's "builds and runs on Android and iOS with zero errors" success criterion cannot even be attempted until this is resolved — the plan must treat toolchain installation as an explicit Wave 0 step, not an assumption.

The second major risk is **Arabic text shaping**. This is not a theoretical concern — Flutter has open, version-dependent GitHub issues specifically affecting Scheherazade New and Lateef (letter-joining/ligature failures) that do not affect Amiri, plus a history of separate Impeller-engine-specific Arabic rendering bugs (some fixed, versions matter). The UI-SPEC already anticipates this by mandating a verification test screen before locking the font — this research adds the specific test case (the `الآ` ligature and diacritic-heavy text) the test screen must include, not just "render some Arabic text."

Third, the locked color palette has real, computed WCAG contrast problems: gold-on-cream (`#C9A227` on `#FAF6EA`) computes to ~2.24:1 — failing even large-text AA (3:1) — and gold-on-green in both themes lands around 3.0–4.2:1, passing only for large text/icons, never for body-sized text. This is not a hypothetical flag; it's calculated from the locked hex values and should directly constrain how the planner scopes gold usage.

**Primary recommendation:** Scaffold with `flutter create`, verify the toolchain works with a trivial build *before* writing any design-system code (fail fast on environment gaps), implement the catalog as `models/burdah.dart` + `repositories/burdah_repository.dart` loading a single `assets/data/burdah_catalog.json` via `rootBundle`, express the theme as `ThemeData` + a custom `ThemeExtension` for the gold/green tokens (light + dark), and build the test screen so it doubles as the concrete verification artifact for success criteria #2 and #3 — including the specific Arabic ligature test case and a real contrast check, not just visual inspection.

## Architectural Responsibility Map

This is a single-tier mobile client app (no backend/server in scope for v1 — ARCH-01 offline-first). Tiers below are Flutter-client-appropriate, not web-tier.

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Project build/toolchain (ARCH-02) | Platform/Build Config | — | Android Gradle + iOS Xcode project config, native toolchains — outside Dart code entirely |
| Catalog data model + repository (ARCH-03) | Data/Repository Layer | Asset Bundle (Static) | Repository is a Dart abstraction; the JSON manifest itself is a bundled static asset, not a live data source |
| Color palette / ThemeData (DSGN-03) | Theme/Design-System Layer | Widget/Presentation Layer | Theme tokens live centrally in `ThemeData`/`ThemeExtension`; widgets consume via `Theme.of(context)`, never hardcode |
| Calligraphic fonts (DSGN-02) | Asset Bundle (Static) | Theme/Design-System Layer | Font files are bundled assets; `TextTheme` maps roles → font family centrally |
| Geometric border widgets (DSGN-01, D-05–D-08) | Widget/Presentation Layer | Asset Bundle (Static) | SVG files are static assets; the border widget wraps `SvgPicture` and applies theme-driven recoloring |
| Test/demo screen (success criteria #3, #4) | Widget/Presentation Layer | — | Throwaway verification screen, not a shipping app screen |

## Standard Stack

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Flutter SDK | 3.44.x (latest stable patch ~3.44.7) [CITED: pub.dev/flutter.dev search results, 2026-07-24] | Cross-platform app framework | Current stable channel; matches CLAUDE.md's existing pin. Always pin to whatever `flutter --version` reports as stable at scaffold time — do not hand-pin an older number from this doc. |
| Dart SDK | 3.12.x (bundled with Flutter 3.44) [ASSUMED — not independently re-verified this session, inherited from CLAUDE.md] | Language runtime | Ships with the Flutter SDK; no separate install decision. |
| `provider` | ^6.1.5+1 [VERIFIED: pub.dev, fetched 2026-07-24 — publisher `dash-overflow.net`, verified, 11k likes, 150 pub points, last published 11 months ago] | App-wide state (selected burdah, theme mode) | Matches CLAUDE.md's locked stack choice; mature/stable — 11-month publish gap is normal for a feature-complete utility package, not a staleness concern. |
| `google_fonts` | ^8.2.0 [VERIFIED: pub.dev, fetched 2026-07-24 — publisher `flutter.dev`, verified, published 8 days ago] | Bundles Scheherazade New + Amiri as local offline assets | Matches CLAUDE.md's pin (was ^8.2.x). Must be configured for asset-only loading (see Code Examples) — do not rely on default runtime-fetch behavior for an offline app. |
| `flutter_svg` | ^2.3.0 [VERIFIED: pub.dev, fetched 2026-07-24 — publisher `flutter.dev`, verified, published 2 months ago] | Renders and recolors the geometric border/star-tessellation SVG assets (D-07) | **New for this phase** — not previously pinned in CLAUDE.md's stack table (D-07 introduced the SVG requirement during discuss-phase, after CLAUDE.md's original research pass). Officially Flutter-team-maintained. Use `colorFilter`/`colorMapper`, not the deprecated `color`/`colorBlendMode` params (removed in recent versions — see Common Pitfalls). |
| `flutter_lints` | ^6.0.0 [VERIFIED: pub.dev, fetched 2026-07-24 — publisher `flutter.dev`, verified, published 14 months ago] | Static analysis ruleset | Scaffolded by default via `flutter create`; keep enabled — catches directionality/const-correctness issues early, which matter for this RTL-heavy, design-dense app. |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `go_router` | ^17.3.0 [VERIFIED: pub.dev, fetched 2026-07-24 — publisher `flutter.dev`, verified, published 51 days ago; min SDK ~Flutter 3.27/Dart 3.6, well below the 3.44 target] | Declarative navigation | Matches CLAUDE.md's pin (was ^17.x). **Not required by this phase's success criteria** (no multi-screen navigation flow yet — that's Phase 3, NAV-01–03). Planner's discretion: add the dependency now for scaffold consistency with the documented stack, or defer to Phase 3 to avoid an unused dependency. Either is defensible; if deferred, note it explicitly so Phase 3 doesn't have to re-research it. |
| `pdfrx` | ^2.4.7 [VERIFIED: pub.dev, fetched 2026-07-24 — publisher `espresso3389.jp`, verified, 336 likes, 160 pub points, published 14 days ago; source repo confirmed at github.com/espresso3389/pdfrx] | PDF rendering | **Not needed for this phase.** Phase 1's catalog only stores a PDF *asset path string* — no PDF is actually rendered until Phase 2 (READ-01–04). Do not add this dependency in Phase 1 unless the planner wants to smoke-test the asset path against a real `pdfrx` load as an extra verification step (optional, not required by success criteria). |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `google_fonts` package (asset-bundled) | Direct `pubspec.yaml` `fonts:` declaration pointing at manually-downloaded `.ttf` files, no `google_fonts` dependency at all | Simpler and removes any risk of the `google_fonts` package's asset-priority-matching logic silently falling through to a network fetch (see Common Pitfalls) — fully static, zero ambiguity. Tradeoff: loses `google_fonts`' convenience API (`GoogleFonts.amiri()` etc.) and its documented asset-bundling helper; you'd hand-roll the `TextTheme` font-family wiring instead. CLAUDE.md already locks `google_fonts`, so treat this as a fallback only if the asset-priority approach proves unreliable during Phase 1 execution, not a first choice. |
| `ThemeExtension` for gold/green tokens | `flex_color_scheme` (community package for advanced Material 3 theming) | Not needed here — this app has exactly 2 themes and a small, fixed token set (4-5 colors × 2 modes). `ThemeExtension` is the Flutter-native, dependency-free solution; `flex_color_scheme` is designed for apps that need many pre-built scheme variants and runtime scheme-switching UI, which is out of scope. |

**Installation:**
```bash
flutter create --org com.burdahapp --platforms android,ios burdahapp
cd burdahapp
flutter pub add provider google_fonts flutter_svg
# go_router: add now for stack consistency, or defer to Phase 3 (planner's call)
flutter pub add go_router
```

**Version verification:** All versions above were checked directly against pub.dev on 2026-07-24 via `WebFetch`. Re-run `flutter pub outdated` immediately after `flutter create` at execution time — pub.dev package versions can move within the window between research and execution, and `flutter create`'s bundled `flutter_lints` version may differ from what's shown here depending on the exact Flutter SDK patch installed.

## Package Legitimacy Audit

**Note on tooling:** The automated `package-legitimacy check` seam supports `npm`, `pypi`, and `crates` ecosystems only — `pub` (Dart/Flutter) is not currently supported. The audit below was performed manually via direct `WebFetch` against pub.dev package pages (an authoritative source), checking publisher verification, publish recency, likes/pub-points, and source-repo presence.

| Package | Registry | Age (last publish) | Likes / Pub Points | Source Repo | Verdict | Disposition |
|---------|----------|---------------------|---------------------|--------------|---------|-------------|
| `provider` | pub.dev | 11 months | 11k likes / 150 pts | github.com (dash-overflow / rrousselGit) | OK | Approved |
| `google_fonts` | pub.dev | 8 days | (flutter.dev official) | github.com/flutter/packages | OK | Approved |
| `flutter_svg` | pub.dev | 2 months | (flutter.dev official) | github.com/dnfield/flutter_svg | OK | Approved |
| `flutter_lints` | pub.dev | 14 months | (flutter.dev official) | github.com/flutter/packages | OK | Approved |
| `go_router` | pub.dev | 51 days | (flutter.dev official) | github.com/flutter/packages | OK | Approved (Phase 3 dependency, verified now for consistency) |
| `pdfrx` | pub.dev | 14 days | 336 likes / 160 pts | github.com/espresso3389/pdfrx | OK | Approved (Phase 2 dependency, verified now for consistency) |

**Packages removed due to [SLOP] verdict:** none
**Packages flagged as suspicious [SUS]:** none

*All package names above were discovered via `WebSearch`/`WebFetch` against pub.dev directly (an authoritative registry with visible publisher-verification badges), not from training-data recall alone — each is tagged `[VERIFIED: pub.dev]` in the Standard Stack tables above rather than `[ASSUMED]`. `flutter.dev`-published packages (go_router, google_fonts, flutter_svg, flutter_lints) carry the strongest provenance available in this ecosystem — they are maintained by the Flutter team itself.*

## Architecture Patterns

### System Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│                     App Bootstrap                        │
│  main.dart → runApp(MyApp) → MaterialApp(theme, darkTheme)│
└───────────────────────┬───────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│              Theme/Design-System Layer                   │
│  ThemeData.light() / ThemeData.dark()                    │
│  + BurdahThemeExtension (gold/green/cream tokens)         │
│  + TextTheme (Scheherazade New → display/heading,         │
│                Amiri → body/label)                        │
└───────────────────────┬───────────────────────────────────┘
                         │ consumed via Theme.of(context)
                         ▼
┌─────────────────────────────────────────────────────────┐
│            Widget/Presentation Layer (test screen)        │
│  GeometricBorderFrame (full-screen)                       │
│  GeometricCardFrame (card-sized)                          │
│  GoldCtaButton                                             │
│  → renders catalog data + font sample + palette swatch    │
└───────────────────────┬───────────────────────────────────┘
                         │ reads via
                         ▼
┌─────────────────────────────────────────────────────────┐
│              Data/Repository Layer                        │
│  BurdahRepository (abstract)                               │
│    → AssetBurdahRepository.getAll() / getById(id)          │
│  Burdah.fromJson(Map) ← typed model                        │
└───────────────────────┬───────────────────────────────────┘
                         │ rootBundle.loadString(...)
                         ▼
┌─────────────────────────────────────────────────────────┐
│              Asset Bundle (Static, offline)                │
│  assets/data/burdah_catalog.json                           │
│  assets/pdfs/burdah_khadija_ra.pdf (ASCII-renamed)          │
│  assets/google_fonts/ScheherazadeNew-*.ttf, Amiri-*.ttf     │
│  assets/images/svg/star_tessellation_*.svg                 │
└─────────────────────────────────────────────────────────┘
```

### Recommended Project Structure

Given the app's small scope (4 total phases, single developer, ~5-6 screens at full v1), a lightweight grouped structure is recommended over a heavier feature-first split — feature-first pays off at medium/large team scale [CITED: multiple 2026 Flutter architecture articles], which this project is not.

```
lib/
├── main.dart              # entrypoint, runApp
├── app.dart                # MaterialApp, theme wiring, (later) go_router config
├── theme/
│   ├── app_colors.dart      # raw hex constants (light + dark)
│   ├── app_theme_extension.dart  # ThemeExtension<BurdahColors>
│   ├── app_text_theme.dart  # TextTheme mapping fonts → roles
│   └── app_theme.dart       # ThemeData.light()/dark() assembly
├── data/
│   ├── models/
│   │   └── burdah.dart       # Burdah model + fromJson
│   └── repositories/
│       ├── burdah_repository.dart        # abstract interface
│       └── asset_burdah_repository.dart  # rootBundle JSON implementation
├── widgets/
│   ├── geometric_border_frame.dart   # full-screen variant (D-08)
│   ├── geometric_card_frame.dart     # card-sized variant (D-08)
│   └── gold_cta_button.dart
└── screens/
    └── design_system_test_screen.dart  # Phase 1 verification screen (throwaway per UI-SPEC)

assets/
├── data/
│   └── burdah_catalog.json
├── pdfs/
│   └── burdah_khadija_ra.pdf   # renamed from the Arabic-filename original — see Common Pitfalls
├── google_fonts/
│   ├── ScheherazadeNew-Regular.ttf
│   ├── ScheherazadeNew-Bold.ttf
│   ├── Amiri-Regular.ttf
│   └── Amiri-Bold.ttf
└── images/svg/
    ├── star_tessellation_frame_full.svg
    └── star_tessellation_frame_card.svg
```

### Pattern 1: Repository Pattern for the JSON Catalog (ARCH-03)

**What:** An abstract `BurdahRepository` interface with a concrete `AssetBurdahRepository` that loads a bundled JSON file via `rootBundle.loadString`, decodes it, and maps entries through a typed `Burdah.fromJson` constructor.
**When to use:** Any time the app needs the burdah list — this phase's test screen, and every later screen (list, reader) that consumes catalog data.
**Example:**
```dart
// Source: Flutter asset-loading pattern, cross-referenced across
// multiple 2026 community guides (GeeksforGeeks, Medium) — CITED, not
// from a single official doc page.

// data/models/burdah.dart
class Burdah {
  final String id;
  final String title;
  final String? titleArabic;
  final String pdfAsset;
  final int sortOrder;

  const Burdah({
    required this.id,
    required this.title,
    this.titleArabic,
    required this.pdfAsset,
    required this.sortOrder,
  });

  factory Burdah.fromJson(Map<String, dynamic> json) => Burdah(
        id: json['id'] as String,
        title: json['title'] as String,
        titleArabic: json['titleArabic'] as String?,
        pdfAsset: json['pdfAsset'] as String,
        sortOrder: json['sortOrder'] as int? ?? 0,
      );
}

// data/repositories/burdah_repository.dart
abstract class BurdahRepository {
  Future<List<Burdah>> getAll();
  Future<Burdah?> getById(String id);
}

// data/repositories/asset_burdah_repository.dart
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class AssetBurdahRepository implements BurdahRepository {
  static const _assetPath = 'assets/data/burdah_catalog.json';

  @override
  Future<List<Burdah>> getAll() async {
    final raw = await rootBundle.loadString(_assetPath);
    final decoded = json.decode(raw) as Map<String, dynamic>;
    final entries = decoded['burdahs'] as List<dynamic>;
    final list = entries
        .map((e) => Burdah.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }

  @override
  Future<Burdah?> getById(String id) async {
    final all = await getAll();
    try {
      return all.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }
}
```

Proposed `assets/data/burdah_catalog.json` shape (extensible — adding a burdah is a pure data edit, satisfying ARCH-03):
```json
{
  "burdahs": [
    {
      "id": "khadija-ra",
      "title": "Burdah of Sayyida Khadija RA",
      "titleArabic": "بردة أم المؤمنين سيدتنا خديجة",
      "pdfAsset": "assets/pdfs/burdah_khadija_ra.pdf",
      "sortOrder": 1
    }
  ]
}
```

### Pattern 2: ThemeExtension for the Gold/Green Token Set (DSGN-03)

**What:** A custom `ThemeExtension` subclass carrying the palette tokens that don't map cleanly onto Material's default `ColorScheme` roles (e.g., the specific "gold accent, reserved for CTA/dividers/trim only" semantic from `01-UI-SPEC.md`).
**When to use:** Anywhere the app needs the gold accent, the geometric-border stroke color, or other bespoke tokens — never hardcode hex values in widget code.
**Example:**
```dart
// Source: Flutter ThemeExtension pattern — CITED from multiple
// 2026 Medium/dev.to guides and the official ThemeExtension API docs
// (api.flutter.dev/flutter/material/ThemeExtension-class.html).

@immutable
class BurdahColors extends ThemeExtension<BurdahColors> {
  final Color gold;
  final Color borderStroke;
  final Color cream;

  const BurdahColors({
    required this.gold,
    required this.borderStroke,
    required this.cream,
  });

  static const light = BurdahColors(
    gold: Color(0xFFC9A227),
    borderStroke: Color(0xFF0A642B),
    cream: Color(0xFFFAF6EA),
  );

  static const dark = BurdahColors(
    gold: Color(0xFFE3C067),
    borderStroke: Color(0xFF12793A),
    cream: Color(0xFF0A642B), // dark theme "background" role, per D-03
  );

  @override
  BurdahColors copyWith({Color? gold, Color? borderStroke, Color? cream}) =>
      BurdahColors(
        gold: gold ?? this.gold,
        borderStroke: borderStroke ?? this.borderStroke,
        cream: cream ?? this.cream,
      );

  @override
  BurdahColors lerp(ThemeExtension<BurdahColors>? other, double t) {
    if (other is! BurdahColors) return this;
    return BurdahColors(
      gold: Color.lerp(gold, other.gold, t)!,
      borderStroke: Color.lerp(borderStroke, other.borderStroke, t)!,
      cream: Color.lerp(cream, other.cream, t)!,
    );
  }
}

// Usage: Theme.of(context).extension<BurdahColors>()!.gold
```

### Pattern 3: Theme-Recolored SVG Geometric Border (D-06, D-07)

**What:** Render the star-tessellation SVG asset and recolor its strokes to match the current theme (green stroke, gold trim) using `flutter_svg`'s `colorFilter` (single color) or `colorMapper` (multi-color/precise control), not the deprecated `color`/`colorBlendMode` parameters.
**When to use:** Both the full-screen and card-sized border widgets (D-08).
**Example:**
```dart
// Source: pub.dev/packages/flutter_svg (fetched 2026-07-24) — CITED

SvgPicture.asset(
  'assets/images/svg/star_tessellation_frame_full.svg',
  colorFilter: ColorFilter.mode(
    Theme.of(context).extension<BurdahColors>()!.borderStroke,
    BlendMode.srcIn,
  ),
  fit: BoxFit.contain, // per UI-SPEC's "overflow: unresolved" flag — verify on tablet sizes
)
```

### Anti-Patterns to Avoid

- **Hardcoding hex colors in widget files:** breaks the single-source-of-truth theme contract and makes dark mode a nightmare to retrofit — always go through `Theme.of(context)` / `ThemeExtension`.
- **Fetching Google Fonts over HTTP at runtime:** contradicts the offline-first requirement (ARCH-01, relevant from Phase 1 onward since this is foundational) and CLAUDE.md's explicit guardrail — bundle as local assets, verify `allowRuntimeFetching` behavior on the test screen with network disabled.
- **Listing `google_fonts` package assets under the `fonts:` section of `pubspec.yaml`:** the package's own docs are explicit that these files must be listed under `assets:`, not `fonts:` — doing it wrong silently breaks the asset-priority matching and falls back to network fetch.
- **Hardcoded `left`/`right` padding/alignment on border/pattern widgets:** breaks silently in RTL contexts (already a documented CLAUDE.md guardrail for this project) — use `EdgeInsetsDirectional`/`AlignmentDirectional`.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|--------------|-----|
| SVG recoloring per theme | Manual SVG string/XML color substitution | `flutter_svg`'s `colorFilter`/`colorMapper` | Handles multi-path SVGs, gradients, and edge cases (masking, `currentColor`) correctly; hand-rolled string replacement breaks on any SVG structure change |
| JSON asset loading + parsing | Custom binary/asset-reading plumbing | `rootBundle.loadString` + `dart:convert` `jsonDecode` | This is the standard, Flutter-SDK-provided mechanism; nothing about this project's needs justifies bypassing it |
| Theme token management | A custom global `AppColors` static class with `if (isDark)` branches scattered through widgets | `ThemeExtension` + `Theme.of(context)` | `ThemeExtension` gives you `lerp` for smooth theme transitions and a single registration point in `ThemeData.extensions`; static-class-with-conditionals duplicates what Flutter already solves and is easy to get inconsistent across widgets |
| Contrast/accessibility verification | Eyeballing colors on a monitor | WCAG relative-luminance formula (computed below) or a contrast-checker tool (WebAIM, Coolors) | Perceived contrast is unreliable, especially for colorblind reviewers; the computed values in this research already show two combinations failing AA that would likely "look fine" to an unassisted eye |

**Key insight:** Everything hand-roll-able in this phase already has a first-party Flutter SDK mechanism or a Flutter-team-maintained package — there is no domain-specific complexity here (no auth, no networking, no complex state) that would justify custom infrastructure.

## Common Pitfalls

### Pitfall 1: No Flutter/Xcode/Android toolchain installed on this machine
**What goes wrong:** ARCH-02's "builds and runs on Android and iOS with zero errors" success criterion is unattainable until the dev environment exists.
**Why it happens:** This is a fresh machine — CLAUDE.md already flagged "the user does not have mobile development tools installed," and this research's live environment probe confirms it (see Environment Availability below): no `flutter`, no `xcodebuild` (only Command Line Tools, not full Xcode), no `adb`/Android SDK, no `java`.
**How to avoid:** Make toolchain installation an explicit Wave 0 task with its own verification step (`flutter doctor` green across all relevant checks) *before* any design-system code is written — don't let it surface as a surprise blocker mid-phase.
**Warning signs:** `flutter create` or `flutter run` failing with SDK-not-found errors partway through what should be routine scaffold work.

### Pitfall 2: Scheherazade New / Lateef Arabic ligature-joining bug
**What goes wrong:** Specific Arabic letter combinations (documented case: "الآ", Alef with Madda) render with the letters incorrectly disconnected in Scheherazade New and Lateef, while the same text renders correctly in Amiri.
**Why it happens:** [VERIFIED: github.com/flutter/flutter/issues/143975 — fetched 2026-07-24] This is a Flutter text-shaping-engine issue (Flutter delegates Arabic shaping to HarfBuzz via Skia), not a font-file defect — it was reported against Flutter 3.19.1/3.20 and, per this research's last check of the issue thread, remained open/unresolved as filed. Flutter is now at 3.44 (per this research) — the bug's status on the currently-pinned version has **not** been independently re-verified this session and must be checked on the test screen.
**How to avoid:** Build the Phase 1 test screen's Arabic sample text to specifically include diacritic-heavy passages AND the `الآ` combination (or equivalent Alef-Madda joins), not just plain unadorned letters — a generic "renders Arabic text" check would miss this class of bug entirely. If Scheherazade New fails, CONTEXT.md's discretion note already authorizes falling back to Amiri for display use too.
**Warning signs:** Visually disconnected letter forms where they should ligate; look specifically at words containing "لا" and "آ" combinations.

### Pitfall 3: Impeller-engine Arabic rendering has a history of separate, version-specific bugs
**What goes wrong:** Beyond the font-specific issue above, Flutter's Impeller rendering backend (now default on iOS and Android) has had its own Arabic-text bugs — e.g., incorrect glyph transforms [CITED: github.com/flutter/flutter/issues/119805, found in 3.7/3.8] and unwanted character gaps [VERIFIED: github.com/flutter/flutter/issues/147577 — confirmed **closed/fixed** as of this research, found in 3.19/3.22].
**Why it happens:** Impeller is a relatively newer rendering backend; RTL/complex-script shaping edge cases have historically lagged behind LTR support.
**How to avoid:** Because these bugs are engine-version-specific and some have already been fixed, this is exactly why the test screen must be verified on the *actual pinned Flutter version* used for this project (3.44.x), not assumed safe based on Arabic support in Flutter generally or in an older version the developer may have used before.
**Warning signs:** Character overlap, unexpected gaps between joined letters, or transform/rotation artifacts on Arabic glyphs specifically (Latin text rendering fine is not evidence Arabic is fine).

### Pitfall 4: Gold-on-cream and gold-on-green fail WCAG AA contrast for text use
**What goes wrong:** Using the locked gold accent (`#C9A227` light / `#E3C067` dark) as a *text* color on the locked backgrounds produces contrast ratios below the WCAG AA thresholds.
**Why it happens:** [VERIFIED: computed via the WCAG 2.1 relative-luminance formula this session, from the exact hex values locked in `01-UI-SPEC.md`]
  - Light theme, gold `#C9A227` on cream `#FAF6EA`: **~2.24:1** — fails both normal-text (4.5:1) and large-text/UI-component (3:1) AA thresholds.
  - Light theme, gold `#C9A227` on green `#0A642B`: **~3.02:1** — passes large-text/UI-component (3:1), fails normal-text (4.5:1).
  - Dark theme, gold `#E3C067` on dark-green background `#0A642B`: **~4.18:1** — passes large-text/UI-component, just short of normal-text AA.
  - Dark theme, gold `#E3C067` on elevated green `#12793A`: **~3.14:1** — passes large-text/UI-component only.
**How to avoid:** This is consistent with `01-UI-SPEC.md`'s own reservation of gold to "CTA fill, divider hairlines, icon accents, border trim" — **never** body-sized gold text. The UI-SPEC already flags this as unverified and asks the executor to check it; this research provides the actual numbers so the check isn't done from scratch mid-execution. If gold is ever used as a text color (e.g., a gold-highlighted list-item label), it must be large-text-sized (≥18pt regular / ≥14pt bold, per WCAG's large-text definition) and only against the green background, never against cream.
**Warning signs:** Any design decision that puts gold text/icons at body-text size against the cream background — this is the one combination that fails even the lenient large-text/UI-component threshold.

### Pitfall 5: Non-ASCII (Arabic) PDF filename with spaces breaks cross-platform asset bundling
**What goes wrong:** The source PDF currently sits at the project root with an Arabic filename containing spaces (`بردة أم المؤمنين سيدتنا خديجة...pdf`). Bundling a file with this name directly as a Flutter asset risks build/runtime failures.
**Why it happens:** [CITED: multiple flutter/flutter GitHub issues — #94201 (Cyrillic filenames fail to load on macOS/iOS while working on Android), #78725 (umlauts in asset names error), #111020 (special-character filenames fail to load), plus Apple notarization tooling (developer.apple.com forums) rejecting non-ASCII filenames in app bundles] — this is a well-documented, actively-reported class of bug, not a one-off report, and it manifests asymmetrically across platforms (which is exactly the kind of bug that "works on Android, breaks on iOS" or vice versa).
**How to avoid:** When moving the PDF into `assets/pdfs/`, rename it to an ASCII slug (e.g., `burdah_khadija_ra.pdf`) and keep the original Arabic title as JSON metadata (`title`/`titleArabic` fields) instead of encoding it in the filesystem path. This is cheap to do now and expensive to discover mid-Phase-2 when the PDF viewer suddenly fails to load on one platform only.
**Warning signs:** Asset loads fine in `flutter run` on one platform (commonly Android) but throws an asset-not-found error on the other (commonly iOS) — this asymmetry is the classic signature of this bug class.

### Pitfall 6: `flutter_svg`'s deprecated `color`/`colorBlendMode` params
**What goes wrong:** Older tutorials/StackOverflow answers show `SvgPicture.asset(..., color: ..., colorBlendMode: ...)` — these parameters have been removed from current `flutter_svg` versions.
**Why it happens:** Version drift between when a tutorial was written and the pinned `^2.3.0` version.
**How to avoid:** Use `colorFilter: ColorFilter.mode(color, BlendMode.srcIn)` for single-color recoloring, or `colorMapper` for precise multi-color control (needed if the star-tessellation SVG has both a green stroke and gold trim in one file).
**Warning signs:** Compile errors referencing removed/renamed `SvgPicture` parameters.

## Code Examples

See Architecture Patterns section above for the full repository, `ThemeExtension`, and SVG-recoloring examples — all sourced/cross-referenced against pub.dev package pages and Flutter API docs fetched during this research session (2026-07-24).

### Bundling Scheherazade New + Amiri fully offline
```yaml
# Source: pub.dev/packages/google_fonts (fetched 2026-07-24) — CITED
# pubspec.yaml
flutter:
  assets:
    - assets/data/burdah_catalog.json
    - assets/google_fonts/   # NOT listed under `fonts:` — package auto-discovers
    - assets/images/svg/
    - assets/pdfs/
```
```dart
// main.dart, before runApp()
import 'package:google_fonts/google_fonts.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false; // hard offline guarantee
  runApp(const MyApp());
}
```
Font files must be named per Google's weight convention inside `assets/google_fonts/` (e.g., `ScheherazadeNew-Regular.ttf`, `ScheherazadeNew-Bold.ttf`, `Amiri-Regular.ttf`, `Amiri-Bold.ttf`) — the package matches on this exact naming pattern to prioritize the local file over any network fetch. [CITED: pub.dev/packages/google_fonts, fetched 2026-07-24]

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|---------------|--------|
| `SvgPicture.asset(..., color:, colorBlendMode:)` | `colorFilter`/`colorMapper` parameters | Deprecated in a recent `flutter_svg` major version (current: 2.3.0) | Any tutorial/example using the old params will fail to compile against the pinned version |
| Skia-only rendering | Impeller as default rendering backend on iOS and Android | Impeller has been the default across both platforms for some time as of 2026 | Historical Arabic-shaping bugs were engine-specific to Impeller in some cases — re-verify on the actual pinned version rather than assuming "Flutter supports Arabic" is a stable, version-independent fact |

**Deprecated/outdated:**
- `flutter_svg`'s `color`/`colorBlendMode` SvgPicture parameters — replaced by `colorFilter`/`colorMapper`.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|----------------|
| A1 | Dart SDK bundled with Flutter 3.44 is 3.12.x | Standard Stack | Low — Dart version is not independently chosen; whatever ships with the installed Flutter SDK is authoritative, this is informational only |
| A2 | Flutter's currently-pinned 3.44.x has resolved (or not) the Scheherazade New/Lateef ligature bug from issue #143975 | Common Pitfalls (Pitfall 2) | Medium — if unresolved, the font choice may need to fall back to Amiri for display text too; this is exactly why the test screen exists, so the risk is contained by design, not eliminated by this research |
| A3 | The star-tessellation SVG assets referenced in the recommended project structure will be sourced/designed during execution (not yet created) | Architecture Patterns, Pattern 3 | Low — this is expected; no asset-sourcing claim is made here, only the *rendering* pattern once assets exist |

**If this table is empty:** N/A — see entries above. All package version/publisher claims are tagged `[VERIFIED: pub.dev]` (directly fetched this session), not `[ASSUMED]`.

## Open Questions

1. **Is the Scheherazade New ligature-joining bug (issue #143975) fixed on Flutter 3.44?**
   - What we know: It was open/unresolved as of the last Flutter versions mentioned in the issue thread (3.19–3.20 era).
   - What's unclear: Whether it has since been fixed — this research did not find an explicit closure status for that specific issue (unlike #147577, which was confirmed closed/fixed).
   - Recommendation: Treat as unresolved until the Phase 1 test screen proves otherwise on the actual installed Flutter version; do not lock Scheherazade New for display text until that check passes.

2. **Where will the star-tessellation SVG assets come from?**
   - What we know: D-06/D-07 lock the visual style (8/12-point interlocking stars, SVG format, theme-recolorable) and D-08 locks the two required variants.
   - What's unclear: Whether these will be hand-authored (e.g., in a vector tool), generated programmatically, or sourced from an existing open-license geometric-pattern library — this was not researched in depth this session since it's an asset-creation task, not a technical/library research question.
   - Recommendation: Flag as a planning decision — if sourcing from a third-party pattern library, verify its license permits redistribution inside a commercial/App-Store app.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|-------------|-----------|---------|----------|
| Flutter SDK | ARCH-02 (entire phase) | ✗ | — | None — must install (`flutter` not on PATH at all) |
| Dart SDK | ARCH-02 (entire phase) | ✗ | — | Bundled with Flutter install — no separate action once Flutter is installed |
| Xcode (full, not just CLT) | iOS build target (ARCH-02) | ✗ | Command Line Tools only present, not full Xcode | None — full Xcode required for iOS builds/simulator; must install from the App Store |
| Android SDK / `adb` | Android build target (ARCH-02) | ✗ | — | None — install via Android Studio or `sdkmanager` |
| Java runtime | Android Gradle build toolchain | ✗ | — | None — Android Gradle Plugin requires a JDK; typically bundled with Android Studio's JBR |
| CocoaPods | iOS dependency management (`pod install`) | ✗ (not probed directly — `pod` not on PATH) | — | Install via Homebrew or `gem install cocoapods` |
| Homebrew | Simplifies installing the above | ✓ | 6.0.5 | — |
| git | Version control (already required by GSD workflow) | ✓ | 2.47.1 | — |

**Missing dependencies with no fallback:**
- Flutter SDK, full Xcode, Android SDK, Java runtime, CocoaPods — all must be installed before ARCH-02's success criterion ("builds and runs on both an Android and an iOS target with zero errors") can be attempted, let alone verified. This blocks the entire phase's success criterion #1 and should be the first executable task, gated by an explicit `flutter doctor` check.

**Missing dependencies with fallback:**
- None — this is a from-scratch native toolchain requirement with no viable substitute for building real Android/iOS binaries.

## Security Domain

`security_enforcement` is enabled (ASVS Level 1, block on High) per `.planning/config.json`. This phase is a fully offline, no-network, no-auth, no-user-generated-data mobile app foundation — most ASVS categories are structurally not applicable, documented explicitly below rather than silently skipped.

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|----------------|---------|--------------------|
| V2 Authentication | No | App has no accounts/login (explicitly out of scope, `REQUIREMENTS.md`) |
| V3 Session Management | No | No sessions — no server, no auth |
| V4 Access Control | No | No user roles or restricted resources — entire catalog is public, bundled content |
| V5 Input Validation | Yes (minimal) | The only "input" this phase parses is the bundled JSON catalog manifest. It is not user-supplied or network-delivered (it ships inside the app bundle), so the threat model is "malformed data shipped by the developer," not "malicious external input." Still: `Burdah.fromJson` should fail predictably (typed exception, not a crash) on missing/malformed fields, matching the UI-SPEC's already-defined error-state copy ("Something's not right..."). |
| V6 Cryptography | No | No secrets, no encrypted storage, no network calls in this phase — nothing to encrypt |

### Known Threat Patterns for this stack

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|-----------------------|
| Malformed/corrupted bundled JSON manifest causing an unhandled crash on app launch | Denial of Service (self-inflicted, not attacker-driven — this is a packaging-bug risk, not a security vulnerability per se) | Repository layer wraps `jsonDecode`/`fromJson` calls in explicit error handling, surfacing the UI-SPEC's defined error state rather than an uncaught exception |
| Path traversal via a crafted `pdfAsset` field value | Tampering | Not exploitable in v1 — the manifest is bundled at build time, not user-editable at runtime, so there is no attacker-controlled input path here. Revisit if a future version allows remote/downloadable catalog updates (explicitly out of scope for v1 per `REQUIREMENTS.md`'s "Cloud sync" exclusion). |

## Sources

### Primary (HIGH confidence)
- pub.dev package pages fetched directly via `WebFetch`, 2026-07-24: `go_router`, `provider`, `google_fonts`, `flutter_svg`, `pdfrx`, `flutter_native_splash`, `flutter_launcher_icons`, `flutter_lints` — version numbers, publisher verification, publish dates, pub points/likes.
- github.com/flutter/flutter/issues/143975 (Scheherazade New/Lateef ligature bug) — fetched directly via `WebFetch`.
- github.com/flutter/flutter/issues/147577 (Impeller Arabic character-gap bug, confirmed closed/fixed) — fetched directly via `WebFetch`.
- WCAG 2.1 relative-luminance contrast ratios — computed directly this session from the exact locked hex values in `01-UI-SPEC.md`.

### Secondary (MEDIUM confidence)
- WebSearch results cross-referencing pub.dev for package metadata (used to corroborate/target the WebFetch calls above).
- github.com/flutter/flutter/issues #94201, #78725, #111020 (non-ASCII asset filename bugs) — found via WebSearch, not individually fetched in full, but consistent across three independent issue reports plus Apple developer-forum reports on notarization rejecting non-ASCII filenames.
- Flutter/Dart architecture community articles (codewithandrea.com, Medium, dev.to) on feature-first vs. layer-first project structure and `ThemeExtension` patterns — directionally consistent across multiple independent sources.

### Tertiary (LOW confidence)
- Exact current Flutter SDK patch version (3.44.7) — sourced from WebSearch snippet summarization, not independently cross-verified against flutter.dev's release page directly this session; re-verify with `flutter --version` once installed rather than trusting this number.
- Whether issue #143975 is fixed on the current 3.44.x release — not resolved by this research; flagged explicitly in Open Questions.

## Metadata

**Confidence breakdown:**
- Standard stack (package versions): HIGH — every version was fetched directly from pub.dev this session, not recalled from training data.
- Architecture (repository pattern, ThemeExtension, SVG recoloring): MEDIUM — patterns are standard/idiomatic Flutter, cross-referenced across multiple community sources, but not verified against this project's actual code (doesn't exist yet).
- Pitfalls (Arabic shaping bugs, contrast ratios, non-ASCII filenames): HIGH — sourced from primary GitHub issue threads and direct WCAG computation from the project's own locked hex values, not speculation.
- Environment availability: HIGH — directly probed on this machine this session.

**Research date:** 2026-07-24
**Valid until:** ~14 days for package versions (pub.dev packages, especially `go_router`/`google_fonts`, move on a roughly monthly cadence — re-verify with `flutter pub outdated` at execution time regardless of this window); ~30 days for architecture/pitfall findings (Flutter engine bug status is the fastest-moving fact here and should be re-checked against whatever Flutter version is actually installed at execution time, not assumed stable from this research date).
