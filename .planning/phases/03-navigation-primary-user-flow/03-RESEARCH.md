# Phase 3: Navigation & Primary User Flow - Research

**Researched:** 2026-07-26
**Domain:** Flutter declarative navigation (go_router), staged widget animation, dependency injection via `provider`
**Confidence:** MEDIUM-HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

- **D-01:** Drop geometric border frames from all screens going forward — the app should be simple and clean, not ornate. The existing `GeometricBorderFrame` and `GeometricCardFrame` widgets are no longer used. — **Reversibility:** reversible — widgets still exist in codebase if needed later.
- **D-02:** No app title, header text, or decorative elements on the home screen — just a single prominent "Burdah" button on a plain themed background (green/cream palette from Phase 1 still applies).
- **D-03:** Home screen is minimal: plain themed background with one centered "Burdah" button (use `GoldCtaButton` or equivalent). No app name, no Arabic calligraphy header, no geometric framing. Just the button.
- **D-04:** Simple list rows for burdah entries, not cards. Each row shows the burdah's Arabic title, tappable. Minimal styling — no card frames, no geometric decoration.
- **D-05:** When user taps a burdah entry (Sayyida Khadija RA), a transitional image of her resting place fades in, glows stronger to peak brightness, then fades out — 2 seconds total. After fade-out, the PDF reader opens. — **Reversibility:** costly — the image transition is burdah-specific (each future burdah could have its own transitional image), so the pattern needs to be extensible.
- **D-06:** Image asset is `IMG_1131.jpeg` (already in project root, needs to be moved to assets/).
- **D-07:** The resting place image is an entry-only experience — navigating back from the reader to the list does NOT replay the image, just a simple fade.
- **D-08:** All screen-to-screen transitions (Home ↔ List, List ↔ Reader, back navigation) use gentle fade transitions — not the default Material slide-from-right.
- **D-09:** The transitional image fade (D-05) is visually distinct from the regular screen fade — it has the glow/intensity build-up effect, not just a simple opacity change.

### Claude's Discretion

- **Burdah list presentation details:** Claude decides the specific list row styling, text sizing, and spacing that looks clean and natural with the existing theme.
- **go_router route structure:** Claude decides the route definitions, path naming, and how burdah ID is passed to the reader screen.
- **Fade transition timing:** Claude decides the duration and easing curves for the gentle screen-to-screen fades (Home ↔ List, back navigation). The transitional image is locked at 2 seconds.
- **Back navigation chrome:** Claude decides whether to use AppBar back arrows, system back gesture, or both — standard Flutter/platform conventions apply.

### Deferred Ideas (OUT OF SCOPE)

None — discussion stayed within phase scope

</user_constraints>

## Summary

Phase 3 wires three new/updated screens (Home, Burdah List, a transitional "reveal" screen) and one existing screen (`BurdahReaderScreen` from Phase 2) into a `go_router`-based navigation stack, replacing the current `MaterialApp(home: DesignSystemTestScreen())` walking-skeleton wiring. `go_router ^17.3.0` and `provider ^6.1.5+1` are already declared in `pubspec.yaml` (added in Phase 1) and confirmed current on pub.dev — no version changes needed. The only new dependency this phase should consider is `flutter_animate ^4.5.x`, already vetted and recommended in `.claude/CLAUDE.md`'s stack research for exactly this kind of one-off choreographed animation (fade → glow build → fade), pulled forward from its original Phase 4 (splash) use case.

The trickiest technical decision is **how back navigation and screen-to-screen fade transitions interact with the transitional reveal image**. Research surfaced conflicting community claims about whether `go_router`'s nested-route `.go()` calls automatically build a back stack. To avoid that ambiguity entirely, this research recommends a **flat, non-nested route table** combined with `context.push()` for all forward navigation (Home→List, List→Reveal→Reader) and `pushReplacement()` specifically to swap the reveal screen out for the reader screen once the 2-second animation completes. This guarantees the automatic AppBar back button and system/gesture back button "just work" (verified go_router behavior: an in-app back button appears automatically whenever more than one page is on the Navigator stack), and it naturally satisfies D-07 ("back from reader does not replay the image") because the reveal screen is removed from the stack by the time the reader is showing.

