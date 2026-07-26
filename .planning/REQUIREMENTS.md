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

- [x] **READ-01**: User can view the Burdah of Sayyida Khadija RA as a page-by-page PDF with swipe navigation
- [x] **READ-02**: User can double-tap-to-zoom on any PDF page for detail (with pinch for fine-adjustment once zoomed)
- [x] **READ-03**: PDF displays the original document faithfully (not extracted text)
- [x] **READ-04**: Arabic content renders correctly with proper RTL layout

### Design

- [ ] **DSGN-01**: App uses Islamic geometric patterns inspired by Turkish/Ghazali style throughout
- [ ] **DSGN-02**: App uses calligraphic Arabic fonts for text elements
- [ ] **DSGN-03**: App uses a Turkish/Ghazali color palette (turquoise, deep blue, gold, burgundy)
- [x] **DSGN-04**: Reading experience has Islamic-themed UI chrome (geometric borders, styled navigation)

### Architecture

- [x] **ARCH-01**: App works fully offline with bundled PDF and audio assets
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
| SPLSH-01 | Phase 4 | Pending |
| SPLSH-02 | Phase 4 | Pending |
| SPLSH-03 | Phase 4 | Pending |
| SPLSH-04 | Phase 4 | Pending |
| NAV-01 | Phase 3 | Pending |
| NAV-02 | Phase 3 | Pending |
| NAV-03 | Phase 3 | Pending |
| READ-01 | Phase 2 | Complete |
| READ-02 | Phase 2 | Complete |
| READ-03 | Phase 2 | Complete |
| READ-04 | Phase 2 | Complete |
| DSGN-01 | Phase 1 | Pending |
| DSGN-02 | Phase 1 | Pending |
| DSGN-03 | Phase 1 | Pending |
| DSGN-04 | Phase 2 | Complete |
| ARCH-01 | Phase 2 | Complete |
| ARCH-02 | Phase 1 | Pending |
| ARCH-03 | Phase 1 | Pending |

**Coverage:**

- v1 requirements: 18 total
- Mapped to phases: 18
- Unmapped: 0 ✓

---
*Requirements defined: 2026-07-24*
*Last updated: 2026-07-24 after roadmap creation*
