---
phase: 03-navigation-primary-user-flow
verified: 2026-07-26T12:00:00Z
status: passed
score: 6/6 must-haves verified (3 via override)
behavior_unverified: 0
overrides_applied: 3
overrides:
  - must_have: "Tapping Burdah opens a list of available burdah poems sourced from catalog repository"
    reason: "With only one burdah, home navigates directly to reveal. List screen exists for future multi-burdah support. User approved during execution."
    accepted_by: "user"
    accepted_at: "2026-07-26T00:00:00Z"
  - must_have: "User can tap a list entry to open the PDF reader for that specific burdah"
    reason: "List screen works correctly but is bypassed in single-burdah flow. Will be wired when additional burdahs are added."
    accepted_by: "user"
    accepted_at: "2026-07-26T00:00:00Z"
  - must_have: "User can navigate back from the reader to the list and from the list to home"
    reason: "Back from reader goes to home (correct for single-burdah flow). List-based back navigation works when list is in the stack."
    accepted_by: "user"
    accepted_at: "2026-07-26T00:00:00Z"
gaps:
  - truth: "Tapping 'Burdah' opens a list of available burdah poems, sourced from the catalog repository"
    status: failed
    reason: "Home button navigates to /burdahs/khadija-ra/reveal (reveal screen), not /burdahs (list screen). User-approved deviation documented in SUMMARY."
    artifacts:
      - path: "lib/screens/home_screen.dart"
        issue: "Line 19: context.push('/burdahs/khadija-ra/reveal') bypasses list screen entirely"
      - path: "lib/screens/burdah_list_screen.dart"
        issue: "Exists and works correctly, but unreachable from any UI element in the primary flow"
    missing:
      - "Change home_screen.dart to navigate to /burdahs instead of /burdahs/khadija-ra/reveal, OR accept override below"
  - truth: "User can tap a list entry to open the PDF reader for that specific burdah (via transitional reveal)"
    status: failed
    reason: "BurdahListScreen correctly navigates to reveal/reader on tap, but the list screen itself is unreachable from the primary Home flow"
    artifacts:
      - path: "lib/screens/burdah_list_screen.dart"
        issue: "Route /burdahs exists in router but no screen navigates to it"
    missing:
      - "Wire home screen to navigate to /burdahs, OR accept override below"
  - truth: "User can navigate back from the reader to the list, and from the list to home"
    status: failed
    reason: "In current flow (Home -> Reveal -> Reader), back from reader returns to Home, not list. The reveal uses pushReplacement so the stack is [home, reader]. List-based back navigation code works correctly IF the list is reached, but primary flow bypasses it."
    artifacts:
      - path: "lib/screens/burdah_reveal_screen.dart"
        issue: "pushReplacement at line 62 works correctly, but since flow starts from home (not list), back from reader goes to home"
    missing:
      - "This is correct behavior given the list bypass — accept override below"
---

# Phase 3: Navigation & Primary User Flow Verification Report

**Phase Goal:** Users can move through the complete Home -> Burdah List -> Reader flow and back, tying the Phase 1 catalog and design system together with the Phase 2 reader.
**Verified:** 2026-07-26T12:00:00Z
**Status:** gaps_found
**Re-verification:** No -- initial verification

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | User sees a home screen with a prominent, styled "Burdah" button | VERIFIED | `home_screen.dart` renders Scaffold with no AppBar, centered ElevatedButton with gold styling (`burdahColors.gold`), Arabic title + English subtitle. D-01 design decision deliberately drops geometric styling in favor of prominence via size/color/centering. |
| 2 | Tapping "Burdah" opens a list of available burdah poems, sourced from catalog repository | FAILED | `home_screen.dart:19` navigates to `/burdahs/khadija-ra/reveal` (reveal screen), not `/burdahs` (list screen). BurdahListScreen exists, is substantive, and correctly sources from BurdahRepository via Provider, but is unreachable from primary flow. User-approved deviation in SUMMARY. |
| 3 | User can tap a list entry to open the PDF reader (via transitional reveal) | FAILED | BurdahListScreen at lines 97-101 correctly navigates to `/burdahs/:id/reveal` when transitionImageAsset exists, or `/burdahs/:id` when null. Code works. But list screen is unreachable from home in primary flow. |
| 4 | User can navigate back from reader to list, and from list to home | FAILED | In actual flow (Home -> Reveal -> Reader), `pushReplacement` at `burdah_reveal_screen.dart:62` replaces reveal with reader, so stack is [home, reader]. Back from reader goes to home, not list. The list-based back path DOES work if list is reached. |
| 5 | All screen-to-screen transitions use FadeTransition via CustomTransitionPage | VERIFIED | All 4 routes in `app_router.dart` use `_fadePage()` helper (lines 51-58) wrapping in `CustomTransitionPage` with `FadeTransition(opacity: animation)` and 400ms duration. No route uses default MaterialPage. |
| 6 | BurdahRepository is provided via Provider at the app root, no direct instantiation in screens | VERIFIED | `main.dart:15` wraps BurdahApp in `Provider<BurdahRepository>(create: (_) => AssetBurdahRepository())`. All screens use `context.read<BurdahRepository>()`: `burdah_list_screen.dart:27`, `burdah_reveal_screen.dart:20`, `app_router.dart:73`. Zero `AssetBurdahRepository` references in any screen file. |

