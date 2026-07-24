# Architecture Research

**Domain:** Flutter mobile reading app (PDF-based Islamic poetry reader, splash animation + audio, extensible content catalog)
**Researched:** 2026-07-24
**Confidence:** MEDIUM (patterns cross-corroborated across multiple current sources; package specifics from unverified web search — verify version numbers at implementation time)

## Standard Architecture

### System Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                          PRESENTATION LAYER                          │
├───────────────┬───────────────┬────────────────┬────────────────────┤
│ SplashScreen  │  HomeScreen   │ BurdahListScreen│  PdfViewerScreen    │
│ (animation +  │  ("Burdah"    │ (list of poems) │ (pdfx PageView +    │
│  audio, one-  │   button)     │                 │  pinch-zoom)        │
│  shot)        │               │                 │                     │
└───────┬───────┴───────┬───────┴────────┬────────┴──────────┬─────────┘
        │               │                │                   │
        │        go_router (declarative route table, shared across all screens)
        │               │                │                   │
├───────┴───────────────┴────────────────┴───────────────────┴─────────┤
│                    STATE / CONTROLLER LAYER (Riverpod)                │
│  ┌──────────────────┐  ┌─────────────────────┐  ┌───────────────────┐│
│  │ SplashController │  │ BurdahListProvider   │  │ PdfViewerState    ││
│  │ (animation timer, │  │ (loads catalog once, │  │ (current page,    ││
│  │  audio playback,  │  │  exposes List<Burdah>)│ │  zoom level)      ││
│  │  nav trigger)     │  │                      │  │                   ││
│  └──────────────────┘  └──────────┬───────────┘  └───────────────────┘│
├────────────────────────────────────┴────────────────────────────────┤
│                          DATA / DOMAIN LAYER                          │
│  ┌────────────┐   ┌──────────────────────┐   ┌──────────────────┐   │
│  │ Burdah      │   │ BurdahRepository      │   │ Bundled Assets    │   │
│  │ (model:     │◄──┤ (reads catalog        │◄──┤ PDFs, audio clip, │   │
│  │  id, title, │   │  manifest — asset      │   │ fonts, images     │   │
│  │  pdfPath,   │   │  JSON or const list)   │   │                    │   │
│  │  cover)     │   │                        │   │                    │   │
│  └────────────┘   └──────────────────────┘   └──────────────────┘   │
└───────────────────────────────────────────────────────────────────────┘
```

### Component Responsibilities

| Component | Responsibility | Typical Implementation |
|-----------|----------------|-------------------------|
| Native splash (pre-Flutter) | Instant logo/background shown before Dart VM is ready — avoids white/black flash | `flutter_native_splash` config in `pubspec.yaml`, generates native launch assets for Android/iOS |
| SplashScreen + SplashController | Runs the Bismillah text animation, triggers the 6.1s audio clip, coordinates fade-out timing, then navigates to Home | Riverpod `StateNotifier`/`Notifier` driving an `AnimationController`; `audioplayers` for the clip |
| HomeScreen | Simple landing screen with the primary "Burdah" CTA | Stateless widget; navigates via `go_router` |
| BurdahListScreen + BurdahListProvider | Displays available burdah poems (starts with one: Sayyida Khadija RA) | Riverpod provider exposing `List<Burdah>` from `BurdahRepository`; `ListView.builder` |
| Burdah (domain model) | Represents one poem: id, title (Arabic + optional transliteration), PDF asset path, cover/thumbnail, ordering | Plain Dart class / `freezed` data class |
| BurdahRepository | Single source of truth for "what burdahs exist" — abstracts catalog source so adding a poem is a data change, not a code change | Reads a bundled JSON manifest (`assets/data/burdahs.json`) or a `const` list; swappable for a remote source later without touching UI |
| PdfViewerScreen | Page-by-page swipe navigation + pinch-to-zoom rendering of a single burdah's PDF | `pdfx` (`PdfViewPinch`/`PdfView` widget) fed the `Burdah.pdfPath` |
| Router | Declarative navigation graph, deep-link-ready, passes `Burdah` (or its id) from list to viewer | `go_router` route table defined once in `core/router/` |
| Theme layer | Centralizes the Turkish/Ghazali geometric palette, calligraphic type, ornamental borders | `ThemeData` + reusable `core/widgets/` (geometric border, gold CTA button) |

## Recommended Project Structure

```
lib/
├── main.dart                       # bootstraps ProviderScope + runApp
├── app.dart                        # MaterialApp.router, theme, locale/RTL config
├── core/
│   ├── router/
│   │   └── app_router.dart         # go_router route table (splash → home → list → viewer)
│   ├── theme/
│   │   ├── app_colors.dart         # turquoise/deep-blue/gold/burgundy palette
│   │   ├── app_typography.dart     # calligraphic + Arabic-safe fonts
│   │   └── app_theme.dart
│   └── widgets/
│       ├── geometric_border.dart   # reusable ornamental frame
│       └── gold_cta_button.dart
├── features/
│   ├── splash/
│   │   ├── presentation/
│   │   │   ├── splash_screen.dart
│   │   │   └── bismillah_animation.dart
│   │   └── application/
│   │       └── splash_controller.dart   # Riverpod: animation + audioplayers coordination
│   ├── home/
│   │   └── presentation/
│   │       └── home_screen.dart
│   ├── burdah_catalog/                  # shared feature: list + domain + data
│   │   ├── domain/
│   │   │   └── burdah.dart              # model
│   │   ├── data/
│   │   │   ├── burdah_repository.dart   # abstraction
│   │   │   └── burdah_catalog.dart      # reads assets/data/burdahs.json (or const list for v1)
│   │   └── presentation/
│   │       ├── burdah_list_screen.dart
│   │       └── burdah_list_item.dart
│   └── pdf_viewer/
│       └── presentation/
│           ├── pdf_viewer_screen.dart   # pdfx PageView + zoom
│           └── pdf_viewer_controls.dart # optional page indicator/back button overlay
assets/
├── pdfs/                            # burdah PDFs (one per poem)
├── audio/                           # trimmed 6.1s Bismillah clip
├── fonts/                           # calligraphic + Arabic body font
├── images/                          # geometric background/textures, app icon source
└── data/
    └── burdahs.json                 # catalog manifest (id, title, pdfPath, cover) — extensibility point
