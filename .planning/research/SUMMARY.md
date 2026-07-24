# Project Research Summary

**Project:** BurdahApp
**Domain:** Flutter Islamic poetry/PDF reading app (mobile, Android + iOS) — devotional single-purpose reader, extensible to a growing collection of burdahs
**Researched:** 2026-07-24
**Confidence:** MEDIUM

## Executive Summary

BurdahApp is a reverent, single-purpose Flutter reading app that presents the Burdah poems (starting with Sayyida Khadija RA) as page-faithful, bundled PDF assets — not extracted/reflowed text — behind a short animated Bismillah splash with audio. This sits at the intersection of Quran/mushaf reader apps, existing low-effort single-poem Burda apps, and multi-work poetry apps like Rekhta. The research is consistent across all four files: the winning strategy is to nail the reverent basics (accurate PDF-of-original content, book-like swipe + pinch-zoom navigation, RTL-correct Arabic typography, offline-first, zero ads) with genuinely premium visual design — the single biggest gap versus every existing competitor in this niche, which are visually generic and often ad-cluttered.

The recommended approach is a lean, feature-first Flutter architecture: `pdfrx` for PDFium-based page rendering, `go_router` for declarative navigation, `provider` (or Riverpod if extensibility grows sooner than expected) for simple state, and a `BurdahRepository` abstraction over a bundled JSON catalog manifest from day one — so the stated "extensible for adding more burdahs" requirement is architecturally real even though v1 ships exactly one poem. A two-stage splash (static native splash → custom animated Flutter widget with `flutter_animate` + `audioplayers`) delivers the differentiator splash experience without over-relying on native splash tooling's real limitations.

The key risks cluster around three technically thin areas that "look done but aren't": (1) PDF viewer memory/gesture behavior only fails on real mid-range devices with the actual production PDF, never in a simulator with a placeholder; (2) Arabic calligraphic font shaping (letter joining, weights, RTL justification) has multiple open, version/engine-dependent Flutter bugs and must be verified against the real Flutter version/rendering engine before font selection is locked in; (3) iOS silent-mode audio behavior for the sacred splash clip requires manual `AVAudioSession` configuration and physical-device testing, since the simulator cannot reproduce this bug class. All three risks are cheap to catch early (dedicated device testing steps) and expensive to fix late (font relock touches the whole typography system).

## Key Findings

### Recommended Stack

Flutter 3.44.x / Dart 3.12.x is the correct cross-platform base — a single codebase for Android + iOS supporting the custom-animation, beautiful-UI requirement the project is built around. `pdfrx` (PDFium-backed, actively maintained) is the recommended PDF renderer over `pdfx`/Syncfusion, avoiding both a stale dependency and Syncfusion's commercial licensing overhead for a read-only viewing use case. `go_router` is recommended from day one despite the app's small size, because it avoids a painful migration once the extensibility requirement (list → detail routing) matures. State is intentionally kept simple: `provider` for v1 (no async/server state needed), with an explicit, documented upgrade path to `riverpod` if a remote/downloadable burdah catalog is ever added.

**Core technologies:**
- Flutter SDK 3.44.x / Dart 3.12.x — cross-platform framework, matches PROJECT.md's own stated rationale
- `pdfrx` ^2.4.x — PDFium page rendering, swipe + pinch-zoom, consistent engine across platforms
- `go_router` ^17.x — declarative navigation, avoids future Navigator migration
- `provider` ^6.1.x — simple app-wide state (selected burdah, splash-done flag); do not reach for Bloc/Riverpod at this scope
- `flutter_native_splash` + `flutter_animate` + `audioplayers` + `google_fonts` (bundled, not runtime-fetched) — splash/typography supporting stack

### Expected Features

The domain has clear, cross-corroborated table stakes drawn from Quran-reader apps, existing single-poem Burda apps, and Rekhta (multi-work poetry). BurdahApp's stated v1 scope already matches the correct table-stakes + differentiator set almost exactly — feature research validates rather than expands PROJECT.md's plan.

