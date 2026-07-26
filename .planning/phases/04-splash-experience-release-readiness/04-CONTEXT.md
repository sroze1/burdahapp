# Phase 4: Splash Experience & Release Readiness - Context

**Gathered:** 2026-07-26
**Status:** Ready for planning

<domain>
## Phase Boundary

Deliver the app's first impression — an animated Bismillah splash screen with Qari Abdul Basit's recitation audio over a Madinah image — that fades smoothly into the Home screen. Then package the app for Play Store and App Store submission with icons, metadata, signing, and native splash configuration.

</domain>

<decisions>
## Implementation Decisions

### Splash Screen Composition
- **D-01:** Splash layout follows the established reveal screen pattern — Madinah image in the top section, Bismillah text below. Image asset is `images.jpeg` (Masjid an-Nabawi at sunset with the green dome). — **Reversibility:** reversible — layout and image are local changes.
- **D-02:** Text section below the image shows three lines: Arabic Bismillah ("بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ"), romanised transliteration ("Bismillahirrahmaanirraheem"), and English translation ("In the name of God, the Most Gracious, the Most Merciful"). White text on dark background, matching the reveal screen's three-line pattern.

### Splash Animation Style
- **D-03:** Madinah image animates like the reveal screen — fades in with saturation build-up and glow effect, not static. Same `flutter_animate` chain pattern established in `burdah_reveal_screen.dart`.
- **D-04:** Bismillah text fades in as a whole (not word-by-word or character-by-character), then does the same glow-and-breathe illumination effect from the reveal screen — warm golden shadow that pulses.
- **D-05:** Audio (6.1s Qari Abdul Basit Bismillah clip) plays alongside the animation, starting when the splash screen loads.

### Splash-to-Home Transition
- **D-06:** Crossfade overlap — splash fades out while Home screen simultaneously fades in. No gap or black frame between them.

### Release Readiness
- **D-07:** Full store submission scope — includes native splash config (`flutter_native_splash`), app icons (`flutter_launcher_icons`), bundle ID setup, signing config, AND store metadata (descriptions, screenshots, privacy policy placeholder). — **Reversibility:** one-way — bundle ID and signing identity, once submitted, cannot be easily changed.
- **D-08:** App icon uses `logo.jpeg` (Rawdah interior image — green, gold, and blue Islamic architecture). — **Reversibility:** reversible — icon can be regenerated from any source image.
- **D-09:** Store listing name is "BurdahApp".

### Claude's Discretion
- **Background colour:** Claude decides whether splash uses black or the app's themed green, based on what works best visually with the Madinah sunset image tones and the white text.
- **Animation timing:** Claude decides how to distribute the animation choreography across the 6.1s audio duration — fade-in timing, saturation build, glow-breathe duration, and fade-out overlap.
- **Native splash colour:** Claude matches the `flutter_native_splash` pre-engine background to the chosen splash background colour so there's no visible flash.
- **Store metadata content:** Claude writes the store descriptions, selects appropriate categories, and generates the privacy policy placeholder.
- **Audio trimming tool/approach:** The MP3 needs to be trimmed to 6.1 seconds — Claude decides the tooling (ffmpeg, Dart script, etc.) for the pre-build trim.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Project Context
- `.planning/PROJECT.md` — Core value, constraints, key decisions (colour palette shift to green+gold+white)
- `.planning/REQUIREMENTS.md` — SPLSH-01, SPLSH-02, SPLSH-03, SPLSH-04 map to this phase
- `.planning/ROADMAP.md` — Phase 4 success criteria, dependencies on Phase 3

### Technology Stack
- `.claude/CLAUDE.md` §Recommended Stack — `flutter_native_splash` for pre-engine gap, `flutter_animate` for text animation, `audioplayers` for audio clip, `flutter_launcher_icons` for app icons
- `.claude/CLAUDE.md` §What NOT to Use — Do NOT use third-party animated splash wrappers; do NOT rely on `flutter_native_splash` alone for the animated splash

### Prior Phase Context
- `.planning/phases/01-foundation-data-architecture-design-system/01-CONTEXT.md` — Design system decisions (D-01 through D-08), colour palette, theme choices
- `.planning/phases/03-navigation-primary-user-flow/03-CONTEXT.md` — Simplification direction (D-01: drop geometric borders), reveal screen pattern (D-05 through D-09)

### Known Concerns
- `.planning/STATE.md` §Blockers/Concerns — iOS silent-mode audio behaviour for the splash clip requires manual AVAudioSession configuration and physical-device testing

### Raw Assets
- `images.jpeg` — Madinah/Masjid an-Nabawi sunset image for splash background (to be moved to assets/)
- `logo.jpeg` — Rawdah interior image for app icon (to be moved to assets/)
- `Surah Al-Fatiha By Qari Abdul Basit 'Abd us-Samad.mp3` — Source audio, needs trimming to first 6.1 seconds and moving to assets/

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `lib/screens/burdah_reveal_screen.dart` — Established animation pattern: `flutter_animate` chain with fadeIn → saturation build → glow-breathe → fadeOut. The splash screen should mirror this exact pattern with the Madinah image and Bismillah text.
- `lib/widgets/transitional_reveal_image.dart` — May contain reusable image animation logic
- `lib/theme/app_theme.dart` — Light/dark theme with green+gold+cream palette; native splash colour should match
- `lib/theme/app_colors.dart` — Colour tokens for theme consistency

### Established Patterns
- `flutter_animate` chains with `.animate()`, `.then()`, `.custom()` for complex multi-stage effects
- `GoogleFonts.scheherazadeNew()` for Arabic calligraphic text (used in reveal screen)
- `go_router` with `MaterialApp.router` for navigation — splash needs to integrate as the initial route
- Fade transitions between all screens (D-08 from Phase 3)

### Integration Points
- `lib/router/app_router.dart` — `initialLocation: '/'` currently points to HomeScreen; splash must become the initial route, navigating to Home on completion
- `lib/app.dart` — `MaterialApp.router` setup; splash timing must complete before router hands off to Home
- `pubspec.yaml` — `audioplayers` and `flutter_native_splash` need to be added as dependencies; MP3 asset needs to be registered
- `android/` and `ios/` — Native splash config, signing, bundle ID, app icon generation targets

</code_context>

<specifics>
## Specific Ideas

- The splash should feel like the reveal screen's "elder sibling" — same reverent glow-and-breathe animation language, but as the app's first impression rather than a burdah-specific transition.
- Image + text split layout mirrors the reveal screen: image fills the top portion, text section below with Arabic, transliteration, and English — consistent visual language across the app.
- The crossfade overlap from splash to Home should feel seamless — the user shouldn't perceive a "loading" moment or jarring cut.
- The Instagram page (`Instagram.html` + `Instagram_files/`) in the project root is reference material from "Pilgrim | Umrah & Hajj" — not app assets. Can be cleaned up or left in place.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 4-Splash Experience & Release Readiness*
*Context gathered: 2026-07-26*
