# Walking Skeleton — BurdahApp

**Phase:** 1
**Generated:** 2026-07-24

## Capability Proven End-to-End

A user launches the app and sees catalog data (Burdah of Sayyida Khadija RA title in English and Arabic) rendered with Islamic calligraphic fonts (Scheherazade New for display, Amiri for body) on a themed screen using the Islamic green/gold/cream color palette, with both light and dark theme variants.

## Architectural Decisions

| Decision | Choice | Rationale |
|---|---|---|
| Framework | Flutter 3.44.x (latest stable) | Cross-platform Android + iOS with single codebase; native-quality custom animations and UI for the sacred-text reading experience. Always pin to whatever `flutter --version` reports as stable at scaffold time. |
| Data layer | Local JSON manifest + rootBundle (no database) | Offline-first (ARCH-01); catalog data is static bundled content. Repository pattern (`BurdahRepository` abstract + `AssetBurdahRepository` concrete) abstracts the source so future extensibility (e.g., downloadable catalogs) requires no architectural change. |
| Auth | None | No user accounts — explicitly out of scope (REQUIREMENTS.md). |
| State management | Provider ^6.1.x | Lowest-ceremony option for simple, static state needs (selected burdah, theme mode). Matches CLAUDE.md locked stack choice. |
| Navigation | go_router ^17.x (routing config deferred to Phase 3) | Dependency added now for stack consistency; actual route configuration happens in Phase 3 when screens exist (NAV-01 through NAV-03). |
| PDF rendering | pdfrx (deferred to Phase 2) | Not added as a dependency until Phase 2 — no PDF rendering in this phase, only the catalog entry referencing the PDF asset path. |
| Deployment target | Android emulator + iOS simulator (local dev) | Store submission packaging deferred to Phase 4. |
| Directory layout | Grouped by type: `theme/`, `data/`, `widgets/`, `screens/` | Small app scope (single developer, 5-6 screens at full v1); feature-folders premature at this scale per community consensus. |
| Design system | `ThemeData` + `ThemeExtension<BurdahColors>` + bundled Google Fonts | Flutter-native theming with custom gold/green/cream tokens; no component-registry tooling (not applicable to Flutter). Both light and dark themes from day one (D-03). |
| Asset delivery | Bundled with app binary (fonts, SVGs, PDFs, JSON) | Fully offline — no runtime network fetches for any asset class. `GoogleFonts.config.allowRuntimeFetching = false` enforced. |

## Stack Touched in Phase 1

- [x] Project scaffold (Flutter create, dependencies, lint, test runner)
- [x] Routing — `MaterialApp.home` points to test screen (go_router route config deferred to Phase 3)
- [x] Data read — JSON catalog loaded via `rootBundle.loadString` through `AssetBurdahRepository` (no database; app is offline-first with bundled content)
- [x] UI — test screen displays catalog data, font samples, palette swatches, and reusable widgets
- [x] Dev run — `flutter run` on Android emulator and/or iOS simulator

## Out of Scope (Deferred to Later Slices)

- PDF rendering and reader screen (Phase 2)
- go_router route configuration and named routes (Phase 3)
- Home screen and burdah list screen (Phase 3)
- Splash animation with Bismillah text and audio (Phase 4)
- App store packaging, icons, and submission (Phase 4)
- Bookmark / last-read page persistence (v2)
- Night mode toggle UI (dark theme is built but user-facing toggle deferred)
- Text search within burdah content (v2, requires verified transcription)

## Subsequent Slice Plan

Each later phase adds one vertical slice on top of this skeleton without altering its architectural decisions:

- Phase 2: User can read the Burdah PDF page-by-page with swipe and pinch-to-zoom inside Islamic-themed reader chrome
- Phase 3: User can navigate Home, Burdah List, and Reader end-to-end using go_router, consuming the catalog and design system from Phase 1
- Phase 4: User is greeted by animated Bismillah splash with Qari Abdul Basit recitation, fading into Home; app is packaged for Play Store and App Store submission