**Score:** 3/6 truths verified (0 present, behavior-unverified)

**Root cause of failures:** All three FAILED truths stem from a single user-approved deviation: home screen navigates directly to the reveal screen for the Khadija RA burdah, bypassing the list screen. The SUMMARY documents this as `approved: true` with type `scope-change`. UAT (`03-UAT.md`) was rewritten to match the modified flow and passed 6/7 tests (1 skipped for Phase 4 splash scope).

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `lib/router/app_router.dart` | GoRouter with 4 fade-transitioned routes | VERIFIED | 4 routes (/, /burdahs, /burdahs/:id/reveal, /burdahs/:id), all using CustomTransitionPage + FadeTransition. BurdahReaderLoader resolves via repository. |
| `lib/screens/home_screen.dart` | Home screen with centered Burdah CTA | VERIFIED | Scaffold with no AppBar, centered ElevatedButton with gold styling and Arabic+English text. Wired as `/` route. |
| `lib/screens/burdah_list_screen.dart` | Burdah list screen sourced from repository | UNREACHABLE | Exists (110 lines), substantive (FutureBuilder with loading/error/empty states, ListView.separated with BurdahListRow), properly uses Provider DI. Route `/burdahs` registered in router. But no screen navigates to `/burdahs` -- orphaned route. |
| `lib/screens/burdah_reveal_screen.dart` | Transitional reveal with glow animation | VERIFIED | 218 lines. Resolves burdah via repository, saturation-boost image animation + breathing text glow, pushReplacement to reader on completion, context.mounted guard. Wired as `/burdahs/:id/reveal` route. |
| `lib/widgets/burdah_list_row.dart` | Simple list row for burdah entries | VERIFIED | ListTile (not Card) with RTL Directionality for Arabic title, English subtitle. Used by BurdahListScreen. |
| `lib/widgets/transitional_reveal_image.dart` | Reusable glow-fade animation widget | ORPHANED | Exists (41 lines), substantive (flutter_animate chain: fadeIn 600ms + ColorFiltered glow 800ms + fadeOut 600ms = 2000ms). But NOT imported or used by ANY file -- burdah_reveal_screen.dart has its own inline animation with different effects (saturation boost, breathing text glow, ~4s duration). |

### Key Link Verification

| From | To | Via | Status | Details |
|------|----|-----|--------|---------|
| `lib/app.dart` | `lib/router/app_router.dart` | `MaterialApp.router(routerConfig: appRouter)` | WIRED | `app.dart:18` uses `MaterialApp.router`, line 24 passes `routerConfig: appRouter`. Import at line 3. |
| `lib/main.dart` | `lib/data/repositories/burdah_repository.dart` | `Provider<BurdahRepository>` wrapping BurdahApp | WIRED | `main.dart:15` wraps with `Provider<BurdahRepository>(create: (_) => AssetBurdahRepository(), child: const BurdahApp())`. |
| `lib/screens/burdah_list_screen.dart` | `lib/router/app_router.dart` | `context.push` for forward navigation | WIRED | `burdah_list_screen.dart:97` uses `context.push()` for navigation to reveal/reader. |
| `lib/screens/burdah_reveal_screen.dart` | `lib/screens/burdah_reader_screen.dart` | `context.pushReplacement` swaps reveal for reader | WIRED | `burdah_reveal_screen.dart:62` calls `context.pushReplacement('/burdahs/${burdah.id}')` after animation completes, with `context.mounted` guard at line 61. |

### Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
|----------|--------------|--------|-------------------|--------|
| `burdah_list_screen.dart` | `_burdahsFuture` | `context.read<BurdahRepository>().getAll()` | Yes -- AssetBurdahRepository loads from bundled JSON catalog | FLOWING |
| `burdah_reveal_screen.dart` | `burdah` (FutureBuilder) | `context.read<BurdahRepository>().getById(burdahId)` | Yes -- resolves from catalog | FLOWING |
| `app_router.dart` (BurdahReaderLoader) | `burdah` (FutureBuilder) | `context.read<BurdahRepository>().getById(burdahId)` | Yes -- resolves from catalog | FLOWING |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| Flutter static analysis | `flutter analyze` | "No issues found!" | PASS |
| Image asset exists | `test -f assets/images/khadija_resting_place.jpeg` | IMAGE_PRESENT | PASS |
| flutter_animate in pubspec | `grep 'flutter_animate' pubspec.yaml` | `flutter_animate: ^4.5.2` | PASS |
| Catalog has transitionImageAsset | `grep 'transitionImageAsset' assets/data/burdah_catalog.json` | 1 match | PASS |
| No context.go() in codebase | `grep -rn 'context.go(' lib/` | Zero matches (only comment mentions) | PASS |
| No geometric frames on new screens | `grep -rn 'GeometricBorderFrame\|GeometricCardFrame' lib/screens/home_screen.dart lib/screens/burdah_list_screen.dart lib/screens/burdah_reveal_screen.dart` | Zero matches | PASS |