**Must have (table stakes):**
- Complete, accurate Arabic PDF content; pinch-to-zoom; book-like swipe page navigation
- Fully offline access (bundled assets, no network dependency)
- No ads/interstitials — the #1 complaint against category leaders like Muslim Pro
- Fast, distraction-free launch to content; RTL-correct rendering wherever Arabic UI text appears

**Should have (competitive differentiators):**
- Premium Islamic geometric/calligraphic visual design (Turkish/Ghazali motif) — the single biggest gap versus every existing low-effort Burda app
- Animated Bismillah splash + audio — no competitor does anything beyond a static logo
- Extensible multi-burdah data model + curated list UI, built now even for one entry

**Defer (v1.x / v2+):**
- Night/reading-mode theme, bookmarking/last-read-position — add once a second burdah ships and real usage data exists
- Search within text — only after a verified (non-OCR) transcription exists
- Full per-burdah recitation audio (distinct from splash clip) — largest scope item in the domain, requires licensed audio + sync; explicitly out of v1 scope
- Anti-features to actively avoid: ads, feature-creep "super-app" additions, PDF text extraction/OCR, social sharing of verses, accounts/cloud sync, IAP/premium tiers

### Architecture Approach

A feature-first Flutter structure with a `core/` layer (router, theme, shared widgets) and `features/` folders for `splash`, `home`, `burdah_catalog` (shared domain + data + list UI), and `pdf_viewer`. The catalog is the extensibility seam: UI never touches `assets/data/burdahs.json` directly — everything flows through a `Burdah` domain model and `BurdahRepository` abstraction, so adding a poem later is a data change, not a code change. Splash is architecturally independent of the reader (built/tested in parallel); the PDF viewer only ever needs a `Burdah.pdfAssetPath` passed via route, never re-reading the catalog itself.

**Major components:**
1. Native splash → animated `SplashScreen`/`SplashController` — one-shot Bismillah animation + audio coordination, disposed after navigation
2. `BurdahRepository` + `Burdah` domain model — single source of truth for what burdahs exist, backed by a bundled JSON manifest
3. `BurdahListScreen` — renders the catalog (1 entry in v1), the extensibility groundwork
4. `PdfViewerScreen` — `pdfrx`/`pdfx` page-by-page swipe + pinch-zoom rendering fed by `pdfAssetPath`
5. `go_router` route table + `core/theme` — cross-cutting navigation and Islamic geometric/calligraphic design system

### Critical Pitfalls

1. **PDF viewer memory leaks / OOM on real devices** — only surfaces after 10-30+ zoom/pan/page-turn cycles on actual mid-range hardware with the real production PDF; use lazy/on-demand page rendering and stress-test early, not just "PDF opens" as the bar.
2. **Gesture conflict between page-swipe and pinch-zoom** — both claim horizontal drag; lock `PageView` swipe physics whenever zoom scale ≠ 1x, re-enable only at reset zoom. Explicit UAT: zoom in, then attempt pan/swipe in all directions.
3. **Arabic font shaping breaks (disconnected letters, wrong weights, bad RTL justify)** — version/engine-dependent Flutter bugs; render the actual Burdah text sample on the pinned Flutter version and both Skia/Impeller before locking in a font, in a dedicated typography-setup phase before content/animation work.
4. **RTL/LTR mixed-direction bugs beyond "flip the layout"** — custom animations/transitions need per-screen, per-transition RTL verification, not a single global `Directionality` setting; this app's splash animation and page transitions are exactly the hand-rolled components this bites.
5. **Native splash white flash cannot be fully eliminated** — `flutter_native_splash` only recolors/matches the OS pre-render screen; it never plays the actual animated Bismillah splash. Configure it to visually match the first Flutter frame so the handoff feels seamless, and test cold-launch on a real low-end device.

## Implications for Roadmap

Based on research, suggested phase structure:

