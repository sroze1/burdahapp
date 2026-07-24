# Stack Research

**Domain:** Flutter Islamic poetry/PDF reading app (mobile, Android + iOS)
**Researched:** 2026-07-24
**Confidence:** MEDIUM (WebSearch-only sourcing; no premium doc providers configured for this run — see Sources note)

## Recommended Stack

### Core Technologies

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| Flutter SDK | 3.44.x (latest stable, released May 2026) | Cross-platform app framework | Single codebase for Android + iOS with native-quality custom animation and rendering — matches the project's own stated rationale (PROJECT.md: "best for custom animations, beautiful UI, single codebase"). Always pin to whatever `flutter --version` reports as stable at project init; do not target an older LTS-style pin, this app has no legacy constraint forcing one. |
| Dart SDK | 3.12.x (bundled with Flutter 3.44) | Language runtime | Comes bundled with the Flutter SDK — no separate install/version decision needed. |
| `pdfrx` | ^2.4.x | PDF rendering, page-by-page swipe navigation, pinch-to-zoom | Renders via PDFium (the same engine Chrome uses) consistently across Android/iOS/desktop/web, unlike packages that swap rendering engines per platform. Actively maintained (published within the last month vs. 13 months of silence on the closest free alternative), free/MIT-style license, purpose-built `PdfPageView` + `PdfViewer` widgets support exactly the "book-like swipe + zoom" requirement out of the box. |
| `go_router` | ^17.x | Navigation (splash → main → burdah list → PDF viewer) | Flutter-team-maintained, Navigation-2.0-based, considered the 2026 default for new Flutter apps. Even for a small app, using it from day one avoids a painful `Navigator.push` → declarative-routing migration once you add the "more burdahs in the future" extensibility the project requires (list screen → detail route becomes a named/typed route trivially). |
| `provider` | ^6.1.x | App-wide state (selected burdah, splash-done flag, theme) | This app's state needs are simple and static (a list of burdah entries, a "which one is open" pointer, no async server state, no complex derived state graphs). Provider is the lowest-ceremony option that still gives clean separation from widgets — matches "small app" guidance from current 2026 Flutter community consensus. Do not reach for Bloc or Riverpod here; that complexity buys nothing for this scope (see "What NOT to Use"). |

### Supporting Libraries

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `flutter_native_splash` | ^2.4.x | Native OS splash (background color/logo shown before the Flutter engine boots) | Always include this — it closes the "white flash" gap between OS app-launch and Flutter's first frame. **Important limitation, confirmed during this research:** it only supports a static background color + image. It cannot play audio or run a custom text animation — that native splash hands off to your own Flutter widget the instant the engine is ready. |
| `flutter_animate` | ^4.5.x | Custom "Bismillahirrahmaanirraheem" text animation on the in-Flutter splash screen | Use this for the actual animated splash *content* (the native splash package above only covers the pre-engine gap). Chainable API — `Text('...').animate().fadeIn().slideY()` — covers fade/scale/slide/shimmer/blur effects without hand-rolling `AnimationController`/`StatefulWidget` boilerplate. Good fit for a one-off, carefully choreographed splash animation. |
| `audioplayers` | ^6.8.x | Playing the trimmed 6.1s Bismillah audio clip on splash | Recommended over `just_audio` for this specific use case: simpler API surface, no need for `just_audio`'s streaming/playlist/looping machinery for a single short bundled asset, and it is the more actively updated of the two as of this research (published within the last month). If audio needs grow later (e.g., full recitation playback per page), revisit `just_audio` then — see Alternatives. |
| `google_fonts` | ^8.2.x | Calligraphic Arabic/Islamic typography (titles, buttons, list labels — NOT the PDF page content itself, which is a rendered image) | Ships every fonts.google.com family, including Arabic options well-suited to this project's tone: **Scheherazade New** (traditional Naskh, most calligraphic/classical feel — best default for headers/titles), **Amiri** (classical Naskh, excellent readability, good for body-style UI text), **Reem Kufi** (Kufic, more geometric/ornamental — good for accents matching the Turkish/Ghazali geometric design brief). Bundle the chosen font file(s) at build time (`GoogleFonts.config.allowRuntimeFetching = false`) rather than fetching at runtime, so the splash/UI never shows a fallback font flash and the app works fully offline. |
| `flutter_launcher_icons` | ^0.14.x | Generate Android + iOS app icons from one source image | Run once per icon design finalization via `pubspec.yaml` config + `dart run flutter_launcher_icons`; supports Android adaptive icons. |
| `flutter_localizations` + `intl` (Flutter SDK-bundled) | matches Flutter SDK | RTL layout plumbing, locale-aware directionality | Needed even though this is a single-locale (Arabic content) app: use `Directionality` widget (or set `supportedLocales`/`locale` to `ar`) and `EdgeInsetsDirectional`/`AlignmentDirectional` instead of hardcoded `left`/`right` throughout custom UI, so geometric borders and layout mirror correctly for the RTL PDF content and any Arabic UI labels. |

