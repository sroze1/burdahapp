---
phase: 03-navigation-primary-user-flow
reviewed: 2026-07-26T12:00:00Z
depth: standard
files_reviewed: 11
files_reviewed_list:
  - assets/data/burdah_catalog.json
  - lib/app.dart
  - lib/data/models/burdah.dart
  - lib/main.dart
  - lib/router/app_router.dart
  - lib/screens/burdah_list_screen.dart
  - lib/screens/burdah_reveal_screen.dart
  - lib/screens/home_screen.dart
  - lib/widgets/burdah_list_row.dart
  - lib/widgets/transitional_reveal_image.dart
  - pubspec.yaml
findings:
  critical: 1
  warning: 5
  info: 1
  total: 7
status: issues_found
---

# Phase 3: Code Review Report

**Reviewed:** 2026-07-26T12:00:00Z
**Depth:** standard
**Files Reviewed:** 11
**Status:** issues_found

## Summary

Phase 3 introduces go_router declarative navigation, a Provider-based BurdahRepository DI layer, a catalog-driven burdah list screen, and a choreographed reveal transition screen. The architecture is sound: route definitions are flat and use fade transitions consistently, the repository abstraction is clean, and `BurdahListScreen` correctly caches its FutureBuilder future in `initState`. However, two other screens (`BurdahRevealScreen` and `BurdahReaderLoader`) repeat the FutureBuilder pattern incorrectly, creating new futures inside `build()` which causes observable UI glitches. Several additional issues affect robustness and violate stated project conventions.

## Critical Issues

### CR-01: FutureBuilder anti-pattern in BurdahRevealScreen and BurdahReaderLoader -- futures created in build() restart on every rebuild

**File:** `lib/screens/burdah_reveal_screen.dart:24` and `lib/router/app_router.dart:74`
**Issue:** Both `BurdahRevealScreen.build()` (line 24) and `BurdahReaderLoader.build()` (line 74) pass `repo.getById(burdahId)` directly to `FutureBuilder.future`. Each call to `build()` creates a new `Future` object. When Flutter rebuilds these widgets (due to theme change, keyboard appearance, device rotation, notification shade, or any `MediaQuery` change), `FutureBuilder` sees a different future reference, resets to `ConnectionState.waiting`, and briefly shows the loading spinner.

For `BurdahReaderLoader` this causes a visible loading flash. For `BurdahRevealScreen` the impact is worse: the 4-second reveal animation chain restarts from the beginning mid-playback, breaking the intended choreography.

`BurdahListScreen` already handles this correctly by caching the future in `initState` (line 27). The pattern is proven in the codebase but was not applied to these two widgets.

**Fix:** Convert both to `StatefulWidget` and cache the future in `initState`, mirroring the pattern already used by `BurdahListScreen`:

```dart
// lib/screens/burdah_reveal_screen.dart
class BurdahRevealScreen extends StatefulWidget {
  const BurdahRevealScreen({super.key, required this.burdahId});
  final String burdahId;

  @override
  State<BurdahRevealScreen> createState() => _BurdahRevealScreenState();
}

class _BurdahRevealScreenState extends State<BurdahRevealScreen> {
  late final Future<Burdah?> _burdahFuture;

  @override
  void initState() {
    super.initState();
    _burdahFuture = context.read<BurdahRepository>().getById(widget.burdahId);
  }

  @override
  Widget build(BuildContext context) {
    // ... use _burdahFuture in FutureBuilder ...
  }
}
```

Apply the same transformation to `BurdahReaderLoader` in `app_router.dart`.

## Warnings

### WR-01: Unsafe type casts for optional fields in Burdah.fromJson bypass validation

**File:** `lib/data/models/burdah.dart:60-63`
**Issue:** The `fromJson` factory carefully validates the three required fields (`id`, `title`, `pdfAsset`) with explicit type checks and descriptive `FormatException` messages. However, the three optional fields use bare `as` casts:

```dart
titleArabic: json['titleArabic'] as String?,      // line 60
sortOrder: json['sortOrder'] as int? ?? 0,         // line 62
transitionImageAsset: json['transitionImageAsset'] as String?,  // line 63
```

If `titleArabic` is present but not a `String` (e.g., a number), `as String?` throws a raw `TypeError` with no context. The `sortOrder` cast is particularly fragile: JSON numbers can decode as `double` (e.g., `"sortOrder": 1.0` produces a `double`, not `int`), causing `as int?` to throw a `TypeError` that bypasses the descriptive error handling established for required fields. The `catch` block in `AssetBurdahRepository.getAll()` catches this but surfaces a generic message, not the field-level context.

**Fix:** Apply the same validation pattern used for required fields:

