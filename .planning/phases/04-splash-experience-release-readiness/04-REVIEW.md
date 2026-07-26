---
phase: 04-splash-experience-release-readiness
type: code-review
depth: standard
status: findings
files_reviewed: 6
files_reviewed_list:
  - lib/screens/splash_screen.dart
  - lib/router/app_router.dart
  - android/app/build.gradle.kts
  - test/widget_test.dart
  - flutter_native_splash.yaml
  - pubspec.yaml
findings_count: 8
critical: 0
warning: 4
info: 4
---

# Phase 04: Code Review Report — Splash Experience & Release Readiness

**Reviewed:** 2026-07-26
**Depth:** standard
**Files Reviewed:** 6
**Status:** issues_found

## Summary

Reviewed the animated splash screen (`SplashScreen`), the route restructure, Android release-signing wiring, the updated smoke test, and the native-splash/pubspec configuration produced across Plans 01–02. `flutter analyze` is clean and `flutter test` currently passes, but tracing the actual runtime/OS behavior surfaced four real functional gaps that the automated checks and the emulator-only verification did not catch:

1. **Confirmed against the `flutter_native_splash` package's own README**: because `android_12.image` is intentionally left unset, real Android 12+ devices (the majority of the install base in 2026) will show the app's launcher icon — the same icon the phase summary already calls out as looking "dumb" — clipped to a circle during the native pre-engine splash. This contradicts the phase's own success claim of a clean, seamless, color-only handoff and was not verifiable on an emulator running an older API level.
2. `respectSilence: true` has a side effect on Android that neither the plan nor RESEARCH.md analyzed: it forces the Android usage type to `notificationRingtone`, tying the recitation clip to the ringer/notification volume stream instead of media volume.
3. The updated smoke test's own explanatory comment doesn't match the numbers: the splash's total animation duration is 7100ms, but the test only advances the fake clock by 7000ms, so the `onComplete → pushReplacement('/home')` path — the thing Phase 4 most needed a regression guard for — never actually executes during the test run.
4. `build.gradle.kts`'s signing config does unchecked non-null casts on `Properties` lookups, so a `key.properties` file that exists but is missing/misspells one entry fails the build with an opaque Kotlin cast exception instead of a clear message.

No hardcoded secrets, injection vectors, or crash-on-launch bugs were found; `key.properties`/`*.jks` are correctly gitignored (and redundantly so — see IN-02).

## Warnings

### WR-01: Android 12+ native splash will show the (already-flagged-as-weak) launcher icon, not a clean black screen

