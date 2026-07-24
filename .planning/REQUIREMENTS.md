# Requirements: BurdahApp

**Defined:** 2026-07-24
**Core Value:** Users can read Burdah poems in a beautiful, distraction-free experience that honors the sacred nature of the texts.

## v1 Requirements

Requirements for initial release. Each maps to roadmap phases.

### Splash

- [ ] **SPLSH-01**: App displays animated "Bismillahirrahmaanirraheem" calligraphic text on launch
- [ ] **SPLSH-02**: App plays Qari Abdul Basit recitation audio (6.1s clip) during splash animation
- [ ] **SPLSH-03**: Splash fades smoothly into the main home screen after animation completes
- [ ] **SPLSH-04**: Native splash screen prevents white flash during engine boot (color-matched to app theme)

### Navigation

- [ ] **NAV-01**: User sees a home screen with a prominent "Burdah" button styled with Islamic geometric design
- [ ] **NAV-02**: User can tap "Burdah" to open a list of available burdah poems
- [ ] **NAV-03**: User can navigate back from any screen to the previous screen

### Reading

- [ ] **READ-01**: User can view the Burdah of Sayyida Khadija RA as a page-by-page PDF with swipe navigation
- [ ] **READ-02**: User can pinch-to-zoom on any PDF page for detail
- [ ] **READ-03**: PDF displays the original document faithfully (not extracted text)
- [ ] **READ-04**: Arabic content renders correctly with proper RTL layout

### Design

- [ ] **DSGN-01**: App uses Islamic geometric patterns inspired by Turkish/Ghazali style throughout
- [ ] **DSGN-02**: App uses calligraphic Arabic fonts for text elements
- [ ] **DSGN-03**: App uses a Turkish/Ghazali color palette (turquoise, deep blue, gold, burgundy)
- [ ] **DSGN-04**: Reading experience has Islamic-themed UI chrome (geometric borders, styled navigation)

### Architecture

- [ ] **ARCH-01**: App works fully offline with bundled PDF and audio assets
- [ ] **ARCH-02**: App runs on both Android and iOS from a single Flutter codebase
- [ ] **ARCH-03**: Burdah catalog is data-driven (JSON manifest) so new burdahs can be added without code changes

## v2 Requirements

Deferred to future release. Tracked but not in current roadmap.

### Reading Enhancements

- **READ-05**: User can bookmark their reading position
- **READ-06**: App remembers last-read page across sessions
- **DSGN-05**: Night/dark reading mode for comfortable reading in low light

### Content

- **CONT-01**: User can search within burdah text (requires verified transcription)
- **CONT-02**: Scrollable extracted text view alongside PDF (once accuracy verified)
- **CONT-03**: Per-burdah recitation audio playback

## Out of Scope

| Feature | Reason |
|---------|--------|
| Text extraction from PDF | Accuracy uncertain for Arabic calligraphic text; user cannot verify |
| User accounts/login | Not needed for a reading app |
| Ads or monetization | Anti-feature — top complaint in competing Islamic apps |
| In-app purchases | Not applicable |
| Social sharing of verses | Out of scope for v1 |
| Cloud sync | No accounts, no sync needed |
| Search within text | Requires verified transcription; defer to v2 |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| SPLSH-01 | — | Pending |
| SPLSH-02 | — | Pending |
| SPLSH-03 | — | Pending |
| SPLSH-04 | — | Pending |
| NAV-01 | — | Pending |
| NAV-02 | — | Pending |
| NAV-03 | — | Pending |
| READ-01 | — | Pending |
| READ-02 | — | Pending |
| READ-03 | — | Pending |
| READ-04 | — | Pending |
| DSGN-01 | — | Pending |
| DSGN-02 | — | Pending |
| DSGN-03 | — | Pending |
| DSGN-04 | — | Pending |
| ARCH-01 | — | Pending |
| ARCH-02 | — | Pending |
| ARCH-03 | — | Pending |

**Coverage:**
- v1 requirements: 18 total
- Mapped to phases: 0
- Unmapped: 18 ⚠️

---
*Requirements defined: 2026-07-24*
*Last updated: 2026-07-24 after initial definition*