**Primary recommendation:** Use a flat `GoRouter` route list (`/`, `/burdahs`, `/burdahs/:id/reveal`, `/burdahs/:id`) with `context.push()`/`pushReplacement()` for navigation, `CustomTransitionPage` + `FadeTransition` on every route for the gentle screen fade (D-08), a dedicated extensible `BurdahRevealScreen` widget driving the glow animation (D-05/D-09) via `flutter_animate`'s chainable `.then()` API, and `provider` at the app root exposing `BurdahRepository` so route builders can resolve burdah-by-id without re-fetching the whole catalog per screen.

## Architectural Responsibility Map

> Flutter mobile app — no server/CDN tiers apply. Tiers adapted to the client-app architecture already established in Phases 1-2.

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Home screen display (single CTA) | Presentation (Widget) | — | Static UI, no data dependency |
| Burdah list rendering | Presentation (Widget) | Data/Repository | Widget renders rows; `BurdahRepository.getAll()` supplies content (ARCH-03) |
| Route-to-route navigation & back stack | Routing (go_router) | — | Sole owner of push/pop/back-button semantics |
| Screen-to-screen fade transition (D-08) | Routing (go_router) | — | `CustomTransitionPage.transitionsBuilder`, not widget-level |
| Burdah ID → `Burdah` object resolution | Data/Repository | Routing | `BurdahRepository.getById()`; route only carries the raw `id` string |
| Transitional glow image animation (D-05/D-09) | Presentation (Widget) | — | Self-contained, reusable widget driven by its own animation timeline |
| Repository availability across routes | Application State (Provider) | — | `Provider<BurdahRepository>` at app root; route builders use `context.read()` |
| PDF page rendering | Presentation (Widget) | — | Unchanged from Phase 2 (`PdfPageSwiper` inside `BurdahReaderScreen`) |

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| `go_router` | ^17.3.0 (already in `pubspec.yaml`; latest on pub.dev, confirmed via registry API) | Declarative routing, back-stack, custom transitions | Already the project's locked navigation choice (`.claude/CLAUDE.md`); Flutter-team-maintained; `CustomTransitionPage` gives exact control needed for D-08/D-09 |
| `provider` | ^6.1.5+1 (already in `pubspec.yaml`) | Expose `BurdahRepository` app-wide so route builders can inject it | Already the project's locked state-management choice; matches official Flutter "app-architecture" DI guidance (repositories exposed via `Provider` at the widget-tree root, read via `context.read()` inside route builders) [CITED: docs.flutter.dev/app-architecture/case-study/dependency-injection] |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `flutter_animate` | ^4.5.x (4.5.2 confirmed latest on pub.dev) | Chainable fade-in → custom glow → fade-out sequence for the D-05 reveal animation | Recommended for the reveal screen specifically because the animation is a one-off, precisely-timed 3-stage choreography — `.animate().fadeIn(duration:).then().custom(duration:, builder:).then().fadeOut(duration:)` sums to exactly 2000ms without hand-rolling `AnimationController` lifecycle/dispose bookkeeping [CITED: pub.dev/packages/flutter_animate] |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `flutter_animate` for the reveal glow | Hand-rolled `AnimationController` + `TweenSequence<double>` | No new dependency, but planner/executor must correctly manage controller `dispose()` and guard `setState` calls after the screen navigates away mid-animation — a common Flutter bug source. Only choose this if the team wants zero new deps before Phase 4. |
| Flat routes + `context.push()` | Nested `GoRoute` children + `context.go()` | Nested routes *may* auto-build a matching back stack from a single `.go()` call, but research found conflicting community claims about this exact behavior for go_router 17.x — see Open Questions. Flat + `push()` is unambiguous and independently verified. |
| `flutter_animate` custom effect | `flutter_svg`-driven radial gradient overlay for "glow" | Considered for a more literal glow-blur effect; deferred to Claude's discretion at implementation time — either a `ColorFiltered`/brightness ramp or an overlay gradient satisfies "glow stronger to peak brightness" as long as it's visually distinct from a flat fade (D-09). |

**Installation:**
```bash
flutter pub add flutter_animate
```
(`go_router` and `provider` are already installed — no action needed.)

