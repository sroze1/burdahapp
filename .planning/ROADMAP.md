# Roadmap: BurdahApp

## Overview

BurdahApp starts from an extensible Flutter foundation (data model + verified Islamic geometric/calligraphic design system), then delivers its core value — a faithful, book-like PDF reading experience for the Burdah of Sayyida Khadija RA — before wiring the primary Home → List → Reader navigation flow, and finally closing with the reverent animated Bismillah splash and store-release readiness. Each phase produces a coherent, independently verifiable capability; later phases build on the data/design foundation rather than retrofitting it.

## Phases

**Phase Numbering:**

- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [x] **Phase 1: Foundation, Data Architecture & Design System** - Extensible Flutter project scaffold, burdah catalog data model, and verified Islamic geometric/calligraphic design system
- [x] **Phase 2: Reading Experience (PDF Viewer)** - Faithful, offline, page-by-page PDF reading with swipe navigation and pinch-to-zoom (completed 2026-07-26)
- [ ] **Phase 3: Navigation & Primary User Flow** - Home → Burdah List → Reader navigation wired end-to-end
- [ ] **Phase 4: Splash Experience & Release Readiness** - Animated Bismillah splash with audio, fading into Home, and store-submission-ready packaging

## Phase Details

### Phase 1: Foundation, Data Architecture & Design System

**Goal**: Establish the extensible Flutter foundation — project scaffold, burdah catalog data model, and a verified Islamic geometric/calligraphic design system — that every later screen builds on.
**Mode:** mvp
**Depends on**: Nothing (first phase)
**Requirements**: ARCH-02, ARCH-03, DSGN-01, DSGN-02, DSGN-03
**Success Criteria** (what must be TRUE):

  1. Flutter project builds and runs on both an Android and an iOS target with zero errors
  2. Burdah catalog data (title, PDF asset path, metadata) loads through a repository layer from a bundled JSON manifest, verified against the Khadija RA entry
  3. A test screen shows the chosen calligraphic Arabic font rendering correctly (letters joined, weights intact) alongside the turquoise/deep-blue/gold/burgundy color palette
  4. Reusable themed widgets (geometric border, gold CTA button) render correctly and are ready to reuse across screens

**Plans:** 2/2 plans executed
Plans:
**Wave 1**

- [x] 01-01-PLAN.md — Walking skeleton: Flutter scaffold, data layer (JSON catalog + repository), theme system (light + dark with green/gold/cream tokens), bundled Arabic fonts, and verification test screen

**Wave 2** *(blocked on Wave 1 completion)*

- [x] 01-02-PLAN.md — Design system widgets: SVG star tessellation geometric border frames (full-screen + card-sized) and gold CTA button

**UI hint**: yes

### Phase 2: Reading Experience (PDF Viewer)

**Goal**: Users can faithfully read the Burdah of Sayyida Khadija RA as a page-by-page PDF with swipe and pinch-to-zoom, fully offline, inside Islamic-themed reader chrome.
**Mode:** mvp
**Depends on**: Phase 1
**Requirements**: READ-01, READ-02, READ-03, READ-04, DSGN-04, ARCH-01
**Success Criteria** (what must be TRUE):

  1. User can open the Burdah PDF and swipe left/right to turn pages, book-like
  2. User can double-tap-to-zoom on any page without triggering an accidental page turn (swipe locked while zoomed, released on reset; pinch available for fine-adjustment once zoomed)
  3. PDF renders the original document exactly as authored (Arabic calligraphy and layout intact), with page-turn direction matching RTL expectations
  4. Reader screen displays with Islamic geometric border/chrome styling from the Phase 1 design system
  5. PDF opens and pages navigate correctly with the device in airplane mode (no network dependency)

**Plans:** 2/2 plans complete
Plans:
**Wave 1**

- [x] 02-01-PLAN.md — End-to-end PDF reading experience: pdfrx integration, page-by-page swipe with RTL order, double-tap-to-zoom with swipe-lock, Islamic-themed reader chrome, human verification checkpoint
- [x] 02-02-PLAN.md — Gap closure: fix deprecated Matrix4.translate() call, formalize double-tap-to-zoom deviation in requirements/roadmap/verification

**UI hint**: yes

### Phase 3: Navigation & Primary User Flow

**Goal**: Users can move through the complete Home → Burdah List → Reader flow and back, tying the Phase 1 catalog and design system together with the Phase 2 reader.
**Mode:** mvp
**Depends on**: Phase 2
**Requirements**: NAV-01, NAV-02, NAV-03
**Success Criteria** (what must be TRUE):

  1. User sees a home screen with a prominent, Islamic-geometric-styled "Burdah" button
  2. Tapping "Burdah" opens a list of available burdah poems (Khadija RA burdah as first entry), sourced from the catalog repository
  3. User can tap a list entry to open the PDF reader for that specific burdah
  4. User can navigate back from the reader to the list, and from the list to home, using standard back navigation on any screen

**Plans:** 1/1 plans executed
Plans:
**Wave 1**

- [x] 03-01-PLAN.md — End-to-end navigation flow: go_router with fade transitions, Provider DI, Home/List/Reveal/Reader screens, transitional reveal image

**UI hint**: yes

### Phase 4: Splash Experience & Release Readiness

**Goal**: Users are greeted by a reverent animated Bismillah splash with recitation audio that fades into Home, and the app is packaged and ready for Play Store / App Store submission.
**Mode:** mvp
**Depends on**: Phase 3
**Requirements**: SPLSH-01, SPLSH-02, SPLSH-03, SPLSH-04
**Success Criteria** (what must be TRUE):

  1. App launch shows a native, color-matched splash immediately on cold start, with no white flash before the Flutter engine takes over
  2. Animated "Bismillahirrahmaanirraheem" calligraphic text plays on launch, synced with the 6.1s Qari Abdul Basit recitation clip
  3. Splash fades smoothly into the Home screen once the animation/audio completes
  4. Audio behaves correctly on iOS with the silent switch engaged (respects device muting, never crashes or hangs) and app icons/permissions are ready for store submission

**Plans**: TBD
**UI hint**: yes

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Foundation, Data Architecture & Design System | 2/2 | Complete | 2026-07-25 |
| 2. Reading Experience (PDF Viewer) | 2/2 | Complete    | 2026-07-26 |
| 3. Navigation & Primary User Flow | 1/1 | In Progress|  |
| 4. Splash Experience & Release Readiness | 0/TBD | Not started | - |