```

### Structure Rationale

- **`core/`:** Cross-cutting concerns (theme, routing, shared widgets) that every feature depends on but that no single feature owns — kept separate so features stay decoupled from each other.
- **`features/<name>/`:** Each screen's own presentation/domain/data lives together. For this app's size, only `burdah_catalog` needs all three sublayers (it has real data + a model); `splash` and `home` are presentation-only (or presentation + a thin controller).
- **`burdah_catalog` as its own feature (not split into `burdah_list` + `pdf_viewer` data):** the `Burdah` model and its repository are consumed by both the list screen and the PDF viewer screen — putting the shared domain/data in one place avoids duplicating the model or creating a circular dependency between two "vertical" features.
- **`assets/data/burdahs.json`:** Directly answers the "extensible for adding more burdahs" requirement — a new poem is a new PDF file + one new JSON entry, zero Dart code changes. Even for v1 (one entry), building the repository against this manifest from day one avoids a rewrite when poem #2 is added.

## Architectural Patterns

### Pattern 1: Native-splash handoff → Flutter animated splash

**What:** Two-stage splash. Stage 1 is a *static* native splash (`flutter_native_splash`) shown instantly before the Flutter engine boots, showing just a logo/background so there's no white/black flash. Stage 2 is a *custom Flutter widget* that takes over the instant the engine is ready, running the actual Bismillah text animation and triggering audio playback, then fading into Home.
**When to use:** Any app wanting an animated/audio splash — native splash mechanisms can't animate or play audio, so a handoff is required.
**Trade-offs:** Two things to keep in sync (native launch image + first Flutter frame) — mismatch causes a visible flicker; mitigate by making the native splash's static image match the first frame of the Flutter animation.

**Example:**
```dart
// splash_controller.dart (Riverpod)
class SplashController extends Notifier<SplashState> {
  late final AudioPlayer _player;

  @override
  SplashState build() {
    _player = AudioPlayer();
    _start();
    return const SplashState.playing();
  }

  Future<void> _start() async {
    unawaited(_player.play(AssetSource('audio/bismillah_intro.mp3')));
    await Future.delayed(const Duration(milliseconds: 6100)); // matches audio + animation length
    state = const SplashState.done();
  }
}
```

### Pattern 2: Repository abstraction over the burdah catalog

**What:** UI never reads `assets/data/burdahs.json` directly — it goes through `BurdahRepository`, which returns `List<Burdah>` domain objects.
**When to use:** Whenever a data source might change or grow (here: more burdahs added later, possibly a remote catalog eventually).
**Trade-offs:** Slight indirection overhead for a single-item v1 catalog, but removes the need for any future rewrite when the catalog grows or moves off-device.

**Example:**
```dart
class Burdah {
  final String id;
  final String title;
  final String pdfAssetPath;
  final String? coverAssetPath;
  const Burdah({required this.id, required this.title, required this.pdfAssetPath, this.coverAssetPath});
}