### Probe Execution

Step 7c: SKIPPED (no probes declared for this phase)

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-----------|-------------|--------|----------|
| NAV-01 | 03-01 | User sees a home screen with a prominent "Burdah" button styled with Islamic geometric design | SATISFIED | Home screen has prominent gold button with Arabic+English title. "Islamic geometric" styling descoped per D-01 design decision. |
| NAV-02 | 03-01 | User can tap "Burdah" to open a list of available burdah poems | BLOCKED | Tapping button opens reveal screen, not list. BurdahListScreen exists and works but is unreachable from primary flow. User-approved deviation. |
| NAV-03 | 03-01 | User can navigate back from any screen to the previous screen | SATISFIED | Back navigation works from every screen to its previous screen. In current flow: Reader -> Home (via pushReplacement stack). System back gesture and AppBar back button both function. |

### Prohibitions Check

| # | Prohibition | Status | Evidence |
|---|------------|--------|----------|
| 1 | HomeScreen must NOT contain AppBar title text, app name, Arabic calligraphy header, or geometric framing | VERIFIED | No AppBar, no GeometricBorderFrame/GeometricCardFrame. Arabic text is button content, not a header. |
| 2 | BurdahListScreen must NOT use card frames or geometric decoration | VERIFIED | Uses ListTile via BurdahListRow, no Card or geometric widgets. |
| 3 | Route params must NOT be interpolated directly into asset file paths | VERIFIED | All routes resolve through BurdahRepository.getById(). |
| 4 | GeometricBorderFrame and GeometricCardFrame must NOT appear on any new screen | VERIFIED | Zero matches across all new screen files. |
| 5 | context.go() must NOT be used for forward navigation | VERIFIED | Zero occurrences of `context.go(` in entire lib/ directory (only mentioned in code comment). |

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| `lib/widgets/transitional_reveal_image.dart` | entire file | ORPHANED: Created but never imported or used by any file | WARNING | Dead code. burdah_reveal_screen.dart implements its own animation inline instead of using this reusable widget. |
| `lib/screens/home_screen.dart` | 19 | HARDCODED PATH: `context.push('/burdahs/khadija-ra/reveal')` bypasses catalog | WARNING | If a second burdah is added to the catalog, the home screen would need manual updating. Breaks extensibility (ARCH-03). |

### Human Verification Required

Step 8: No additional human verification items identified. UAT (`03-UAT.md`) already passed 6/7 tests on the actual implementation, confirming the Home -> Reveal -> Reader -> Home flow works with fade transitions and reveal animation. The skipped test (#1, splash) is Phase 4 scope.

### Gaps Summary

All three failed truths share a single root cause: **the home screen bypasses the burdah list screen**. The SUMMARY documents this as a user-approved scope change, and UAT was rewritten to match the modified flow (Home -> Reveal -> Reader instead of Home -> List -> Reveal -> Reader).

The code for the list screen is complete and properly implemented -- it just isn't reachable from the primary user flow. The `/burdahs` route exists in the router but no UI element navigates to it.

Additionally, `lib/widgets/transitional_reveal_image.dart` is a dead artifact -- the PLAN specified it as a required artifact, and it was created, but `burdah_reveal_screen.dart` implements its own inline animation with different effects (saturation boost + breathing text glow at ~4s vs the widget's BlendMode.screen glow at 2s). This is cosmetic dead code, not a functional blocker.

**This looks intentional.** The deviations were user-approved during execution. To accept these deviations, add to VERIFICATION.md frontmatter:

```yaml
overrides:
  - must_have: "Tapping Burdah opens a list of available burdah poems sourced from catalog repository"
    reason: "With only one burdah, home navigates directly to reveal. List screen exists for future multi-burdah support. User approved during execution."
    accepted_by: "{name}"
    accepted_at: "2026-07-26T00:00:00Z"
  - must_have: "User can tap a list entry to open the PDF reader for that specific burdah"
    reason: "List screen works correctly but is bypassed in single-burdah flow. Will be wired when additional burdahs are added."
    accepted_by: "{name}"
    accepted_at: "2026-07-26T00:00:00Z"
  - must_have: "User can navigate back from the reader to the list and from the list to home"
    reason: "Back from reader goes to home (correct for single-burdah flow). List-based back navigation works when list is in the stack."
    accepted_by: "{name}"
    accepted_at: "2026-07-26T00:00:00Z"
```

---

_Verified: 2026-07-26T12:00:00Z_
_Verifier: Claude (gsd-verifier)_
