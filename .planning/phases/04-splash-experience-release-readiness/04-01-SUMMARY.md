---
phase: 04-splash-experience-release-readiness
plan: 01
subsystem: ui
tags: [flutter, flutter_animate, audioplayers, splash, animation]

requires:
  - phase: 03-navigation-primary-user-flow
    provides: go_router routing structure, HomeScreen at '/', _fadePage transition
provides:
  - Animated Bismillah splash screen with Madinah sunset image and three-line text
  - Audio playback of 6.1s Qari Abdul Basit recitation clip
  - Route restructure (splash at '/', home at '/home')
  - Prepared source assets for Plan 02 (app icon, native splash)
affects: [04-02-release-packaging]

tech-stack:
  added: [audioplayers]
  patterns: [animation chain mirroring reveal screen pattern, saturation matrix filter, breathing glow effect]

key-files:
  created:
    - lib/screens/splash_screen.dart
    - assets/images/madinah_sunset.png
    - assets/audio/bismillah_trimmed.mp3
    - assets/icon/app_icon_source.png
  modified:
    - lib/router/app_router.dart
    - pubspec.yaml
    - test/widget_test.dart

key-decisions:
  - "Extended peak hold duration from 2800ms to 3800ms (~7.1s total) based on user feedback for more reverent pacing"
  - "Colors.black background for splash (matches reveal screen convention, provides contrast)"
  - "respectSilence: true for iOS silent-switch audio behaviour"
  - "Audio wrapped in try-catch so playback failure never crashes the app"

patterns-established:
  - "Splash animation chain: fadeIn → saturation ramp → hold → fadeOut, timed to audio clip"
  - "Audio context configured with respectSilence before playback"

requirements-completed: [SPLSH-01, SPLSH-02, SPLSH-03]

coverage:
  - id: D1
    description: "SplashScreen widget with animated Madinah image (fadeIn, saturation build, glow hold, fadeOut)"
    requirement: SPLSH-01
    verification:
      - kind: automated_ui
        ref: "flutter analyze --no-fatal-infos"
        status: pass
      - kind: e2e
        ref: "emulator cold-launch screen recording — image animation confirmed"
        status: pass
    human_judgment: true
    rationale: "Animation pacing and visual feel require subjective judgment — approved by user after timing adjustment"
  - id: D2
    description: "Three-line Bismillah text with golden breathing glow animation"
    requirement: SPLSH-01
    verification:
      - kind: e2e
        ref: "emulator cold-launch — text rendering and glow confirmed via screenshots"
        status: pass
    human_judgment: true
    rationale: "Arabic calligraphy rendering and glow aesthetics need human eye"
  - id: D3
    description: "Qari Abdul Basit 6.1s recitation audio plays during splash"
    requirement: SPLSH-02
    verification:
      - kind: e2e
        ref: "logcat confirms audioplayers acquired and released audio focus"
        status: pass
    human_judgment: true
    rationale: "Audio quality and sync require human ear — approved by user"
  - id: D4
    description: "Splash crossfades into Home screen via pushReplacement('/home')"
    requirement: SPLSH-03
    verification:
      - kind: e2e
        ref: "emulator — Home screen visible after splash, back button goes to launcher not splash"
        status: pass
    human_judgment: false
  - id: D5
    description: "iOS silent-switch respect via AudioContextConfig(respectSilence: true)"
    requirement: SPLSH-04
    verification: []
    human_judgment: true
    rationale: "Requires physical iPhone testing — no Xcode/simulator available in this environment"
---

## Accomplishments

1. **Asset preparation** — Converted images.jpeg (WebP) to PNG, trimmed full recitation MP3 to 6.1s clip, square-padded logo.jpeg to 1024x1024 icon source
2. **SplashScreen widget** — StatefulWidget with flutter_animate chains mirroring the reveal screen pattern: Madinah image with saturation/glow build-up (top 3/5), three-line Bismillah text with golden breathing glow (bottom 2/5)
3. **Audio integration** — audioplayers with iOS silent-switch respect (respectSilence: true), wrapped in try-catch for resilience
4. **Route restructure** — Splash at '/', HomeScreen moved to '/home', existing navigation flow preserved
5. **Timing refinement** — Extended peak hold from 2800ms to 3800ms based on user feedback for a more reverent, unhurried pacing

## Self-Check: PASSED

- flutter analyze: zero issues
- flutter build apk --debug: succeeded
- flutter test: passes
- Emulator cold-launch verified: animation, audio, transition, back-stack all correct
- User approved visual and audio quality after timing adjustment

## Deviations

- **Animation total duration extended to ~7.1s** (from planned ~6.1s) — user requested the peak hold phase stay longer for a more reverent feel. Audio clip is still 6.1s, so the last ~1s of visual animation plays silently before the crossfade.

## Issues

None.