**File:** `flutter_native_splash.yaml:14-18`
**Issue:** The `android_12` section only sets `color`/`color_dark`, with no `image`/`icon_background_color`. Per `flutter_native_splash`'s own README (`~/.pub-cache/hosted/pub.dev/flutter_native_splash-2.4.8/README.md:166-171`): *"If this parameter is not specified, the app's launcher icon will be used instead. Please note that the splash screen will be clipped to a circle on the center of the screen."* Confirmed further by the generated `android/app/src/main/res/values-v31/styles.xml`, which sets `windowSplashScreenBackground` but no `windowSplashScreenAnimatedIcon` override — meaning the OS falls back to `android:icon="@mipmap/ic_launcher"` from `AndroidManifest.xml`, i.e. the Rawdah-interior icon that 04-02-SUMMARY.md itself records the user found unappealing ("looks dumb"). So on real Android 12+ hardware, cold-launch will briefly show a black screen **with a circle-clipped copy of that icon centered on it**, not the pure solid-black "no visible seam" splash the checkpoint verification claims to have confirmed. The checkpoint's emulator test does not state which Android API level was used, so this discrepancy plausibly went unnoticed.
**Fix:** Either accept and document the circular-icon fallback as an explicit, intentional trade-off, or add a dedicated `android_12.image` (a small, centered, circle-safe asset per the README's sizing guidance — 1152×1152 without background, safe content within a 768px circle) plus `icon_background_color: "#000000"` so Android 12+ shows something deliberate instead of an unreviewed fallback:
```yaml
android_12:
  color: "#000000"
  color_dark: "#000000"
  image: assets/icon/android12_splash_icon.png
  icon_background_color: "#000000"
```

### WR-02: `respectSilence: true` silently reroutes Android playback to the ringer/notification stream

**File:** `lib/screens/splash_screen.dart:44-46`
**Issue:** `AudioContextConfig(respectSilence: true).build()` was chosen (per RESEARCH.md Pattern 2 / Pitfall 3) specifically to fix iOS silent-switch behavior. But `audioplayers_platform_interface`'s `AudioContextConfig.buildAndroid()` (`audio_context_config.dart:85-100`) shows `respectSilence: true` also forces `usageType: AndroidUsageType.notificationRingtone` on Android — unconditionally, with no platform branch to opt out. This means the recitation clip is now tied to the device's ringer/notification volume slider rather than the media volume slider on Android: a very common configuration (ringer silenced/vibrate, media volume up — the default on many phones) will silently mute the splash audio even though the user would expect a media-style splash sound to play, and conversely the volume rocker during the splash will adjust ringer volume, not media volume, which is a confusing side effect. This was not analyzed anywhere in the plan or RESEARCH.md (which only ever discusses the iOS side of `respectSilence`), and would not be noticed on most emulators, which typically have no meaningful ringer/media volume distinction configured.
**Fix:** Build the `AudioContext` explicitly per platform instead of relying on the generic Android mapping, e.g.:
```dart
await _player.setAudioContext(
  AudioContext(
    iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
    android: AudioContextAndroid(usageType: AndroidUsageType.media),
  ),
);
```
This keeps the iOS silent-switch behavior SPLSH-04 actually asked for while leaving Android on the normal media-volume stream (unaffected by ringer silence, matching a decorative splash sound's expected UX).

### WR-03: Smoke test's pump duration is shorter than the splash's real animation length — the navigation path it claims to protect never runs

**File:** `test/widget_test.dart:22-28`; durations from `lib/screens/splash_screen.dart:94-117`
**Issue:** The image animation chain is `fadeIn(900ms) → custom(1200ms) → custom(3800ms) → fadeOut(1200ms)` = **7100ms** total (matches the 04-01-SUMMARY.md deviation note: "extended peak hold duration... ~7.1s total"). The test comment claims it "advance[s] the fake clock past the full ~6.1s chain (through the pushReplacement navigation to Home)" and calls `await tester.pump(const Duration(seconds: 7))` — i.e. 7000ms, which is **100ms short** of the actual 7100ms total. Since `.animate(onComplete: ...)` only fires after the entire chain completes, `_onSplashComplete()`/`context.pushReplacement('/home')` never executes within this test run. The test still passes, but only because it merely asserts "no exception was thrown during the (incomplete) splash render" — it does not exercise, and therefore provides no regression protection for, the actual route-replacement behavior (D-06) that this phase introduced and that the comment claims to be safeguarding.
**Fix:** Pump past the real total (with margin), e.g. `await tester.pump(const Duration(seconds: 8));`, and add an assertion that navigation actually happened (e.g. `expect(find.byType(SplashScreen), findsNothing);`) so the test fails loudly if a future timing change breaks the onComplete → pushReplacement path.

### WR-04: Unchecked non-null casts in `build.gradle.kts` signing config produce opaque failures on malformed `key.properties`

**File:** `android/app/build.gradle.kts:40-44`
**Issue:**
```kotlin
signingConfigs {
    create("release") {
        if (keystorePropertiesFile.exists()) {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
}
```
`Properties["..."]` returns `Any?`; if `key.properties` exists but is missing (or has a typo'd) one of `keyAlias`/`keyPassword`/`storePassword`, the forced `as String` cast throws a raw `ClassCastException` (`null cannot be cast to non-null type kotlin.String`) deep in Gradle configuration, with no indication of which property is missing or that the root cause is `key.properties`. `storeFile` is handled more defensively (`?.let`) but the other three are not, which is an inconsistent standard within the same block.
**Fix:** Validate/require the keys explicitly with a clear error message, e.g.:
```kotlin
fun requireProp(name: String): String =
    keystoreProperties.getProperty(name)
        ?: error("key.properties is missing required property: $name")

keyAlias = requireProp("keyAlias")
keyPassword = requireProp("keyPassword")
storePassword = requireProp("storePassword")
storeFile = keystoreProperties.getProperty("storeFile")?.let { file(it) }
```

## Info

### IN-01: Unused 1024×1024 icon-source asset bundled into every release build

**File:** `pubspec.yaml:89`
**Issue:** `assets/icon/` is registered in `flutter.assets`, which ships `assets/icon/app_icon_source.png` (≈228KB) inside the compiled app bundle. `grep -rn "assets/icon" lib/` finds zero references — `flutter_launcher_icons` reads `image_path` directly off disk during its own `dart run` codegen step and does not need the file registered as a Flutter asset. This was explicitly directed by 04-01-PLAN.md, so it's a plan-level choice rather than an executor error, but it's still dead weight shipped in every build with no code depending on it.
**Fix:** Remove `assets/icon/` from `pubspec.yaml`'s `flutter.assets` list; keep the source PNG in the repo (for regenerating icons later) but outside the bundled-assets path.

### IN-02: Root `.gitignore` additions duplicate existing `android/.gitignore` entries

**File:** `.gitignore` (new entries); `android/.gitignore:12-14`
**Issue:** `android/key.properties`, `*.jks`, `*.p12`, `*.keystore` were added to the root `.gitignore`, but `android/.gitignore` already ignores `key.properties`, `**/*.keystore`, and `**/*.jks` (confirmed via `git check-ignore -v android/key.properties` resolving to `android/.gitignore:12`). Not a security gap — the file is correctly untracked either way — but it's redundant and makes it unclear which `.gitignore` is the "source of truth" for signing-secret exclusion going forward.
**Fix:** No functional change needed; optionally leave a one-line comment noting the pre-existing `android/.gitignore` coverage so future edits don't assume the root file is the only guard.

### IN-03: `_saturationMatrix` and `glowColor` duplicated verbatim between two screens

**File:** `lib/screens/splash_screen.dart:65-75,79`
**Issue:** The static `_saturationMatrix` helper and the `const glowColor = Color(0xFFF5E6C8)` constant are byte-for-byte copies of the same code in `lib/screens/burdah_reveal_screen.dart:77-87,91`. This was an explicit instruction in 04-01-PLAN.md ("copy the `_saturationMatrix` static method"), so it matches spec, but as the codebase grows it creates drift risk: a future tuning of the saturation curve or the glow tone in one screen is easy to forget in the other.
**Fix:** Extract both into a shared `lib/utils/glow_effects.dart` (or similar) used by both `SplashScreen` and `BurdahRevealScreen`.

### IN-04: Broad `catch (_)` swallows all exception types, including config/assertion errors

**File:** `lib/screens/splash_screen.dart:42-51`
**Issue:** The try/catch around `setAudioContext`/`play` is well-justified for expected playback failures (per T-04-02), but `catch (_)` also silently swallows programmer-error cases, e.g. `AudioContextConfig.validateIOS()`'s `assert()`s (audioplayers_platform_interface `audio_context_config.dart:126-143`) would fire if `respectSilence` is ever combined with an incompatible `route`/`focus` flag in a future edit — that misconfiguration would vanish silently in debug builds instead of surfacing as a visible assertion failure during development.
**Fix:** Narrow the catch or at least log in debug mode, e.g. `} catch (e) { assert(() { debugPrint('Splash audio failed: $e'); return true; }()); }`, so genuine misconfigurations remain discoverable without risking a release-mode crash.

---

_Reviewed: 2026-07-26_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