**Version verification:** Confirmed directly against the pub.dev registry API (`https://pub.dev/api/packages/<name>`) during this research session:
- `go_router`: latest `17.3.0`, matches `pubspec.yaml`'s `^17.3.0` and `pubspec.lock`'s resolved version. [VERIFIED: pub.dev registry API]
- `flutter_animate`: latest `4.5.2`, published ~20 months ago, `is:flutter-favorite`, publisher `gskinner.com` (verified publisher badge), 4,232 likes, 928K downloads/30 days, BSD-3-Clause, source at `github.com/gskinner/flutter_animate`. [VERIFIED: pub.dev registry API]

## Package Legitimacy Audit

| Package | Registry | Age | Downloads | Source Repo | Verdict | Disposition |
|---------|----------|-----|-----------|--------------|---------|-------------|
| `go_router` | pub.dev | Years (Flutter-team package) | Very high | github.com/flutter/packages | OK | Already installed — no action |
| `provider` | pub.dev | Years | Very high | github.com/rrousselGit/provider | OK | Already installed — no action |
| `flutter_animate` | pub.dev | ~2 yrs on this major version, package itself older | 928K/30 days | github.com/gskinner/flutter_animate | OK | New addition — approved, no checkpoint needed (flutter-favorite, verified publisher) |

**Packages removed due to [SLOP] verdict:** none
**Packages flagged as suspicious [SUS]:** none

Note: the `gsd-tools package-legitimacy check` seam only supports `npm`/`pypi`/`crates` ecosystems, not Dart's `pub` ecosystem — the audit above was performed manually against the pub.dev registry API (`grantedPoints`, `likeCount`, `downloadCount30Days`, `tags`, `repository` fields), which is pub.dev's own authoritative package-quality signal set. All three packages carry verified-publisher or Flutter-team provenance with active, high-download-count source repos — no slopsquatting risk indicators present.

## Architecture Patterns

### System Architecture Diagram

```
┌─────────────┐   push('/burdahs')    ┌──────────────────┐
│ Home Screen │ ─────────────────────▶│ Burdah List Screen│
│  (route: /) │◀───────── pop ─────── │ (route: /burdahs) │
└─────────────┘                       └─────────┬─────────┘
                                                 │ tap row →
                                                 │ push('/burdahs/:id/reveal')
                                                 ▼
                                       ┌────────────────────────┐
                                       │ Burdah Reveal Screen    │   BurdahRepository
                                       │ (route: /burdahs/:id/   │◀── .getById(id)
                                       │  reveal)                │
                                       │  — fade in → glow →     │
                                       │    fade out (2s total)  │
                                       └───────────┬─────────────┘
                                                   │ animation complete →
                                                   │ pushReplacement('/burdahs/:id')
                                                   ▼
                                       ┌────────────────────────┐
                                       │ Burdah Reader Screen     │
                                       │ (route: /burdahs/:id)    │   ← unchanged
                                       │  (Phase 2, PdfPageSwiper)│     from Phase 2
                                       └───────────┬─────────────┘
                                                   │ pop (back button /
                                                   │ system gesture)
                                                   ▼
                                       Burdah List Screen (reveal NOT replayed — D-07)
```

Data flow: `BurdahRepository` (Provider-injected, singleton at app root) feeds `getAll()` to the List screen and `getById(id)` to both the Reveal screen (to resolve `transitionImageAsset`/`titleArabic`) and — indirectly, already-resolved — the Reader screen.

### Recommended Project Structure
```
lib/
├── app.dart                      # MaterialApp.router wiring (was MaterialApp(home:))
├── router/
│   └── app_router.dart           # GoRouter instance + route table
├── screens/
│   ├── home_screen.dart          # NEW — D-02/D-03
│   ├── burdah_list_screen.dart   # NEW — D-04
│   ├── burdah_reveal_screen.dart # NEW — D-05/D-06/D-07/D-09
│   └── burdah_reader_screen.dart # EXISTING (Phase 2, unchanged)
├── widgets/
│   ├── burdah_list_row.dart      # NEW — simple row, not a card (D-04)
│   ├── transitional_reveal_image.dart # NEW — reusable glow-fade widget (D-05 extensibility)
│   └── gold_cta_button.dart      # EXISTING (Phase 1, reused as-is for D-03)
├── data/
│   ├── models/burdah.dart        # EXTEND — add optional `transitionImageAsset` field
│   └── repositories/...          # UNCHANGED
└── main.dart                     # UPDATE — wrap BurdahApp in Provider<BurdahRepository>
```