### Development Tools

| Tool | Purpose | Notes |
|------|---------|-------|
| Android Studio + Xcode | Android/iOS toolchains, emulators/simulators, codesigning | Required regardless of editor choice — PROJECT.md notes "the user does not have mobile development tools installed," so first-phase setup must include installing both, plus CocoaPods for iOS. |
| VS Code + Flutter/Dart extensions (or Android Studio's Flutter plugin) | Day-to-day editing, hot reload, DevTools | Either works; VS Code is lighter-weight if this is a fresh dev machine setup. |
| `flutter_lints` | Static analysis / lint ruleset | Comes scaffolded by default with `flutter create`; keep it enabled rather than disabling rules, it catches directionality and const-correctness issues early which matter for a design-heavy, RTL app. |

## Installation

```bash
# Verify/install Flutter SDK first (see fvm note below if multiple projects), then:
flutter create burdah_app
cd burdah_app

# Core
flutter pub add pdfrx go_router provider

# Supporting
flutter pub add flutter_animate audioplayers google_fonts
flutter pub add flutter_native_splash flutter_launcher_icons --dev

# Generate native splash + icons after adding your design assets
dart run flutter_native_splash:create
dart run flutter_launcher_icons
```

## Alternatives Considered

| Recommended | Alternative | When to Use Alternative |
|-------------|-------------|--------------------------|
| `pdfrx` | `pdfx` | If you hit a `pdfrx` rendering bug/regression specific to your PDF, or need `pdfx`'s slightly larger installed base for community-answered edge cases. `pdfx`'s `PdfViewPinch` widget covers the same swipe+zoom requirement and is a safe fallback — just note it renders via PDF.js on web / native renderer on mobile (less visually consistent than PDFium everywhere). |
| `pdfrx` / `pdfx` | `syncfusion_flutter_pdfviewer` | Only if you later need enterprise features (text search, annotations, form-filling) that justify accepting Syncfusion's commercial license terms. Not needed for this project's read-only page-viewing requirement — avoid the licensing overhead. |
| `audioplayers` | `just_audio` | If the app later adds full-length recitation audio per burdah with playlists, background playback, or gapless looping — `just_audio` is purpose-built for that (Flutter Favorite, richer audio-session handling). For a single bundled 6.1s clip, it's unnecessary weight. |
| `provider` | `riverpod` | If the "extensible for adding more burdahs" requirement grows into something with async data sources (remote burdah catalog, downloadable content, sync), Riverpod's testability and async-first design pays off. Re-evaluate at that point rather than over-engineering now. |
| `provider` / `riverpod` | `bloc` | Only if the team scales up and wants enforced separation of business logic via strict event/state contracts — overkill for a single-developer, content-display app. |
| `go_router` | Plain `Navigator`/`MaterialPageRoute` | Only for a true one-screen prototype. This project already has 4+ distinct screens (splash → home → burdah list → PDF viewer) plus a stated future-extensibility requirement, so start with `go_router`. |

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| PDF **text extraction** libraries (e.g., `syncfusion_flutter_pdf`'s text-extraction APIs, custom OCR pipelines) | PROJECT.md explicitly scopes this out — Arabic diacritic-heavy calligraphic PDF text extraction is unreliable and risks corrupting sacred text; also unnecessary since the goal is visual page fidelity, not searchable text. | `pdfrx`/`pdfx` page-image rendering (treat the PDF as the source of visual truth) |
| Relying on `flutter_native_splash` alone for the animated/audio splash | It is confirmed (this research) to only support a static background + image before the Flutter engine loads — it cannot run an animation or play audio. Building the whole splash experience around it will hit a hard wall. | Use `flutter_native_splash` only for the pre-engine gap, then hand off immediately to a custom Flutter splash `Widget` using `flutter_animate` + `audioplayers` |
| Third-party "animated splash screen" wrapper packages (e.g., `animated_splash_screen`, `custom_animated_splash`) | These are low-adoption, inconsistently maintained convenience wrappers around exactly what `flutter_animate` + a plain `Scaffold` already do — they add a dependency and abstraction layer for something trivial to hand-roll, and give you less control over the specific choreography this project needs (custom Arabic calligraphic text reveal timed to a 6.1s audio clip). | Hand-roll the splash screen as a normal `StatelessWidget`/`StatefulWidget` using `flutter_animate` for the text and `audioplayers` for the clip, driven by a `Future.delayed`/audio-completion callback for the fade-out transition |
| Hardcoded `left`/`right` padding/alignment (`EdgeInsets.only(left: ...)`, `Alignment.centerLeft`) anywhere UI touches Arabic content | Breaks silently in RTL — geometric borders and content will mirror incorrectly, and this is easy to miss until real Arabic content is on screen. | `EdgeInsetsDirectional`/`AlignmentDirectional` + explicit `Directionality`/locale configuration from the start |
| Fetching Google Fonts at runtime (`google_fonts` default HTTP-fetch behavior) for this app | An offline-first, reverent reading app showing a fallback system font (or a network spinner) on first load while fetching a title font undermines the "distraction-free, sacred" experience the project targets. | Bundle the chosen font file(s) as local assets and set `GoogleFonts.config.allowRuntimeFetching = false`, or use `google_fonts`' asset-bundling helper at build time |

## Stack Patterns by Variant

**If future milestones add full recitation audio playback per burdah (currently out of scope):**
- Migrate from `audioplayers` to `just_audio` (or run both side-by-side — `just_audio` for content, `audioplayers` for UI sound effects)
- Because `just_audio` handles playlists, background audio, and gapless playback that a single splash clip never needed

**If future milestones add a remote/downloadable burdah catalog (currently out of scope, but "extensible" is a stated constraint):**
- Migrate state management from `provider` to `riverpod`
- Because you'll need async-first state (network/download status) and better testability than `provider`'s `ChangeNotifier` pattern gives you

**If `pdfrx` rendering has any visual fidelity issue with this specific ornate Arabic calligraphic PDF:**
- Fall back to `pdfx`'s `PdfViewPinch` widget
- Because it's the most mature free alternative with the same swipe+zoom capability, just a different (platform-native) rendering backend

## Version Compatibility

| Package A | Compatible With | Notes |
|-----------|-----------------|-------|
| `pdfrx@^2.4.x` | Flutter 3.44.x / Dart 3.12.x | No known constraint conflicts found during this research; verify against `flutter pub outdated` at project scaffold time since versions move monthly. |
| `go_router@^17.x` | Flutter 3.44.x | go_router major versions have historically tracked Flutter's Navigator API changes closely — always let `flutter pub add` resolve the version rather than hand-pinning an older major. |
| `google_fonts@^8.x` | Any current Flutter/Dart | No native dependencies; pure Dart/asset package, so compatibility risk is minimal. |
| `flutter_native_splash@^2.4.x` + `flutter_launcher_icons@^0.14.x` | Each other, any current Flutter | Both are build-time codegen tools (no runtime dependency), so they don't interact with each other or with `pdfrx`/`audioplayers` at the dependency-resolution level. |

## Sources

- WebSearch (Google-indexed results) — pub.dev package pages for `pdfrx`, `pdfx`, `audioplayers`, `flutter_native_splash`, `flutter_animate`, `google_fonts`, `provider`, `go_router`, `flutter_launcher_icons` — versions and last-published dates fetched directly from pub.dev via WebFetch on 2026-07-24. Confidence: LOW-to-MEDIUM per source-hierarchy classification (WebSearch/WebFetch, not a curated docs provider) — **treat exact version numbers as a snapshot to re-verify with `flutter pub add`/pub.dev at implementation time**, not as pinned truth.
- No Context7 or other premium documentation MCP provider was available/configured for this research session (`config` flags in the research-plan input were all `false`) — all findings sourced via built-in WebSearch/WebFetch only. This caps overall confidence at MEDIUM; roadmap/planning should re-confirm exact versions when scaffolding the project.
- Community consensus on state-management choice (Provider vs. Riverpod vs. Bloc for small apps) drawn from multiple 2026-dated blog posts found via WebSearch — directionally reliable (multiple independent sources agree) but not vendor-authoritative.

---
*Stack research for: Flutter Islamic poetry/PDF reading app*
*Researched: 2026-07-24*
