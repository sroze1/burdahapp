# Phase 1: Foundation, Data Architecture & Design System - Pattern Map

**Mapped:** 2026-07-24
**Files analyzed:** 14 (new)
**Analogs found:** 0 / 14 (greenfield project — no existing codebase)

## Context

This is a brand-new Flutter project. `find`/`Glob` confirm no `lib/`, `pubspec.yaml`, or prior Dart code exists anywhere in the repo — only raw source assets (`.pdf`, `.mp3`) sit at the project root, plus `.claude/` and `.planning/` tooling directories. There are no in-repo analogs to copy from.

Because of this, the "Pattern Assignments" below are sourced from `01-RESEARCH.md`'s Architecture Patterns section (itself cross-referenced against official Flutter SDK docs, `flutter_svg`/`google_fonts` pub.dev pages, and community-verified idioms) rather than from Read calls against existing project files. Treat these as **canonical templates to establish**, not existing conventions to match. Once Phase 1 lands, these become the real in-repo analogs for Phases 2-4.

## File Classification

| New File | Role | Data Flow | Template Source | Match Quality |
|----------|------|-----------|------------------|---------------|
| `lib/main.dart` | config/entrypoint | request-response (bootstrap) | RESEARCH.md Architecture Diagram + Code Examples (google_fonts offline config) | research-template |
| `lib/app.dart` | config | request-response (bootstrap) | RESEARCH.md Architecture Diagram | research-template |
| `lib/theme/app_colors.dart` | config | transform (static tokens) | RESEARCH.md Pattern 2 (ThemeExtension) | research-template |
| `lib/theme/app_theme_extension.dart` | config | transform | RESEARCH.md Pattern 2, full code example | research-template |
| `lib/theme/app_text_theme.dart` | config | transform | RESEARCH.md Standard Stack (`google_fonts`) + Common Pitfalls #2/#3 | research-template |
| `lib/theme/app_theme.dart` | config | transform | RESEARCH.md Pattern 2 (ThemeData assembly) | research-template |
| `lib/data/models/burdah.dart` | model | CRUD (read-only) | RESEARCH.md Pattern 1, full code example | research-template |
| `lib/data/repositories/burdah_repository.dart` | service (interface) | CRUD (read-only) | RESEARCH.md Pattern 1, abstract interface | research-template |
| `lib/data/repositories/asset_burdah_repository.dart` | service (implementation) | file-I/O (asset bundle read) | RESEARCH.md Pattern 1, full code example | research-template |
| `lib/widgets/geometric_border_frame.dart` | component | transform (render) | RESEARCH.md Pattern 3 (SVG recoloring) | research-template |
| `lib/widgets/geometric_card_frame.dart` | component | transform (render) | RESEARCH.md Pattern 3 (SVG recoloring) | research-template |
| `lib/widgets/gold_cta_button.dart` | component | request-response (tap handler) | RESEARCH.md Pattern 2 (ThemeExtension consumption) + Pitfall 4 (contrast constraint) | research-template |
| `lib/screens/design_system_test_screen.dart` | component (screen) | transform (render/verification) | RESEARCH.md Architecture Diagram, "Widget/Presentation Layer" row | research-template |
| `assets/data/burdah_catalog.json` | config (data) | file-I/O (static asset) | RESEARCH.md Pattern 1, JSON schema example | research-template |

## Pattern Assignments

### `lib/data/models/burdah.dart` (model, CRUD read-only)

**Template:** RESEARCH.md Pattern 1 ("Repository Pattern for the JSON Catalog", lines 220-249 of `01-RESEARCH.md`)

**Core pattern — typed model with `fromJson`:**
```dart
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
```

**Extensibility requirement (ARCH-03):** new burdahs are added purely by appending an object to `assets/data/burdah_catalog.json` — no changes to `burdah.dart` needed as long as new fields stay optional/backward-compatible with `fromJson`.

**Error-handling requirement (Security Domain, V5):** `fromJson` should fail predictably (typed exception) on missing/malformed required fields (`id`, `title`, `pdfAsset`) rather than crashing uncaught — RESEARCH.md's Known Threat Patterns table flags this explicitly.

---

### `lib/data/repositories/burdah_repository.dart` + `asset_burdah_repository.dart` (service, file-I/O)

