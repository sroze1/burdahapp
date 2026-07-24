# Phase 1: Foundation, Data Architecture & Design System - Context

**Gathered:** 2026-07-24
**Status:** Ready for planning

<domain>
## Phase Boundary

Establish the extensible Flutter foundation — project scaffold, burdah catalog data model, and a verified Islamic geometric/calligraphic design system — that every later screen builds on. This phase delivers the toolbox (theme, widgets, data layer), not the screens that use it.

</domain>

<decisions>
## Implementation Decisions

### Color Palette & Theming
- **D-01:** Cream-white base with deep Islamic green (#0A642B) accents — green appears on headers, navigation bars, buttons, and borders. The white should be slightly warm/tinted (not sterile #FFFFFF) so the green feels natural. — **Reversibility:** reversible — palette values live in ThemeData, changeable without structural rework.
- **D-02:** Gold accents throughout — dividers, icon highlights, border trim, and buttons. Illuminated-manuscript aesthetic. Gold as a secondary accent color alongside the primary green.
- **D-03:** Both light AND dark themes for v1 — dark mode uses deep green (#0A642B) as the dark background with lighter text and adjusted gold/accent tones. — **Reversibility:** costly — building both themes from the start is easier than retrofitting dark mode later, but it doubles the theme surface to test.
- **D-04:** The color palette shifts from the original Turkish/Ghazali brief (turquoise, deep blue, burgundy) to an Islamic green + gold + white palette. This is the user's deliberate choice.

### Geometric Pattern Style
- **D-05:** Border frames only — geometric patterns frame screens and cards, content area stays clean. Patterns should not compete with the sacred text.
- **D-06:** Interlocking star tessellations — classic 8-point or 12-point Islamic geometric stars. The most recognizable Islamic geometric tradition.
- **D-07:** SVG assets for pattern implementation — crisp at any resolution, recolorable via theme for dark mode support. Use flutter_svg to render. — **Reversibility:** reversible — SVGs can be replaced with CustomPainter later if animation is desired.
- **D-08:** Two border widget variants needed: full-screen frame (wraps entire screen) AND card-sized frame (wraps individual content cards like burdah list items).

### Claude's Discretion
- **Exact hex values:** User specified green (#0A642B) and "gold" conceptually. Claude should select specific gold hex values, the warm-white background tone, text colors, and all dark-mode variants that harmonize with the chosen green.
- **Calligraphic font selection:** User did not discuss this area. Claude should select fonts based on best practices (Scheherazade New, Amiri, Reem Kufi options per CLAUDE.md research). The test screen will verify shaping before locking.
- **Catalog data model shape:** User did not discuss this. Claude should design the JSON manifest schema based on the extensibility requirement (ARCH-03) — at minimum: title, PDF asset path, metadata fields sufficient for a list screen.
- **Design references:** User explicitly noted they have limited exposure to Islamic design traditions and no specific visual references. Downstream agents should make confident design choices grounded in established Islamic geometric/calligraphic design principles rather than asking for more user input on visual direction.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Project Context
- `.planning/PROJECT.md` — Core value statement, constraints, key decisions
- `.planning/REQUIREMENTS.md` — Full v1 requirements with traceability (DSGN-01, DSGN-02, DSGN-03, ARCH-02, ARCH-03 map to this phase)
- `.planning/ROADMAP.md` — Phase 1 success criteria and phase dependencies

### Technology Stack
- `.claude/CLAUDE.md` §Recommended Stack — Validated Flutter/pdfrx/go_router/provider stack with version ranges, supporting libraries, and "What NOT to Use" warnings

### Raw Assets (already in repo)
- `بردة أم المؤمنين سيدتنا خديجة المسماة المكنز المكنون والدر المصون في سيرة صاحبة المعلاة وساكنة الحجون.pdf` — The Burdah PDF to catalog
- `Surah Al-Fatiha By Qari Abdul Basit 'Abd us-Samad.mp3` — Splash audio (Phase 4 asset, but present for reference)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- None — greenfield project, no Flutter scaffold exists yet

### Established Patterns
- None yet — stack recommended (Flutter 3.44.x, pdfrx, go_router, provider) but not scaffolded

### Integration Points
- Raw PDF and MP3 files exist at project root — need to be moved into Flutter `assets/` directory structure during scaffold
- CLAUDE.md documents full recommended stack with version pins and "What NOT to Use" guardrails

</code_context>

<specifics>
## Specific Ideas

- User wants the app to feel "mostly green" — generous green presence without overwhelming. The balance is cream-white background with green dominating structural elements (headers, nav, buttons, borders).
- Gold + green pairing should evoke illuminated-manuscript aesthetic — think gilded accents on a green-framed page.
- Pattern borders should use classic 8/12-point interlocking star tessellations — the most recognizable Islamic geometric motif.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 1-Foundation, Data Architecture & Design System*
*Context gathered: 2026-07-24*
