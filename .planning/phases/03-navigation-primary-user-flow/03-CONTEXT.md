# Phase 3: Navigation & Primary User Flow - Context

**Gathered:** 2026-07-26
**Status:** Ready for planning

<domain>
## Phase Boundary

Wire the complete Home → Burdah List → Reader navigation flow end-to-end. This phase connects the Phase 1 catalog/design system with the Phase 2 reader through go_router, adding a Home screen, a Burdah list screen, and a transitional image reveal before the reader opens.

</domain>

<decisions>
## Implementation Decisions

### Design Simplification
- **D-01:** Drop geometric border frames from all screens going forward — the app should be simple and clean, not ornate. The existing `GeometricBorderFrame` and `GeometricCardFrame` widgets are no longer used. — **Reversibility:** reversible — widgets still exist in codebase if needed later.
- **D-02:** No app title, header text, or decorative elements on the home screen — just a single prominent "Burdah" button on a plain themed background (green/cream palette from Phase 1 still applies).

### Home Screen
- **D-03:** Home screen is minimal: plain themed background with one centered "Burdah" button (use `GoldCtaButton` or equivalent). No app name, no Arabic calligraphy header, no geometric framing. Just the button.

### Burdah List Screen
- **D-04:** Simple list rows for burdah entries, not cards. Each row shows the burdah's Arabic title, tappable. Minimal styling — no card frames, no geometric decoration.

### Transitional Image (Burdah Entry → Reader)
- **D-05:** When user taps a burdah entry (Sayyida Khadija RA), a transitional image of her resting place fades in, glows stronger to peak brightness, then fades out — 2 seconds total. After fade-out, the PDF reader opens. — **Reversibility:** costly — the image transition is burdah-specific (each future burdah could have its own transitional image), so the pattern needs to be extensible.
- **D-06:** Image asset is `IMG_1131.jpeg` (already in project root, needs to be moved to assets/).
- **D-07:** The resting place image is an entry-only experience — navigating back from the reader to the list does NOT replay the image, just a simple fade.

### Screen Transitions
- **D-08:** All screen-to-screen transitions (Home ↔ List, List ↔ Reader, back navigation) use gentle fade transitions — not the default Material slide-from-right.
- **D-09:** The transitional image fade (D-05) is visually distinct from the regular screen fade — it has the glow/intensity build-up effect, not just a simple opacity change.

### Claude's Discretion
- **Burdah list presentation details:** Claude decides the specific list row styling, text sizing, and spacing that looks clean and natural with the existing theme.
- **go_router route structure:** Claude decides the route definitions, path naming, and how burdah ID is passed to the reader screen.
- **Fade transition timing:** Claude decides the duration and easing curves for the gentle screen-to-screen fades (Home ↔ List, back navigation). The transitional image is locked at 2 seconds.
- **Back navigation chrome:** Claude decides whether to use AppBar back arrows, system back gesture, or both — standard Flutter/platform conventions apply.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Project Context
- `.planning/PROJECT.md` — Core value, constraints, key decisions (color palette shift to green+gold+white)
- `.planning/REQUIREMENTS.md` — NAV-01, NAV-02, NAV-03 map to this phase
- `.planning/ROADMAP.md` — Phase 3 success criteria and dependencies

### Technology Stack
- `.claude/CLAUDE.md` §Recommended Stack — go_router ^17.x for navigation, provider ^6.1.x for state

### Prior Phase Context
- `.planning/phases/01-foundation-data-architecture-design-system/01-CONTEXT.md` — Design system decisions (D-01 through D-08), color palette, theme choices

### Raw Assets
- `IMG_1131.jpeg` — Transitional image of Sayyida Khadija RA's resting place (to be moved to assets/)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `lib/widgets/gold_cta_button.dart` — Gold CTA button widget, candidate for the home screen "Burdah" button
- `lib/data/models/burdah.dart` — Burdah model with `id`, `title`, `titleArabic`, `pdfAsset`, `sortOrder`
- `lib/data/repositories/burdah_repository.dart` — Abstract repository with `getAll()` and `getById()`
- `lib/data/repositories/asset_burdah_repository.dart` — Concrete implementation loading from bundled JSON
- `lib/screens/burdah_reader_screen.dart` — Fully functional PDF reader from Phase 2
- `lib/theme/app_theme.dart` — Light/dark theme with green+gold+cream palette

### Established Patterns
- MaterialApp with `home:` property (no router yet) — must be converted to `MaterialApp.router` with go_router
- Provider-based state management (recommended but not yet wired for repository access from screens)
- `DesignSystemTestScreen` is current home — should be removed or kept as dev-only

### Integration Points
- `lib/app.dart` — Must convert from `MaterialApp(home:)` to `MaterialApp.router(routerConfig:)` for go_router
- `BurdahRepository.getAll()` — Feeds the burdah list screen
- `BurdahRepository.getById()` — Used to resolve burdah when navigating from list to reader
- `BurdahReaderScreen` — Already accepts a burdah's PDF asset path; needs to be wired as a go_router destination

</code_context>

<specifics>
## Specific Ideas

- The resting place image transition should feel reverent — fade in, glow/build to peak intensity, then fade out. Not a simple crossfade. 2 seconds total.
- Each future burdah could potentially have its own transitional image — the pattern should be extensible (e.g., image path in the burdah catalog JSON).
- "Simple" is the recurring theme — the user explicitly said "nothing extravagant" and "forget the geometry stuff."

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 3-Navigation & Primary User Flow*
*Context gathered: 2026-07-26*