**Template:** RESEARCH.md Pattern 1, lines 250-284

**Interface (abstract):**
```dart
abstract class BurdahRepository {
  Future<List<Burdah>> getAll();
  Future<Burdah?> getById(String id);
}
```

**Implementation — asset-bundle read via `rootBundle`:**
```dart
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

**Do-not-hand-roll note:** use `rootBundle.loadString` + `dart:convert`'s `jsonDecode` — this is the standard SDK-provided mechanism (RESEARCH.md "Don't Hand-Roll" table); no custom asset-reading plumbing.

---

### `assets/data/burdah_catalog.json` (config data, file-I/O)

**Template:** RESEARCH.md Pattern 1, lines 288-300

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

**Critical pitfall (RESEARCH.md Pitfall 5):** the source PDF at repo root has a non-ASCII (Arabic) filename with spaces. It MUST be renamed to an ASCII slug (`burdah_khadija_ra.pdf`) when moved into `assets/pdfs/` — non-ASCII asset filenames are a documented cross-platform bundling failure (asymmetric: works on Android, fails on iOS, or vice versa). Keep the Arabic title only as JSON metadata (`titleArabic`), never in the filesystem path.

---

### `lib/theme/app_theme_extension.dart` + `app_theme.dart` + `app_colors.dart` (config, transform)

**Template:** RESEARCH.md Pattern 2 ("ThemeExtension for the Gold/Green Token Set"), lines 302-356

```dart
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

// Usage anywhere in widget code:
// Theme.of(context).extension<BurdahColors>()!.gold
```

**Anti-pattern to avoid (RESEARCH.md, Architecture Patterns):** never hardcode hex values directly in widget files — always route through `Theme.of(context).extension<BurdahColors>()`. This is the single-source-of-truth contract for both light/dark themes (D-03).

**Locked hex values (from D-01/D-02 + CONTEXT.md discretion resolution):**
- Primary green: `#0A642B`
- Gold (light): `#C9A227` / Gold (dark): `#E3C067`
- Warm cream/white: `#FAF6EA`

**WCAG contrast constraint (RESEARCH.md Pitfall 4) — must inform any text-color choices in this file:**
- Gold `#C9A227` on cream `#FAF6EA`: ~2.24:1 — fails AA even for large text. Never use gold as text on cream.
- Gold `#C9A227` on green `#0A642B`: ~3.02:1 — large-text/UI-component only, never body text.
- Dark gold `#E3C067` on dark green `#0A642B`: ~4.18:1 — large-text/UI-component only.
- Restrict gold to CTA fill, divider hairlines, icon accents, border trim — never body-sized text.

---

### `lib/widgets/geometric_border_frame.dart` + `geometric_card_frame.dart` (component, transform/render)

**Template:** RESEARCH.md Pattern 3 ("Theme-Recolored SVG Geometric Border"), lines 358-374

```dart
SvgPicture.asset(
  'assets/images/svg/star_tessellation_frame_full.svg',
  colorFilter: ColorFilter.mode(
    Theme.of(context).extension<BurdahColors>()!.borderStroke,
    BlendMode.srcIn,
  ),
  fit: BoxFit.contain, // verify on tablet sizes — overflow unresolved per UI-SPEC
)
```

**Two required variants (D-08):**
- `geometric_border_frame.dart` — full-screen wrap, uses `star_tessellation_frame_full.svg`
- `geometric_card_frame.dart` — card-sized wrap (e.g., burdah list items), uses `star_tessellation_frame_card.svg`

**Critical pitfall (RESEARCH.md Pitfall 6):** use `colorFilter`/`colorMapper`, NOT the deprecated `color`/`colorBlendMode` params — these were removed from current `flutter_svg` (pinned `^2.3.0`). Older tutorials show the deprecated API; do not copy from them.

**RTL guardrail (CLAUDE.md "What NOT to Use" + RESEARCH.md Anti-Patterns):** border widgets must use `EdgeInsetsDirectional`/`AlignmentDirectional`, never hardcoded `left`/`right` — this app is RTL-heavy (Arabic content) and hardcoded directionality breaks silently.

---

### `lib/screens/design_system_test_screen.dart` (component/screen, transform/render — verification artifact)