### Pattern 1: MaterialApp.router + flat GoRouter table with per-route fade
**What:** Replace `MaterialApp(home:)` with `MaterialApp.router(routerConfig: appRouter)`; define every route with `pageBuilder` returning `CustomTransitionPage` + `FadeTransition` to satisfy D-08 uniformly (including into the reveal screen — the *route* transition is a plain fade; the *glow* is a separate widget-internal animation that starts once the reveal screen is already on screen, satisfying D-09's "visually distinct" requirement).
**When to use:** All routes in this phase.
**Example:**
```dart
// Source: pub.dev go_router docs (docs.page/csells/go_router/transitions) — official maintainer docs
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 400), // default is 300ms — override for "gentle"
      ),
    ),
    GoRoute(
      path: '/burdahs',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const BurdahListScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    ),
    GoRoute(
      path: '/burdahs/:id/reveal',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: BurdahRevealScreen(burdahId: state.pathParameters['id']!),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    ),
    GoRoute(
      path: '/burdahs/:id',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: BurdahReaderLoader(burdahId: state.pathParameters['id']!),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    ),
  ],
);
```
Navigation calls: `context.push('/burdahs')` from Home; `context.push('/burdahs/${burdah.id}/reveal')` from a list row tap; `context.pushReplacement('/burdahs/${burdah.id}')` from inside the reveal screen once its animation completes. Back navigation (`AppBar` back arrow + system/gesture back) is automatic once more than one page is on the stack — no manual `WillPopScope`/`PopScope` needed for the base flow. [CITED: go_router official docs — "go_router provides an in-app back button in the AppBar automatically whenever the matched route results in more than one screen on the Navigator"]

### Pattern 2: Route param → repository resolution (never trust the raw ID)
**What:** `GoRoute` path parameters are raw strings from the URL/route. Never use `state.pathParameters['id']` directly to build a file path (e.g. never do `'assets/pdfs/$id.pdf'`). Always resolve through `BurdahRepository.getById(id)` first, and handle the `null` (not-found) case with the existing "Something's not right" error copy pattern established in Phase 1's `DesignSystemTestScreen`.
**When to use:** Every screen (`BurdahRevealScreen`, `BurdahReaderLoader`) that receives a burdah ID via routing.
**Example:**
```dart
class BurdahReaderLoader extends StatelessWidget {
  const BurdahReaderLoader({super.key, required this.burdahId});
  final String burdahId;

  @override
  Widget build(BuildContext context) {
    final repo = context.read<BurdahRepository>();
    return FutureBuilder<Burdah?>(
      future: repo.getById(burdahId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final burdah = snapshot.data;
        if (burdah == null) {
          // UI-SPEC Copywriting Contract — error state (established Phase 1)
          return const Scaffold(body: Center(child: Text("Something's not right")));
        }
        return BurdahReaderScreen(burdah: burdah);
      },
    );
  }
}
```

### Pattern 3: Extensible transitional reveal image (D-05)
**What:** Add an optional `transitionImageAsset` field to the `Burdah` model (stays optional per the `Burdah.fromJson` "new fields must stay optional" contract established in Phase 1 — ARCH-03). `BurdahRevealScreen` reads this from the resolved `Burdah`, not a hardcoded path, so future burdahs can each ship their own reveal image via the catalog JSON without a code change.
**When to use:** `BurdahRevealScreen` / `TransitionalRevealImage` widget.
**Example:**
```dart
// burdah_catalog.json — add the field to the existing khadija-ra entry
{
  "id": "khadija-ra",
  "title": "Burdah of Sayyida Khadija RA",
  "titleArabic": "بردة أم المؤمنين سيدتنا خديجة",
  "pdfAsset": "assets/pdfs/burdah_khadija_ra.pdf",
  "transitionImageAsset": "assets/images/khadija_resting_place.jpeg",
  "sortOrder": 1
}
```
```dart
// Source: pub.dev/packages/flutter_animate — official README chaining example
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
          // "glow stronger to peak brightness" — brighten toward peak at value==1, ease back
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
**Fallback behavior (not covered by CONTEXT.md — flag for planner):** the only current catalog entry (`khadija-ra`) will always have `transitionImageAsset` set, so this isn't blocking for v1. But since D-05 explicitly anticipates future burdahs each having their own image, the planner should decide: if a future burdah's `transitionImageAsset` is `null`, does the list-row tap skip straight to `pushReplacement`-free `push('/burdahs/:id')` (no reveal), or is a reveal image mandatory for every catalog entry going forward? Recommend documenting this as a light validation note rather than blocking Phase 3 execution, since only one burdah exists today.

### Anti-Patterns to Avoid
- **Wrapping the reveal screen's animation in the route-level `CustomTransitionPage.transitionsBuilder`:** The route fade (D-08) and the glow fade (D-05/D-09) are different animations serving different purposes — conflating them (e.g. trying to make the *page transition itself* do the glow) makes the glow non-reusable per-burdah and couples it to routing internals. Keep them as two separate layers (see Pattern 1 vs Pattern 3).
- **Using `context.go()` for the List→Reveal→Reader chain:** `.go()` navigates by declarative location match and its exact back-stack behavior for this flat (non-nested) route table was not confirmed as reliably building an implicit stack during this research (see Open Questions) — use `.push()`/`pushReplacement()` instead, which unambiguously always adds to (or swaps the top of) the Navigator stack.
- **Reading `BurdahRepository` via `Provider.of(context)` inside a `redirect:` callback:** community reports (GitHub flutter/flutter#127313) note Provider context lookups can behave unreliably inside go_router's `redirect` function specifically. Not needed for this phase (no redirects planned), but worth flagging if the planner considers adding one later — prefer resolving repository state at `runApp()` time or within route `builder`/`pageBuilder` callbacks instead.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|--------------|-----|
| Screen-to-screen transition animation | Custom `PageRouteBuilder` from scratch | `CustomTransitionPage` (go_router built-in) | go_router already wraps `PageRouteBuilder` correctly for its own Navigator/back-stack integration; hand-rolling a separate `PageRouteBuilder` risks fighting go_router's own page management |
| Multi-stage choreographed widget animation (fade/glow/fade) | Manual `AnimationController` + multiple `Tween`s + manual `dispose()` bookkeeping | `flutter_animate`'s `.animate().effect().then().effect()...` chain | Removes the most common source of Flutter animation bugs in a small app — forgetting `dispose()` or calling `setState` after the widget is unmounted mid-navigation |
| Back-button / back-stack logic | Custom `WillPopScope`/`PopScope` handlers on every screen | go_router's automatic AppBar back button + system back gesture handling | This is exactly what go_router is designed to solve; only reach for `PopScope` if a screen needs to *intercept* back (not needed anywhere in this phase's flow) |

**Key insight:** Every piece of navigation and animation infrastructure needed for this phase already exists in the two locked-in packages (`go_router`, and `flutter_animate` pulled forward from Phase 4). The only genuinely new code this phase writes is the *content* (screens, the reveal widget's specific glow curve) — not the underlying navigation/animation machinery.

## Common Pitfalls

### Pitfall 1: Forgetting the `MaterialApp` → `MaterialApp.router` swap breaks silently
**What goes wrong:** `go_router` routes are defined but `app.dart` still uses `MaterialApp(home: ...)` — routes never fire, app still shows the old screen.
**Why it happens:** `MaterialApp(home:)` and `MaterialApp.router(routerConfig:)` are mutually exclusive constructors; it's easy to add a `GoRouter` instance without remembering to swap the `MaterialApp` constructor that consumes it.
**How to avoid:** This is an explicit Integration Point already flagged in `03-CONTEXT.md` — verify `app.dart` uses `MaterialApp.router` before considering routing "done."
**Warning signs:** Tapping the Burdah CTA does nothing, or navigates via the old `Navigator.push` pattern still present in `DesignSystemTestScreen`.

### Pitfall 2: `context.go()` silently drops the back stack
**What goes wrong:** Using `.go()` instead of `.push()` for forward navigation on a flat (non-nested) route table means each call can replace the current page instead of stacking it, so the AppBar back button never appears and the Android system back button exits the app instead of going to the previous screen — a direct violation of NAV-03.
**Why it happens:** `.go()` and `.push()` look interchangeable in trivial examples; the stacking difference only becomes visible when you actually test back navigation.
**How to avoid:** Use `.push()`/`pushReplacement()` exclusively for this phase's forward navigation (see Pattern 1). Explicitly test the full back chain (Reader→List→Home) as part of verification, not just forward taps.
**Warning signs:** No back arrow appears in the AppBar on the List or Reader screens.

### Pitfall 3: New image asset not registered in `pubspec.yaml`
**What goes wrong:** `IMG_1131.jpeg` is moved into `assets/images/` but `Image.asset('assets/images/khadija_resting_place.jpeg')` throws an asset-not-found exception at runtime.
**Why it happens:** The current `pubspec.yaml` only lists `assets/images/svg/` explicitly, not the parent `assets/images/` directory — Flutter does not auto-discover new files in a directory that isn't itself declared.
**How to avoid:** Add the specific file (or the `assets/images/` directory) to `pubspec.yaml`'s `flutter: assets:` list, then `flutter pub get`.
**Warning signs:** `Unable to load asset` exception on first tap of a burdah list row.

### Pitfall 4: Animation controller/dispose lifecycle bugs during navigation
**What goes wrong:** If the reveal screen is hand-rolled with a raw `AnimationController` instead of `flutter_animate`, navigating away before the 2-second animation finishes (e.g. rapid back-taps, hot-reload during dev) can trigger a `setState() called after dispose()` crash.
**Why it happens:** The reveal screen auto-navigates itself (`pushReplacement`) at animation-end via a callback; if the widget is disposed before that callback fires (user backs out mid-animation), the callback still tries to touch a disposed `BuildContext`/state.
**How to avoid:** Guard the `pushReplacement` callback with `if (!context.mounted) return;` (or equivalent `mounted` check) before navigating; prefer `flutter_animate`'s `onComplete` callback, which is scoped correctly to widget lifecycle.
**Warning signs:** Rapid tap-back-during-reveal crashes with a disposed-widget error in debug console.

### Pitfall 5: Route param used directly to build a file path
**What goes wrong:** `state.pathParameters['id']` is a raw string from routing (could theoretically be manipulated via a crafted deep link, though this app has no external deep-linking surface today) — building `'assets/pdfs/$id.pdf'` directly instead of resolving through `BurdahRepository.getById(id)` skips the existing FormatException/not-found safety net Phase 1 already built.
**Why it happens:** It looks like a shortcut since the ID pattern (`khadija-ra`) already matches the asset naming loosely.
**How to avoid:** Always resolve `Burdah` objects through the repository (Pattern 2) — never interpolate route params into asset paths.
**Warning signs:** N/A today (single catalog entry) but becomes a real risk the moment a second burdah is added with a mismatched ID/filename pattern.

## Code Examples

### Registering the Provider-based repository at app root
```dart
// Source: docs.flutter.dev/app-architecture/case-study/dependency-injection — official Flutter guidance
// main.dart
void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(
    Provider<BurdahRepository>(
      create: (_) => AssetBurdahRepository(),
      child: const BurdahApp(),
    ),
  );
}
```
```dart
// app.dart
class BurdahApp extends StatelessWidget {
  const BurdahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'BurdahApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
```

### Burdah list row (D-04 — simple row, not a card)
```dart
// Illustrative — no direct upstream source; follows established
// Directionality(rtl) pattern from Phase 1's DesignSystemTestScreen
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

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|-------------------|---------------|--------|
| `MaterialApp(home: Widget)` + imperative `Navigator.push` | `MaterialApp.router(routerConfig: GoRouter(...))` | go_router has been the Flutter-team-endorsed default since Navigator 2.0 stabilized (well before this project's start) | Declarative route table, automatic back-button/back-stack handling, and typed transition control (`CustomTransitionPage`) instead of manually building `MaterialPageRoute`s |

**Deprecated/outdated:**
- Nothing specific to flag as deprecated within this phase's scope — `go_router` 17.x and `flutter_animate` 4.5.x are both current, actively maintained majors.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|----------------|
| A1 | Flat (non-nested) `GoRoute` list + `context.push()`/`pushReplacement()` reliably produces the automatic AppBar back button and system-back-gesture pop for this exact 4-route chain (Home→List→Reveal→Reader) on go_router 17.3.0 | Architecture Patterns — Pattern 1, Anti-Patterns | If wrong, NAV-03 ("navigate back... using standard back navigation") could silently fail on List or Reader screens; must be explicitly verified during Phase 3 execution/verification (push a burdah, confirm back arrow appears and system back works at every step) rather than assumed from research alone |
| A2 | `flutter_animate`'s `.then()` timing model sums sequential effect durations exactly (no implicit overlap/gap) as documented on pub.dev | Standard Stack, Pattern 3 | If timing doesn't sum exactly to 2000ms as expected, the D-05 "2 seconds total" spec could be off by tens-to-hundreds of ms — low risk (would just need duration tuning, not a redesign) |
| A3 | A `ColorFiltered`/`BlendMode.screen` white overlay ramp is a reasonable technical approach to "glow stronger to peak brightness" (D-05/D-09) | Pattern 3 code example | This is one illustrative implementation, not a locked decision — CONTEXT.md leaves exact glow mechanism to Claude's discretion; if it doesn't read as "reverent" enough visually, swap for a radial-gradient overlay or a subtle scale+opacity combo instead |

**If this table is empty:** N/A — see entries above.

## Open Questions

1. **Does go_router 17.x's nested-`GoRoute` + `.go()` combination auto-build a back stack from a single declarative call?**
   - What we know: One community source states yes ("navigating from /home to /home/settings adds settings to the stack, auto-showing a back button"); a second (AI-summarized official-docs fetch) states `.go()` *replaces* the whole stack and recommends `.push()` for back-stack behav0r instead.
   - What's unclear: Which claim is authoritative for the exact go_router 17.3.0 behavior; the two sources appear to describe different route configurations (nested-route nav vs. flat-route nav).
   - Recommendation: Sidestepped for this phase by using flat routes + explicit `.push()`/`pushReplacement()` everywhere (Pattern 1), which is unambiguous regardless of how nested-route `.go()` behaves. Revisit only if a future phase needs deep-linking/URL-driven navigation, where flat + push has its own tradeoff (browser/URL history won't reflect nav state) — not a concern for this offline mobile-only app.

2. **Should `DesignSystemTestScreen` be deleted or kept as a dev-only route?**
   - What we know: `03-CONTEXT.md`'s Integration Points flags this as an open item ("should be removed or kept as dev-only") but it's not covered by a locked Decision or listed under Claude's Discretion.
   - What's unclear: Whether the planner should schedule its removal as an explicit task, or leave it present-but-unreachable (orphaned, still compiles, just no longer the app's `home`).
   - Recommendation: Planner should make an explicit call — likely delete it now since Phase 1's verification purpose is fully superseded by real screens, and CONTEXT.md's "simple, not extravagant" theme (D-01/D-02) suggests minimizing dead code. Low risk either way.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|-------------|-----------|---------|----------|
| Flutter SDK | Entire phase | ✓ | 3.44.8 (stable) | — |
| Dart SDK | Entire phase | ✓ | 3.12.2 (bundled with Flutter) | — |
| `go_router` pub package | Routing | ✓ | 17.3.0 (already resolved in `pubspec.lock`) | — |
| `provider` pub package | Repository DI | ✓ | 6.1.5+1 (already resolved in `pubspec.lock`) | — |
| `flutter_animate` pub package | Reveal glow animation | ✗ (not yet added) | latest 4.5.2 on pub.dev | Hand-rolled `AnimationController`/`TweenSequence` (see Alternatives Considered) — fully viable fallback, no blocker |
| `IMG_1131.jpeg` source asset | Transitional reveal image (D-06) | ✓ | present at project root, 526×636px JPEG, 127KB | — needs move to `assets/images/` + `pubspec.yaml` registration (Pitfall 3) |

**Missing dependencies with no fallback:** none.
**Missing dependencies with fallback:** `flutter_animate` — not yet installed; fallback (hand-rolled animation) exists and is fully viable if the team prefers zero new deps this phase.

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-------------------|
| NAV-01 | User sees a home screen with a prominent "Burdah" button styled with Islamic geometric design | Home screen uses existing `GoldCtaButton` (Pattern in Recommended Project Structure) per D-02/D-03; note the tension between the original requirement wording ("Islamic geometric design") and CONTEXT.md's D-01/D-02 which explicitly drop geometric framing — CONTEXT.md's locked decisions take precedence, "prominent" is satisfied via size/color/centering, not literal geometric border widgets. Planner should note this reconciliation. |
| NAV-02 | User can tap "Burdah" to open a list of available burdah poems | `context.push('/burdahs')` (Pattern 1) → `BurdahListScreen` sourced from `BurdahRepository.getAll()` (Architectural Responsibility Map) |
| NAV-03 | User can navigate back from any screen to the previous screen | Flat route table + `context.push()`/`pushReplacement()` (Pattern 1) guarantees automatic AppBar back button + system back gesture at every step; see Open Question 1 and Assumption A1 for the one unverified edge |
</phase_requirements>

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|----------------|---------|--------------------|
| V2 Authentication | No | Single-user offline app, no accounts (per REQUIREMENTS.md Out of Scope) |
| V3 Session Management | No | No sessions |
| V4 Access Control | No | No user roles/permissions |
| V5 Input Validation | Yes | Route path parameter (`:id`) must always be resolved through `BurdahRepository.getById()` before use — never interpolated directly into an asset file path (Pattern 2, Pitfall 5) |
| V6 Cryptography | No | Not applicable to this phase |

### Known Threat Patterns for this stack

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|-----------------------|
| Unvalidated route parameter used to construct a file/asset path (path-traversal-adjacent) | Tampering | Resolve every `id` through the repository layer (`getById`), which validates against the known catalog rather than trusting the raw string; return the established "Something's not right" error state on a `null` result instead of attempting a raw asset load |
| Unhandled exception on malformed/missing catalog entry crashing the reader flow | Denial of Service | Already mitigated by Phase 1's `CatalogLoadException`/`FormatException` handling in `AssetBurdahRepository` — Phase 3 screens must surface these via the existing error-state UI copy pattern rather than letting them propagate unhandled through the new routes |

## Sources

### Primary (HIGH confidence)
- pub.dev registry API (`https://pub.dev/api/packages/go_router`, `.../flutter_animate`) — version, publish date, score/tags fetched directly, 2026-07-26
- `docs.flutter.dev/app-architecture/case-study/dependency-injection` — official Flutter documentation on Provider-based DI with go_router route builders
- `pub.dev/packages/flutter_animate` — official package README, sequential `.then()` chaining and `CustomEffect` API

### Secondary (MEDIUM confidence)
- `docs.page/csells/go_router/transitions` — go_router maintainer (Chris Sells, Google)'s docs mirror; `CustomTransitionPage` fade example and default `transitionDuration` (300ms)
- WebSearch — go_router automatic back-button behavior ("in-app back button in AppBar provided automatically when more than one screen is on the Navigator")

### Tertiary (LOW confidence)
- WebSearch — conflicting claim about `.go()` on nested routes replacing vs. building the back stack; not independently resolved this session, see Open Question 1
- WebSearch — general Flutter `AnimationController`/`TweenSequence` fade/glow pattern background (used only as conceptual background, not a locked implementation)

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — both core packages already installed and version-confirmed against pub.dev registry directly; `flutter_animate` independently verified as a legitimate, high-quality, actively-favorited package
- Architecture: MEDIUM — route/transition/DI patterns are well-documented and cross-checked against official sources, but the nested-route back-stack ambiguity (Open Question 1) is the one gap; mitigated by choosing the unambiguous flat+push design
- Pitfalls: MEDIUM-HIGH — pitfalls 1, 3, 5 are project-specific and high-confidence (directly traceable to this codebase's current state); pitfalls 2 and 4 are general go_router/Flutter animation gotchas, cross-referenced against community reports

**Research date:** 2026-07-26
**Valid until:** ~2026-08-25 (30 days — Flutter/go_router/flutter_animate are all stable, slow-moving majors; re-verify exact versions only if Phase 3 execution is delayed significantly past this window)
</content>