### Phase 1: Foundation & Extensible Data Architecture
**Rationale:** The `Burdah` model + `BurdahRepository` abstraction over a JSON manifest must exist before any screen is built — retrofitting a hardcoded single entry into a real catalog later is exactly the rework PROJECT.md's extensibility requirement is meant to prevent. Also establishes project scaffolding, theme/typography foundation, and RTL/`Directionality` setup at the app root.
**Delivers:** Flutter project scaffold, `core/` (router skeleton, theme shell, RTL config), `burdah_catalog` domain model + repository reading a bundled JSON manifest with one entry.
**Addresses:** Extensible burdah list/data model (differentiator), RTL correctness (table stakes).
**Avoids:** Anti-Pattern — hardcoding PDF paths/titles in widgets; non-extensible data structure pitfall.

### Phase 2: Typography & Design System
**Rationale:** Font shaping/weight/RTL-justify bugs are foundational and expensive to fix once content work has built on top of a broken font choice — must be locked in before PDF/animation work, per PITFALLS.md's explicit phase mapping.
**Delivers:** Calligraphic Arabic font selection verified via a throwaway test screen (letter joining, weights, Skia/Impeller) on both platforms; Islamic geometric palette (turquoise/gold/burgundy) and reusable themed widgets (geometric border, gold CTA button).
**Uses:** `google_fonts` (bundled, not runtime-fetched), `flutter_lints`.
**Implements:** `core/theme` layer.

### Phase 3: PDF Viewer (Reading Experience)
**Rationale:** Core value proposition and highest-risk technical component (memory + gesture pitfalls) — needs its own focused phase with explicit device-testing verification, separate from splash/list work which can proceed in parallel.
**Delivers:** `PdfViewerScreen` with page-by-page swipe navigation and pinch-to-zoom, gesture-conflict handling (lock swipe physics while zoomed), fed by `Burdah.pdfAssetPath`.
**Addresses:** Page-by-page PDF viewer, pinch-to-zoom (table stakes).
**Avoids:** PDF memory leak/OOM pitfall, gesture conflict pitfall — both require explicit real-device UAT before considered done.

### Phase 4: Burdah List & Home Screen
**Rationale:** Depends on Phase 1's repository and Phase 2's theme; ties the catalog to navigation and completes the primary user flow (Home → List → Viewer).
**Delivers:** `HomeScreen` with prominent "Burdah" CTA, `BurdahListScreen` rendering the catalog (1 entry), `go_router` route table wiring Home → List → Viewer with the `Burdah` object passed via route `extra`.
**Uses:** `go_router`, `BurdahListProvider`.
**Implements:** Declarative routing pattern, repository-to-UI data flow.

### Phase 5: Splash Screen (Animation + Audio)
**Rationale:** Architecturally independent of the reader (can be built/polished in parallel with Phases 3-4), but sequenced last here because it's the most "looks-done-but-isn't" polish item — native splash handoff, animation-jank avoidance, and iOS silent-mode audio all need dedicated device verification best done once the rest of the app exists to fade into.
**Delivers:** Two-stage splash: static native splash matched to first Flutter frame, then animated Bismillah text (`flutter_animate`, Transform/Opacity-driven) + 6.1s audio clip (`audioplayers`, iOS `AVAudioSession` configured for silent-switch respect), fading into Home.
**Addresses:** Animated Bismillah splash + audio, fade transition (differentiator/polish).
**Avoids:** Native splash white-flash, animation jank (layout-based vs transform-based), audio ignoring iOS silent switch.

### Phase 6: Release Preparation
**Rationale:** Store submission has its own distinct pitfall class (permission bloat, privacy policy) unrelated to app functionality — must be a final, explicit checklist phase rather than assumed.
**Delivers:** App icons (`flutter_launcher_icons`), manifest/plist permission audit, minimal accurate privacy policy, final RTL/typography/gesture regression pass across all screens.
**Avoids:** Store rejection from permission bloat pitfall.

### Phase Ordering Rationale

