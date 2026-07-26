# Phase 4: Splash Experience & Release Readiness - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-07-26
**Phase:** 04-splash-experience-release-readiness
**Areas discussed:** Splash animation style & composition, Release readiness scope

---

## Splash Screen Composition & Animation (combined — user described full vision upfront)

User provided a comprehensive freeform answer describing the splash screen:

**User's vision:** "background of madinah, I just added a new image, underneath Bismillah, same font glow and breathe illuminating the text and Bismillah full, nice arabic font in white. Same thing underneath the image have that text, fade in whole etc"

**Interpretation:** Madinah image (images.jpeg) in the top section, Bismillah in Arabic calligraphy below in white, same glow-and-breathe animation from the reveal screen, text fades in as a whole.

---

## Image Animation

| Option | Description | Selected |
|--------|-------------|----------|
| Animate like reveal | Image fades in and builds saturation/glow, matching the reveal screen's established pattern | ✓ |
| Static background | Image is visible immediately as the backdrop, all animation focus goes to the Bismillah text | |
| You decide | Claude picks whichever approach feels more cohesive | |

**User's choice:** Animate like reveal
**Notes:** None

---

## Background Colour

| Option | Description | Selected |
|--------|-------------|----------|
| Black | Dark, cinematic backdrop — matches the reveal screen's feel | |
| Themed green | Uses the app's deep Islamic green as the background | |
| You decide | Claude picks based on what works best with the Madinah sunset tones | ✓ |

**User's choice:** You decide
**Notes:** Claude has discretion on background colour

---

## Sub-text Below Arabic

| Option | Description | Selected |
|--------|-------------|----------|
| Arabic only | Just the Bismillah in Arabic calligraphy | |
| Add transliteration | Arabic + romanised text below | |
| Full trio | Arabic + transliteration + English translation — mirrors the reveal screen's three-line pattern | ✓ |

**User's choice:** Full trio
**Notes:** Matches the reveal screen's established three-line text pattern

---

## Splash-to-Home Transition

| Option | Description | Selected |
|--------|-------------|----------|
| Fade out then fade in | Everything fades to background, then Home fades in — clean break | |
| Crossfade overlap | Splash fades out while Home simultaneously fades in — seamless | ✓ |
| You decide | Claude picks whichever feels smoothest | |

**User's choice:** Crossfade overlap
**Notes:** None

---

## Release Readiness Scope

| Option | Description | Selected |
|--------|-------------|----------|
| Technical only | Native splash, app icons, bundle ID, signing — app is buildable for release | |
| Full store submission | All of above PLUS store metadata, descriptions, screenshots, privacy policy | ✓ |
| Skip release prep | Focus entirely on splash — handle release packaging separately | |

**User's choice:** Full store submission
**Notes:** None

---

## App Icon

User responded with freeform: "in the directory as instagram", then clarified: "i added logo in directory"

**Found:** `logo.jpeg` — interior image of the Rawdah in Masjid an-Nabawi with green, gold, and blue Islamic architecture.

---

## Store Listing Name

| Option | Description | Selected |
|--------|-------------|----------|
| BurdahApp | Simple, direct — matches the project name | ✓ |
| Burdah | Clean, single-word name | |
| Burdah — Islamic Poetry | Descriptive subtitle for store search discoverability | |

**User's choice:** BurdahApp
**Notes:** None

---

## Claude's Discretion

- Background colour for the splash screen (black vs themed green)
- Animation timing distribution across the 6.1s audio duration
- Native splash pre-engine colour matching
- Store metadata content (descriptions, categories, privacy policy)
- Audio trimming tooling approach

## Deferred Ideas

None — discussion stayed within phase scope
