# Phase 3: Navigation & Primary User Flow - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-07-26
**Phase:** 03-navigation-primary-user-flow
**Areas discussed:** Home screen composition, Screen transitions

---

## Home Screen Composition

### Q1: What should the home screen feel like?

| Option | Description | Selected |
|--------|-------------|----------|
| Centered showcase | Full-screen geometric border frame, app title in Arabic calligraphy at top, single prominent GoldCtaButton centered — minimal, reverent, feels like a book cover | |
| Welcome greeting | Geometric frame with an Islamic greeting/Bismillah header, brief Arabic subtitle, then the Burdah button below — warmer, more inviting | |
| You decide | Let Claude design the layout based on the Islamic aesthetic established in Phase 1 | |

**User's choice:** Free-text response — "simple just splash screen, burdah button, click it, all burdahs show (as of now only one) sayiida khadija's burdah is there to be clicked, once clicked fades in showing a pic of her resting place and fades out to the pdf, nothing extravagant other than this. Simple app, forget the geometry stuff from now just this."
**Notes:** Major design simplification — user explicitly dropped geometric border frames and wants a minimal, clean app. Introduced the transitional resting place image concept.

### Q2: Do you already have the image of Sayyida Khadija RA's resting place?

| Option | Description | Selected |
|--------|-------------|----------|
| Yes, I have it | I'll provide the image file to bundle in assets | ✓ |
| Not yet | I need to find/source it first | |

**User's choice:** Yes, I have it
**Notes:** Image is `IMG_1131.jpeg` in the project root directory.

### Q3: How long should the resting place image show before fading to the PDF?

| Option | Description | Selected |
|--------|-------------|----------|
| Brief (2-3 seconds) | Quick reverent moment, then into the reading | |
| Medium (4-5 seconds) | Enough time to contemplate the image | |
| You decide | Claude picks an appropriate duration | |

**User's choice:** Free-text — "2 seconds fade in and start to glow stronger till peak max fade in, then fade out, 2 seconds altogether"
**Notes:** Specific animation choreography: fade in → glow/intensity build to peak → fade out, 2 seconds total.

### Q4: Home screen — button only or with app name?

| Option | Description | Selected |
|--------|-------------|----------|
| Just the button | Clean background, one prominent button, nothing else | ✓ |
| App name + button | Small 'BurdahApp' title or Arabic calligraphic header above the button | |
| You decide | Claude picks what looks natural | |

**User's choice:** Just the button

### Q5: Burdah list style?

| Option | Description | Selected |
|--------|-------------|----------|
| Simple list row | Plain styled row with the burdah's Arabic title, tappable — minimal | ✓ |
| Card entry | A styled card with the title and Arabic title, centered on screen | |
| You decide | Claude picks based on the simple aesthetic | |

**User's choice:** Simple list row

---

## Screen Transitions

### Q1: Transitions for Home to List and back?

| Option | Description | Selected |
|--------|-------------|----------|
| Default Material | Standard slide-from-right transitions | |
| Fade everywhere | Gentle fade transitions between all screens | |
| You decide | Claude picks transitions that feel cohesive | |

**User's choice:** Free-text — "very gentle fade in and out transitions, different to sayyida khadija's though"
**Notes:** Two distinct fade styles: gentle fade for screen-to-screen navigation, and the special glow transition for the burdah entry → reader flow.

### Q2: Back navigation from reader — replay image?

| Option | Description | Selected |
|--------|-------------|----------|
| Simple fade back | Just fade from reader back to the list — image is entry-only | ✓ |
| Reverse the image | Show the resting place image again briefly when leaving | |
| You decide | Claude picks what feels natural | |

**User's choice:** Simple fade back

---

## Claude's Discretion

- Burdah list row styling, text sizing, and spacing
- go_router route structure and path naming
- Fade transition durations and easing curves (except the 2-second image transition)
- Back navigation chrome (AppBar arrows, system back gesture)

## Deferred Ideas

None — discussion stayed within phase scope