**Template:** RESEARCH.md Architecture Diagram ("Widget/Presentation Layer" box) + Common Pitfalls #2/#3 (Arabic shaping test cases)

**Purpose:** throwaway verification screen (not shipping), must render:
1. Catalog data pulled via `AssetBurdahRepository.getAll()`
2. Font sample — MUST include the `الآ` (Alef-Madda) ligature and diacritic-heavy Arabic text, specifically testing Scheherazade New's known ligature-joining bug (Flutter issue #143975) before locking the font choice
3. Palette swatch — visual + computed contrast check for gold/cream/green combinations (see WCAG figures above)
4. Both `GeometricBorderFrame` and `GeometricCardFrame` widgets in use

---

### `lib/main.dart` (config/entrypoint)

**Template:** RESEARCH.md Code Examples section, lines 451-460

```dart
import 'package:google_fonts/google_fonts.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false; // hard offline guarantee
  runApp(const MyApp());
}
```

**pubspec.yaml asset registration (critical — wrong section silently breaks offline fonts):**
```yaml
flutter:
  assets:
    - assets/data/burdah_catalog.json
    - assets/google_fonts/   # NOT listed under `fonts:` — package auto-discovers
    - assets/images/svg/
    - assets/pdfs/
```
Font files must be named per Google's weight convention (`ScheherazadeNew-Regular.ttf`, `ScheherazadeNew-Bold.ttf`, `Amiri-Regular.ttf`, `Amiri-Bold.ttf`) inside `assets/google_fonts/` — `google_fonts` matches on this exact naming pattern to prefer the local file over network fetch.

## Shared Patterns

### Theme token access (applies to all widget/screen files)
**Source:** RESEARCH.md Pattern 2
**Rule:** Every widget consumes colors via `Theme.of(context).extension<BurdahColors>()!`, never a hardcoded hex or a static `AppColors.foo` conditional-branch class. `ThemeExtension` provides `lerp` for smooth theme transitions and single-point registration in `ThemeData.extensions`.

### Directionality (applies to all layout/widget files touching Arabic content)
**Source:** CLAUDE.md "What NOT to Use" table + RESEARCH.md Anti-Patterns
**Rule:** Use `EdgeInsetsDirectional`/`AlignmentDirectional` exclusively — never `EdgeInsets.only(left:...)` or `Alignment.centerLeft`. Applies to `geometric_border_frame.dart`, `geometric_card_frame.dart`, `design_system_test_screen.dart`, and any future screen.

### Repository error handling (applies to `asset_burdah_repository.dart` and its consumers)
**Source:** RESEARCH.md Security Domain, Known Threat Patterns table
**Rule:** Wrap `jsonDecode`/`fromJson` calls in explicit error handling; surface a defined error state (per UI-SPEC's "Something's not right..." copy) rather than letting an uncaught exception crash the app on a malformed bundled manifest.

### Offline-first asset loading (applies to fonts, SVGs, JSON, PDF)
**Source:** RESEARCH.md Anti-Patterns + CLAUDE.md "What NOT to Use"
**Rule:** No runtime network fetches anywhere in this phase. Fonts bundled locally with `allowRuntimeFetching = false`; JSON/SVG/PDF all loaded via `rootBundle`/asset paths, never HTTP.

## No Analog Found

All 14 files have no in-repo analog (greenfield project). Each is backed by a research-template match quality (see table above), sourced from `01-RESEARCH.md`'s Architecture Patterns section instead of an existing file. No gaps remain — RESEARCH.md provides a concrete template for every planned file's core pattern.

Two files are asset-creation tasks with no code template (flagged as Open Questions in RESEARCH.md, not pattern gaps):
- `assets/images/svg/star_tessellation_frame_full.svg`
- `assets/images/svg/star_tessellation_frame_card.svg`

These must be hand-authored, generated, or sourced (with license verification if third-party) during Phase 1 execution — RESEARCH.md Pattern 3 only covers how to *render/recolor* them, not how to author them.

## Metadata

**Analog search scope:** Entire repo root (`find . -maxdepth 3`) — confirmed no `lib/`, `pubspec.yaml`, or Dart source exists.
**Files scanned:** 0 existing Dart files (none exist); 2 upstream docs read in full (`01-CONTEXT.md`, `01-RESEARCH.md`)
**Pattern extraction date:** 2026-07-24
