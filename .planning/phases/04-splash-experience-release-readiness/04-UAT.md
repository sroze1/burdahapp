---
status: partial
phase: 04-splash-experience-release-readiness
source: [04-01-SUMMARY.md, 04-02-SUMMARY.md]
started: 2026-07-26T12:00:00Z
updated: 2026-07-26T12:00:00Z
---

## Current Test

[testing complete]

## Tests

### 1. Animated Madinah Splash Image
expected: On cold launch, the splash screen shows the Madinah sunset image with a smooth animation chain: fade in, saturation build-up, golden glow hold, then fade out. The pacing feels reverent and unhurried (~7.1s total).
result: pass

### 2. Bismillah Text with Golden Glow
expected: Three-line Bismillah text appears below the image with a golden breathing glow animation. Arabic calligraphy renders correctly with proper diacritics.
result: pass

### 3. Recitation Audio During Splash
expected: Qari Abdul Basit's 6.1s Bismillah recitation plays during the splash screen. Audio quality is clear and syncs naturally with the visual animation.
result: pass

### 4. iOS Silent Switch Respect
expected: When the iPhone silent switch is on, the recitation audio does not play. When silent switch is off, audio plays normally.
result: blocked
blocked_by: physical-device
reason: "Needs Xcode + iOS simulator or physical iPhone to verify"

### 5. No White Flash on Cold Start
expected: On cold launch, the very first frame is solid black — no white flash before the splash animation begins.
result: pass

### 6. App Launcher Icon
expected: The app icon on the home screen/app drawer shows the Rawdah interior image, properly sized without stretching or cropping.
result: pass

### 7. Store Listing Metadata
expected: Store listing files exist with appropriate Play Store description, App Store description, and privacy policy. Content is accurate and suitable for submission.
result: pass

### 8. Splash Crossfade to Home
expected: Splash crossfades into Home screen via pushReplacement('/home')
result: pass
source: automated
coverage_id: D4

### 9. Android Release Signing
expected: Android release signing configured with keystore and key.properties
result: pass
source: automated
coverage_id: D3

## Summary

total: 9
passed: 7
issues: 0
pending: 0
blocked: 1
skipped: 0
blocked: 0

## Gaps

[none yet]