- Data architecture (Phase 1) and typography (Phase 2) come first because both are foundational decisions that are expensive to change once other phases build on top of them (per ARCHITECTURE.md's repository-first guidance and PITFALLS.md's font-lock-in warning).
- The PDF viewer (Phase 3) is sequenced before full screen wiring (Phase 4) because it is the highest-technical-risk component and benefits from isolated, focused device-testing rather than being tangled with navigation work.
- Splash (Phase 5) is architecturally independent per ARCHITECTURE.md ("sequential, not dependent") and is deliberately placed after the core reading flow so its polish-heavy verification (native splash matching, silent-mode audio) happens against a substantially complete app.
- Release prep (Phase 6) is last by definition — it's a submission gate, not a feature phase.

### Research Flags

Phases likely needing deeper research during planning:
- **Phase 2 (Typography):** Arabic font shaping bugs are Flutter-version and rendering-engine (Skia vs Impeller) dependent per multiple open `flutter/flutter` issues — needs current-version-specific verification at planning/execution time.
- **Phase 3 (PDF Viewer):** `pdfrx` version-specific API and any rendering regressions on the actual production PDF should be re-verified against pub.dev at implementation time; this research is WebSearch-sourced (MEDIUM confidence), not documentation-verified.
- **Phase 5 (Splash Audio):** iOS `AVAudioSession` configuration for silent-mode respect is plugin/iOS-version dependent per open GitHub issues — needs current-state verification for whatever `audioplayers` version is pinned at execution time.

Phases with standard patterns (skip research-phase):
- **Phase 1 (Foundation/Data Architecture):** Repository pattern over a JSON manifest is a well-established Flutter community pattern, cross-corroborated.
- **Phase 4 (List/Home/Routing):** `go_router` declarative routing is the current Flutter-team-recommended default with well-documented patterns.
- **Phase 6 (Release Prep):** Store permission-audit process is a standard, well-documented checklist item, not novel research territory.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | MEDIUM | WebSearch/WebFetch only, no premium docs provider configured this run; package versions should be re-verified with `flutter pub add`/pub.dev at implementation time |
| Features | MEDIUM | LOW-tier individual sources (app-store listings, review aggregators) but cross-corroborated across 3+ independent sources per major claim |
| Architecture | MEDIUM | Patterns cross-corroborated across multiple current community sources; package-specific API details are LOW-tier and unverified — re-check at build time |
| Pitfalls | MEDIUM-HIGH | Individual sources are LOW-tier web digests, but underlying pitfalls are corroborated across multiple independent official `flutter/flutter` and package-repo GitHub issues |

**Overall confidence:** MEDIUM

### Gaps to Address

- Exact pinned versions for `pdfrx`, `go_router`, `provider`/`riverpod`, `audioplayers`, `google_fonts` should be re-verified against pub.dev at project scaffold time (Phase 1).
- No premium documentation provider (e.g., Context7) was available for this research run — all findings are WebSearch/WebFetch-sourced.
- Which specific calligraphic font (Scheherazade New vs. Amiri vs. Reem Kufi) will actually render correctly on the target Flutter version/engine is unresolved until the Phase 2 throwaway test screen is built.
- State-management choice (`provider` vs. `riverpod`) is deliberately deferred to an "if extensibility grows" trigger rather than decided now.

## Sources

### Primary (HIGH confidence)
- None — no Context7 or premium documentation MCP provider was configured for this research session.

### Secondary (MEDIUM confidence)
- pub.dev package pages (`pdfrx`, `pdfx`, `audioplayers`, `flutter_native_splash`, `flutter_animate`, `google_fonts`, `provider`, `go_router`, `flutter_launcher_icons`)
- Multiple independent official `flutter/flutter` and package-repo GitHub issues (#34610, #117902, #138788, #143941, #119805, #50216; syncfusion/flutter-widgets #2192/#2032/#632; espresso3389/pdfrx #319; jonbhanson/flutter_native_splash #739; florent37/Flutter-AssetsAudioPlayer #349)

### Tertiary (LOW confidence)
- App-store listings and review aggregators for competitor analysis (Qasida Burda Sharif, Burda Baith, Muslim Pro, Quran.com, Rekhta)
- Community blog posts on Flutter state-management and project structure conventions
- Comparitech study on religious-app permission bloat

---
*Research completed: 2026-07-24*
*Ready for roadmap: yes*
