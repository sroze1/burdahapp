# Phase 3: Navigation & Primary User Flow - Pattern Map

**Mapped:** 2026-07-26
**Files analyzed:** 10 (5 new screens/widgets, 1 new router file, 2 modified files, 1 modified model, 1 new data field)
**Analogs found:** 8 / 10

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|-----------------|---------------|
| `lib/main.dart` (MODIFY — wrap in `Provider<BurdahRepository>`) | config/provider | request-response (DI) | `lib/main.dart` (current) | exact (extend in place) |
| `lib/app.dart` (MODIFY — `MaterialApp` → `MaterialApp.router`) | config | request-response | `lib/app.dart` (current) | exact (extend in place) |
| `lib/router/app_router.dart` (NEW) | route/config | request-response | none in codebase (no router file exists yet) | no analog — use RESEARCH.md Pattern 1 |
| `lib/screens/home_screen.dart` (NEW) | component/screen | request-response | `lib/screens/design_system_test_screen.dart` (button+nav sub-pattern only) | role-match (partial — trim heavily per D-01/D-02) |
| `lib/screens/burdah_list_screen.dart` (NEW) | component/screen | CRUD (read/list) | `lib/screens/design_system_test_screen.dart` (`FutureBuilder<List<Burdah>>` loading/error/empty pattern) | role-match |
| `lib/widgets/burdah_list_row.dart` (NEW) | component | transform (render row) | `lib/screens/design_system_test_screen.dart` (Arabic/RTL text rendering block, lines 172-199) | role-match |
| `lib/screens/burdah_reveal_screen.dart` (NEW) | component/screen | event-driven (animation → navigate) | none in codebase (no animation screens exist yet) | no analog — use RESEARCH.md Pattern 3 |
| `lib/widgets/transitional_reveal_image.dart` (NEW) | component | event-driven | none in codebase | no analog — use RESEARCH.md Pattern 3 |
| `lib/screens/burdah_reader_screen.dart` (route wiring only, body unchanged) | component/screen | request-response | `lib/screens/burdah_reader_screen.dart` itself (Phase 2, unchanged) | exact (already correct — just needs a `BurdahReaderLoader` wrapper) |
| `lib/data/models/burdah.dart` (MODIFY — add optional `transitionImageAsset`) | model | CRUD | `lib/data/models/burdah.dart` (current) | exact (extend in place) |
| `assets/data/burdah_catalog.json` (MODIFY — add `transitionImageAsset` field) | config/data | CRUD | itself | exact (extend in place) |
| `pubspec.yaml` (MODIFY — register `assets/images/`, add `flutter_animate`) | config | — | itself | exact (extend in place) |

## Pattern Assignments

### `lib/main.dart` (config, DI)

**Analog:** `lib/main.dart` (current file, full contents below — 12 lines, read in one pass)

**Current pattern:**
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(const BurdahApp());
}
```

**Required change (per RESEARCH.md Code Examples — Registering the Provider-based repository at app root):** wrap `BurdahApp` in `Provider<BurdahRepository>(create: (_) => AssetBurdahRepository(), child: const BurdahApp())`. Import `package:provider/provider.dart`, `data/repositories/burdah_repository.dart`, `data/repositories/asset_burdah_repository.dart`. Keep `GoogleFonts.config.allowRuntimeFetching = false` before `runApp` — do not move or remove it.

---

### `lib/app.dart` (config)

**Analog:** `lib/app.dart` (current file, full contents read in one pass, 27 lines)

**Current pattern:**
```dart
import 'package:flutter/material.dart';

import 'screens/design_system_test_screen.dart';
import 'theme/app_theme.dart';

