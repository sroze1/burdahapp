---
phase: 04-splash-experience-release-readiness
plan: 02
subsystem: infra
tags: [flutter, native-splash, launcher-icons, android-signing, store-listing]

requires:
  - phase: 04-splash-experience-release-readiness
    provides: SplashScreen with Colors.black background, app_icon_source.png (1024x1024)
provides:
  - Native pre-engine splash (color-matched black, no white flash)
  - App launcher icons for all Android/iOS densities
  - Android release signing configuration
  - Store listing metadata for Play Store and App Store
affects: []

tech-stack:
  added: [flutter_native_splash (dev), flutter_launcher_icons (dev)]
  patterns: [color-only native splash matching Flutter splash background, guarded signing config loading]

key-files:
  created:
    - flutter_native_splash.yaml
    - store_listing/play_store_description.txt
    - store_listing/app_store_description.txt
    - store_listing/privacy_policy.md
  modified:
    - pubspec.yaml
    - android/app/build.gradle.kts
    - .gitignore

key-decisions:
  - "Color-only native splash (#000000) — no image in native layer, Madinah photo stays in Flutter widget"
  - "Signing secrets excluded from git before keystore generation (security-first)"
  - "build.gradle.kts loads key.properties with exists() guard so debug builds work without it"
  - "App icon uses Rawdah interior image from logo.jpeg — user noted it looks suboptimal, deferred to future redesign"

patterns-established:
  - "Native splash color matches Flutter SplashScreen background for seamless handoff"
  - "Android signing config with file-existence guard for dev/release parity"

requirements-completed: [SPLSH-04]

coverage:
  - id: D1
    description: "Native pre-engine splash with color-matched black background, no white flash on cold start"
    requirement: SPLSH-04
    verification:
      - kind: e2e
        ref: "emulator cold-launch — first frame is solid black, no white flash"
        status: pass
    human_judgment: true
    rationale: "Cold-start visual behavior requires real device observation"
  - id: D2
    description: "App launcher icons generated for all Android/iOS densities from Rawdah interior image"
    requirement: SPLSH-04
    verification:
      - kind: automated_ui
        ref: "mipmap-hdpi/ic_launcher.png exists and is not stretched/cropped"
        status: pass
    human_judgment: true
    rationale: "User reviewed icon — approved but noted it looks suboptimal; deferred to future redesign"
  - id: D3
    description: "Android release signing configured with keystore and key.properties"
    requirement: SPLSH-04
    verification:
      - kind: automated_ui
        ref: "git check-ignore confirms key.properties is untracked; flutter build apk --debug succeeds"
        status: pass
    human_judgment: false
  - id: D4
    description: "Store listing metadata for Play Store and App Store with privacy policy"
    verification:
      - kind: manual_procedural
        ref: "user reviewed store_listing/ files"
        status: pass
    human_judgment: true
    rationale: "Store copy appropriateness requires human judgment"
---

## Accomplishments

1. **Native splash** — Color-only `#000000` native splash with Android 12 config section, matching SplashScreen's Colors.black for seamless handoff
2. **App icons** — Generated all Android mipmap densities and iOS AppIcon.appiconset sizes from the 1024x1024 Rawdah interior source
3. **Android signing** — Keystore generated, key.properties written locally (gitignored), build.gradle.kts loads signing config with exists() guard
4. **Store metadata** — Play Store and App Store descriptions plus privacy policy (no data collection)
5. **Security** — Signing secrets (.jks, .p12, key.properties) excluded from git before any secrets were generated

## Self-Check: PASSED

- flutter analyze: zero issues
- flutter build apk --debug: succeeds
- Cold-launch on emulator: no white flash, seamless native-to-Flutter splash transition
- key.properties confirmed untracked by git
- Full navigation flow intact (splash → home → reveal → reader)

## Deviations

None.

## Issues

- **App icon appearance** — User noted the launcher icon "looks dumb" using the current Rawdah interior source image. Approved for now; icon redesign deferred to a future iteration with a purpose-designed icon asset.
- **iOS verification gap** — No Xcode/simulator/device available. iOS native splash, icons, silent-switch audio, and flutter build ipa all require separate testing.