abstract class BurdahRepository {
  Future<List<Burdah>> getAll();
}

class AssetBurdahRepository implements BurdahRepository {
  @override
  Future<List<Burdah>> getAll() async {
    final raw = await rootBundle.loadString('assets/data/burdahs.json');
    final list = jsonDecode(raw) as List;
    return list.map((e) => Burdah(
      id: e['id'], title: e['title'], pdfAssetPath: e['pdfPath'], coverAssetPath: e['cover'],
    )).toList();
  }
}
```

### Pattern 3: Declarative routing with typed route params (go_router)

**What:** A single route table declares Splash → Home → BurdahList → PdfViewer, with the selected `Burdah` (or its id) passed through the route rather than via global/ambient state.
**When to use:** Any app with more than 1-2 screens; avoids manual `Navigator.push` scattered through the codebase and sets up deep-linking for free (useful if a "share this burdah" link is ever wanted).
**Trade-offs:** Small setup cost for an app this size, but it's the current officially-recommended pattern and scales cleanly if screens are added later.

## Data Flow

### App Launch → Reading Flow

```
App process starts
    ↓
Native splash (static, instant) — flutter_native_splash
    ↓ (Flutter engine ready, first frame)
SplashScreen mounts → SplashController.build()
    ↓                         ↓
Bismillah text animation   audioplayers plays 6.1s clip
    ↓ (both finish / timer elapses)
Fade transition → go_router.go('/home')
    ↓
HomeScreen ("Burdah" button)
    ↓ tap
go_router.go('/burdahs') → BurdahListScreen
    ↓ (on first build)
BurdahListProvider → BurdahRepository.getAll() → reads assets/data/burdahs.json
    ↓
List<Burdah> rendered (starts with 1 entry: Sayyida Khadija RA)
    ↓ tap an item
go_router.go('/burdahs/:id', extra: burdah) → PdfViewerScreen
    ↓
pdfx loads Burdah.pdfAssetPath → PageView (swipe) + PdfViewPinch (pinch-zoom)
```

### State Management

```
ProviderScope (root)
    ↓
SplashController (Notifier)  — local to splash lifecycle, disposed after navigation
BurdahListProvider (FutureProvider/AsyncNotifier) — cached after first load, re-read by both
    the list screen and (optionally) a "related burdahs" section later
PdfViewerState (per-screen Notifier) — current page index, zoom scale; scoped to the
    viewer screen instance, not shared globally