class BurdahApp extends StatelessWidget {
  const BurdahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BurdahApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const DesignSystemTestScreen(),
    );
  }
}
```

**Required change:** replace `home: const DesignSystemTestScreen()` with `routerConfig: appRouter` and switch the constructor to `MaterialApp.router(...)`. Remove the `design_system_test_screen.dart` import; add `import 'router/app_router.dart';`. Keep `theme`/`darkTheme`/`themeMode` lines unchanged — this preserves the existing light/dark palette wiring untouched. This is Pitfall 1 in RESEARCH.md — verify this swap explicitly, since routes silently no-op if `MaterialApp(home:)` is left in place.

---

### `lib/router/app_router.dart` (NEW — route/config, no analog)

**Source:** RESEARCH.md Pattern 1 (`MaterialApp.router + flat GoRouter table with per-route fade`), lines 161-207 of `03-RESEARCH.md`. Use the flat 4-route table (`/`, `/burdahs`, `/burdahs/:id/reveal`, `/burdahs/:id`) each wrapped in `CustomTransitionPage` + `FadeTransition`, per D-08. Reuse `Burdah` model imports and `state.pathParameters['id']!` extraction exactly as shown there. Reader route must wrap `BurdahReaderScreen` in a `BurdahReaderLoader` per RESEARCH.md Pattern 2 (never interpolate raw `id` into an asset path — resolve via `BurdahRepository.getById`).

**Error-state copy contract to reuse (from `design_system_test_screen.dart` lines 100-116):**
```dart
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
```
Apply this exact copy/style pattern inside `BurdahReaderLoader`'s `snapshot.data == null` branch (RESEARCH.md Pattern 2).

---

### `lib/screens/home_screen.dart` (NEW — component/screen)

**Analog:** `lib/screens/design_system_test_screen.dart` (button-tap-to-navigate sub-pattern only — most of that file's content, per D-01/D-02, must NOT be copied: no `AppBar` title text, no font/color/geometric-frame demo sections).

**Reusable sub-pattern — CTA button placement** (lines 298-305 of `design_system_test_screen.dart`):
```dart
Center(
  child: GoldCtaButton(
    label: 'Read Burdah',
    onPressed: _handleReadBurdahPressed,
  ),
),
```

**GoldCtaButton constructor contract** (`lib/widgets/gold_cta_button.dart` lines 17-25 — read in full, 60 lines):
```dart
class GoldCtaButton extends StatelessWidget {
  const GoldCtaButton({
    super.key,
    required this.label,
    required this.onPressed,
  });
  final String label;
  final VoidCallback onPressed;
  ...
}
```

**Required screen shape (per D-02/D-03):** `Scaffold` with **no** `AppBar` (or a transparent/empty one), plain themed background (`Theme.of(context).colorScheme` / `BurdahColors.cream` — do not hardcode hex, mirroring the "single-source-of-truth" contract documented at `app_theme_extension.dart` lines 8-10), body is a `Center` containing only the `GoldCtaButton` with `label: 'Burdah'` and `onPressed: () => context.push('/burdahs')` (RESEARCH.md Pattern 1 navigation call convention — use `context.push`, not `Navigator.push`/`.go()`).

---

### `lib/screens/burdah_list_screen.dart` (NEW — component/screen, CRUD read)

**Analog:** `lib/screens/design_system_test_screen.dart` — reuse its `FutureBuilder<List<Burdah>>` loading/error/empty-state scaffolding (lines 27-39 for `initState`/future creation, lines 81-138 for the three-state `FutureBuilder` builder).

**Loading state pattern** (lines 84-89):
```dart
if (snapshot.connectionState == ConnectionState.waiting) {
  return const Padding(
    padding: EdgeInsetsDirectional.symmetric(vertical: 24),
    child: Center(child: CircularProgressIndicator()),
  );
}
```

**Error state pattern** (lines 90-117) — same "Something's not right" copy block as above, reuse verbatim.

**Empty state pattern** (lines 119-137):
```dart
if (burdahs.isEmpty) {
  // UI-SPEC Copywriting Contract — empty state.
  return Padding(
    padding: const EdgeInsetsDirectional.symmetric(vertical: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('No burdahs yet', style: textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          'New burdah poems will appear here as more are '
          'added to the collection.',
          style: textTheme.bodyMedium,
        ),
      ],
    ),
  );
}
```

**Repository access change:** in the new screen, do NOT instantiate `AssetBurdahRepository()` directly (as `design_system_test_screen.dart` line 37 does) — instead use `context.read<BurdahRepository>().getAll()` per RESEARCH.md's Provider-DI recommendation, since the repository is now injected at app root via `main.dart`.

**List rendering:** replace the single-item display (lines 139-158) with a `ListView.builder`/`ListView.separated` over `burdahs`, rendering each row via the new `BurdahListRow` widget (D-04 — simple `ListTile` rows, not cards). Tapping a row navigates via `context.push('/burdahs/${burdah.id}/reveal')` (RESEARCH.md Pattern 1).

---

### `lib/widgets/burdah_list_row.dart` (NEW — component, D-04)

**Analog:** `lib/screens/design_system_test_screen.dart` Arabic/RTL text rendering block, lines 172-199, and RESEARCH.md's own illustrative `BurdahListRow` code example (RESEARCH.md lines 368-392, no direct upstream source but follows the established `Directionality(rtl)` pattern).

**RTL text pattern to copy** (from `design_system_test_screen.dart` lines 172-178):
```dart
Directionality(
  textDirection: TextDirection.rtl,
  child: Text(
    '...',
    style: textTheme.displaySmall,
  ),
),
```

**Full row implementation (RESEARCH.md-provided, use directly):**
```dart
class BurdahListRow extends StatelessWidget {
  const BurdahListRow({super.key, required this.burdah, required this.onTap});
  final Burdah burdah;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      onTap: onTap,
      title: burdah.titleArabic != null
          ? Directionality(
              textDirection: TextDirection.rtl,
              child: Text(burdah.titleArabic!, style: textTheme.titleLarge),
            )
          : Text(burdah.title, style: textTheme.titleLarge),
      subtitle: Text(burdah.title, style: textTheme.bodyMedium),
    );
  }
}
```
Note: D-04 says "no card frames, no geometric decoration" — do NOT wrap this in `GeometricCardFrame` (which `design_system_test_screen.dart` lines 269-294 demonstrates but which is explicitly deprecated per D-01).

---

### `lib/screens/burdah_reveal_screen.dart` + `lib/widgets/transitional_reveal_image.dart` (NEW — no analog, event-driven)

**Source:** RESEARCH.md Pattern 3 (`Extensible transitional reveal image (D-05)`), lines 239-283 — use directly, this is the only source for this pattern in the project.

```dart
class TransitionalRevealImage extends StatelessWidget {
  const TransitionalRevealImage({super.key, required this.assetPath, required this.onComplete});
  final String assetPath;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Image.asset(assetPath, fit: BoxFit.cover)
      .animate(onComplete: (_) => onComplete())
      .fadeIn(duration: 600.ms, curve: Curves.easeIn)
      .then()
      .custom(
        duration: 800.ms,
        builder: (context, value, child) => ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.white.withOpacity(0.35 * (1 - (2 * value - 1).abs())),
            BlendMode.screen,
          ),
          child: child,
        ),
      )
      .then()
      .fadeOut(duration: 600.ms, curve: Curves.easeOut);
    // 600 + 800 + 600 = 2000ms total, matches D-05's locked 2-second spec.
  }
}
```

**`burdah_reveal_screen.dart` responsibilities:** resolve `burdahId` → `Burdah` via `context.read<BurdahRepository>().getById(id)` (mirror `BurdahReaderLoader`'s `FutureBuilder<Burdah?>` pattern from RESEARCH.md Pattern 2, lines 214-236, including the null → "Something's not right" branch), then render `TransitionalRevealImage(assetPath: burdah.transitionImageAsset!, onComplete: () { if (!context.mounted) return; context.pushReplacement('/burdahs/${burdah.id}'); })` — the `context.mounted` guard is mandatory per RESEARCH.md Pitfall 4 (animation/dispose lifecycle bug on rapid back-tap).

**Anti-pattern to avoid (RESEARCH.md Anti-Patterns, first bullet):** do NOT put this glow animation inside the route's `CustomTransitionPage.transitionsBuilder` — it must be a separate widget-internal animation that starts once the reveal screen is already mounted, per D-09.

---

### `lib/screens/burdah_reader_screen.dart` (UNCHANGED body, needs `BurdahReaderLoader` wrapper)

**Analog:** itself — `lib/screens/burdah_reader_screen.dart`, full file read (65 lines). This file's `build()` already accepts a resolved `Burdah` via constructor (line 22-24) and needs zero internal changes. Only a new wrapper widget `BurdahReaderLoader` (defined inline in `app_router.dart` or as its own file) is needed — see RESEARCH.md Pattern 2, lines 214-236, for the exact `FutureBuilder<Burdah?>` implementation to copy.

---

### `lib/data/models/burdah.dart` (MODIFY — add `transitionImageAsset`)

**Analog:** itself — `lib/data/models/burdah.dart`, full file read (59 lines).

**Existing optional-field pattern to follow** (lines 11, 18, 53 — how `titleArabic` is threaded through as optional):
```dart
final String? titleArabic;
...
const Burdah({
  required this.id,
  required this.title,
  this.titleArabic,
  required this.pdfAsset,
  required this.sortOrder,
});
...
titleArabic: json['titleArabic'] as String?,
```

**Required addition:** add `final String? transitionImageAsset;` as a constructor optional param and `transitionImageAsset: json['transitionImageAsset'] as String?,` in `fromJson` — mirrors the exact `titleArabic` optional-field precedent above (ARCH-03 "new fields must stay optional" contract, per RESEARCH.md Pattern 3). Do NOT add it to the required-field validation block (lines 34-48) — it must stay optional so older/future catalog entries without an image don't throw `FormatException`.

---

## Shared Patterns

### Provider-based repository access
**Source:** `lib/data/repositories/burdah_repository.dart` (abstract contract, full file, 19 lines) + `lib/data/repositories/asset_burdah_repository.dart` (concrete impl, full file, 57 lines) + RESEARCH.md Code Examples (`main.dart`/`app.dart` DI wiring, lines 336-366)
**Apply to:** `main.dart` (provider registration), `burdah_list_screen.dart`, `burdah_reveal_screen.dart`, `BurdahReaderLoader` (all three read via `context.read<BurdahRepository>()`)
```dart
abstract class BurdahRepository {
  Future<List<Burdah>> getAll();
  Future<Burdah?> getById(String id);
}
```
Never instantiate `AssetBurdahRepository()` directly inside a screen once Provider is wired — that pattern (seen in `design_system_test_screen.dart` line 37) is the old walking-skeleton approach being replaced this phase.

### "Something's not right" error-state copy
**Source:** `lib/screens/design_system_test_screen.dart`, lines 100-116 (UI-SPEC Copywriting Contract, already established Phase 1)
**Apply to:** `burdah_list_screen.dart` (catalog load failure), `BurdahReaderLoader` / `burdah_reveal_screen.dart` (burdah-by-id not found)
```dart
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
```

### go_router fade transition wrapper
**Source:** RESEARCH.md Pattern 1, lines 161-207 (no in-codebase analog — this is genuinely new infrastructure this phase)
**Apply to:** all four routes in `app_router.dart` (D-08 — every screen-to-screen transition, including into the reveal screen, uses a plain `FadeTransition`; only the reveal screen's *internal* widget animation is the distinct glow effect per D-09)
```dart
pageBuilder: (context, state) => CustomTransitionPage(
  key: state.pageKey,
  child: const SomeScreen(),
  transitionsBuilder: (context, animation, secondaryAnimation, child) =>
      FadeTransition(opacity: animation, child: child),
  transitionDuration: const Duration(milliseconds: 400),
),
```

### Theme token access (never hardcode hex)
**Source:** `lib/theme/app_theme_extension.dart` lines 8-10 + `lib/widgets/gold_cta_button.dart` lines 35-37
**Apply to:** `home_screen.dart` background color, `burdah_reveal_screen.dart` scaffold background
```dart
final theme = Theme.of(context);
final burdahColors = theme.extension<BurdahColors>()!;
```

## No Analog Found

| File | Role | Data Flow | Reason |
|------|------|-----------|--------|
| `lib/router/app_router.dart` | route/config | request-response | No `go_router`/routing file exists yet anywhere in the codebase — this is the project's first routing config. Use RESEARCH.md Pattern 1 verbatim as the source of truth. |
| `lib/screens/burdah_reveal_screen.dart` | component/screen | event-driven | No animation-driven/choreographed screen exists yet. Use RESEARCH.md Pattern 3 (`flutter_animate` chain) verbatim. |
| `lib/widgets/transitional_reveal_image.dart` | component | event-driven | No `flutter_animate` usage exists yet anywhere in the codebase (dependency not yet installed — flagged in RESEARCH.md Environment Availability). Use RESEARCH.md Pattern 3 verbatim; requires `flutter pub add flutter_animate` first. |

## Metadata

**Analog search scope:** `lib/` (all `.dart` files, 17 total: screens/, widgets/, theme/, data/models/, data/repositories/, main.dart, app.dart)
**Files scanned:** 10 (main.dart, app.dart, design_system_test_screen.dart, burdah_reader_screen.dart, gold_cta_button.dart, burdah.dart, burdah_repository.dart, asset_burdah_repository.dart, app_theme_extension.dart, pubspec.yaml)
**Pattern extraction date:** 2026-07-26
</content>