```dart
final rawSort = json['sortOrder'];
final sortOrder = rawSort is int
    ? rawSort
    : rawSort is double
        ? rawSort.toInt()
        : 0;

final titleArabic = json['titleArabic'];
if (titleArabic != null && titleArabic is! String) {
  throw FormatException(
    'Burdah.fromJson: "titleArabic" must be a String or null, got ${titleArabic.runtimeType} in $json',
  );
}
```

### WR-02: HomeScreen force-unwraps BurdahColors theme extension with no null guard

**File:** `lib/screens/home_screen.dart:13`
**Issue:** `theme.extension<BurdahColors>()!` crashes with a null assertion error if the `BurdahColors` extension is missing from the theme. `BurdahReaderScreen` (lines 29-34) already demonstrates the safer pattern: access with a null check, assert in debug mode, and provide a fallback. `HomeScreen` skips this entirely.

While the current theme setup registers `BurdahColors`, this unguarded access is fragile against future refactoring (e.g., changing theme registration order, testing with a minimal `ThemeData`). The same force-unwrap pattern appears in `geometric_border_frame.dart:31` and `gold_cta_button.dart:36` (out of this review's scope but a wider pattern).

**Fix:** Mirror the defensive pattern from `BurdahReaderScreen`:

```dart
final themeBurdahColors = theme.extension<BurdahColors>();
assert(
  themeBurdahColors != null,
  'BurdahColors extension missing from ThemeData',
);
final burdahColors = themeBurdahColors ?? BurdahColors.light;
```

### WR-03: HomeScreen hardcodes burdah ID and assumes reveal route exists

**File:** `lib/screens/home_screen.dart:19`
**Issue:** The home screen hardcodes `context.push('/burdahs/khadija-ra/reveal')`. This bypasses the dynamic check that `BurdahListScreen` (lines 98-100) correctly performs:

```dart
burdah.transitionImageAsset != null
    ? '/burdahs/${burdah.id}/reveal'
    : '/burdahs/${burdah.id}',
```

If the `khadija-ra` catalog entry is renamed, removed, or its `transitionImageAsset` field dropped, the home button routes to a reveal screen that shows the error state. The list screen is resilient to this; the home screen is not.

**Fix:** Load the burdah from the repository (or accept it as a parameter) and check `transitionImageAsset` before choosing the route, or at minimum route to `/burdahs/khadija-ra` (the reader screen, which has its own null handling) rather than unconditionally to the reveal route.

### WR-04: Hardcoded salaam text in _RevealContent violates ARCH-03 extensibility contract

**File:** `lib/screens/burdah_reveal_screen.dart:138-168`
**Issue:** `_RevealContent` receives a generic `Burdah` object but renders three hardcoded text strings specific to Sayyida Khadija RA:

- Line 138: Arabic salaam text
- Line 150: Transliteration text
- Line 163: English translation text

The `Burdah` model and `burdah_catalog.json` are designed for extensibility (ARCH-03: "New burdahs are added by appending an object to that JSON file; this class never needs to change"). But if a second burdah is added with a `transitionImageAsset`, this screen would display Khadija-specific salaam text for ANY burdah, producing incorrect content.

**Fix:** Add a `revealText` or `salaamText` field (or nested object) to the `Burdah` model and JSON catalog, then read from the model rather than hardcoding. Alternatively, document that the reveal screen is intentionally Khadija-specific and route other burdahs directly to the reader.

### WR-05: TransitionalRevealImage widget is dead code

**File:** `lib/widgets/transitional_reveal_image.dart:1-41`
**Issue:** The `TransitionalRevealImage` class is defined but never imported or used anywhere in the codebase. `BurdahRevealScreen` implements its own reveal animation inline with a different (and more complex) choreography including saturation manipulation and text glow effects. The widget's documented "2000ms total" duration also does not match the reveal screen's actual 4000ms animation chain.

**Fix:** Delete `lib/widgets/transitional_reveal_image.dart`, or if it is intended for future reuse, add a comment documenting the intended consumer. Dead widgets increase maintenance surface and create confusion about which implementation is canonical.

## Info

### IN-01: EdgeInsets used instead of EdgeInsetsDirectional in two screens

**File:** `lib/screens/home_screen.dart:23` and `lib/screens/burdah_reveal_screen.dart:131`
**Issue:** Both files use `EdgeInsets.symmetric(horizontal: ...)` instead of `EdgeInsetsDirectional.symmetric(horizontal: ...)`. The project's CLAUDE.md "What NOT to Use" section explicitly calls out hardcoded `left`/`right` padding and recommends `EdgeInsetsDirectional` throughout.

For symmetric horizontal/vertical padding the rendered result is identical in both LTR and RTL, so this is not a functional bug. However, it violates the stated project convention and could mask real issues if the padding is later changed to asymmetric values.

**Fix:** Replace with `EdgeInsetsDirectional.symmetric(horizontal: 24, vertical: 16)` and `EdgeInsetsDirectional.symmetric(horizontal: 40, vertical: 24)` respectively.

---

_Reviewed: 2026-07-26T12:00:00Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