```

### Key Data Flows

1. **Splash coordination:** Two concurrent side effects (animation ticks, audio playback) must both be tracked by one controller so navigation only fires once both are "done" — prevents fading out mid-audio or mid-animation.
2. **Catalog → list → viewer handoff:** The `Burdah` object is fetched once by `BurdahRepository`, rendered in the list, then passed *by value* (via route `extra` or by id + re-lookup) into the PDF viewer — the viewer never re-reads the catalog file itself, it just needs `pdfAssetPath`.
3. **RTL/locale flow:** Directionality is set once at the `MaterialApp` level (or per-widget for the Arabic PDF title text) and flows down — it does not affect the PDF viewer itself, since the PDF page is rendered as a fixed-layout image/texture, not reflowed text.

## Scaling Considerations

For this domain, "scale" means **number of burdahs and asset/bundle size**, not concurrent users (no backend, no server load).

| Scale | Architecture Adjustments |
|-------|---------------------------|
| 1-5 burdahs (v1 target) | Bundle all PDFs + the JSON manifest as local assets; `AssetBurdahRepository` is sufficient; app size stays small |
| 5-30 burdahs | Still fine as bundled assets if PDFs are modest size; consider lazy-loading PDF bytes (don't preload all into memory) — `pdfx` already loads per-document on demand |
| 30+ burdahs / large PDFs | Bundle size becomes a real constraint (app store limits, install size); consider moving PDFs to on-demand download (e.g., Firebase Storage/CDN) behind the same `BurdahRepository` interface — this is exactly why the repository abstraction exists from day one |

### Scaling Priorities

1. **First bottleneck:** App binary size once several high-resolution PDFs are bundled — mitigate by compressing/optimizing PDFs before bundling, not by architecture changes.
2. **Second bottleneck (future, out of current scope):** If burdahs are ever added post-install without an app update, the `BurdahRepository` interface is the seam to swap `AssetBurdahRepository` for a remote-fetching implementation — no UI changes needed.

## Anti-Patterns

### Anti-Pattern 1: Hardcoding PDF paths / titles directly in widgets

**What people do:** `Image.asset('assets/pdfs/khadija.pdf')` or similar literals scattered across the list screen and viewer screen.
**Why it's wrong:** Directly violates the stated "extensible for adding more burdahs" requirement — every new poem requires hunting through UI code instead of editing one manifest.
**Do this instead:** Always go through `Burdah` model + `BurdahRepository`; UI only ever holds a `Burdah` instance.

### Anti-Pattern 2: One giant StatefulWidget for the splash screen

**What people do:** Cram `AnimationController`, `AudioPlayer`, timers, and `Navigator.push` calls directly into a single `State` class with ad-hoc `Future.delayed` chains.
**Why it's wrong:** Timing races are common (audio finishes before/after animation depending on device), and it's untestable in isolation.
**Do this instead:** Extract the coordination logic into a `SplashController` (Riverpod `Notifier`) that the widget only observes — makes the "when do we navigate" decision a single, testable piece of state.

### Anti-Pattern 3: Re-fetching or duplicating the catalog inside the PDF viewer

**What people do:** Have `PdfViewerScreen` independently re-read `burdahs.json` or hold its own copy of the burdah list "just in case."
**Why it's wrong:** Two sources of truth drift apart; also wastes an asset read on every navigation.
**Do this instead:** Pass the already-loaded `Burdah` object through the route (`go_router`'s `extra` parameter) or pass just the `id` and look it up in the already-cached `BurdahListProvider`.

## Integration Points

### External Services

None for v1 — this is a fully offline, bundled-content app (no backend, no accounts, no network calls per the Out of Scope list in PROJECT.md).

| Service | Integration Pattern | Notes |
|---------|---------------------|-------|
| (none) | — | All PDFs, audio, fonts ship inside the app bundle |

### Internal Boundaries

| Boundary | Communication | Notes |
|----------|---------------|-------|
| Splash ↔ Home | `go_router` navigation only, no shared state | Splash controller is disposed once navigation happens |
| BurdahList ↔ PdfViewer | `Burdah` object passed via route (`extra`) or id lookup | Keeps viewer decoupled from *how* the catalog was loaded |
| Theme/core ↔ all features | One-way (features read `core/theme`, never the reverse) | Prevents feature-specific styling from leaking into shared theme |
| RTL/locale ↔ presentation widgets | `Directionality`/`Locale` set at `MaterialApp` root, consumed by text widgets | Does not reach into the PDF viewer's rendering (PDF content is a fixed image, not reflowed) |

## Sources

- [syncfusion_flutter_pdfviewer | Flutter package](https://pub.dev/packages/syncfusion_flutter_pdfviewer) — MEDIUM/LOW (vendor docs, cross-checked against community comparisons)
- [pdfx | Flutter package](https://pub.dev/packages/pdfx) — LOW (web search digest, verify current version/API at build time)
- [Flutter Project Structure: Feature-first or Layer-first? — Code with Andrea](https://codewithandrea.com/articles/flutter-project-structure/) — LOW (web search digest; widely-cited community reference)
- [Flutter State Management in 2026: Riverpod vs Bloc vs Provider — dev.to](https://dev.to/lycore/flutter-state-management-in-2026-riverpod-vs-bloc-vs-provider-in-production-2i53) — LOW (web search digest, cross-corroborated by 6+ independent 2026 articles in same search)
- [flutter_native_splash discussion — GeeksforGeeks / community guides](https://www.geeksforgeeks.org/flutter-animated-splash-screen/) — LOW (web search digest)
- [audioplayers vs just_audio comparisons — Flutter Gems](https://fluttergems.dev/packages/audioplayers/) — LOW (web search digest)

All findings above are tagged LOW per the source-hierarchy seam (unverified single-pass web search) despite strong cross-source agreement — **verify exact package versions and API signatures against pub.dev at implementation time**, since these were not fetched via a documentation-verified provider (e.g. Context7).

---
*Architecture research for: Flutter Islamic reading app (PDF viewer, splash animation, extensible content catalog)*
*Researched: 2026-07-24*
