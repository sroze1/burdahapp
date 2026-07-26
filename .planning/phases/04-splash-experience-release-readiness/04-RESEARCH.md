# Phase 4: Splash Experience & Release Readiness - Research

**Researched:** 2026-07-26
**Domain:** Flutter animated splash screen (native + in-app), audio playback with iOS silent-mode handling, app icon/native-splash asset pipelines, Android/iOS store signing and submission readiness
**Confidence:** MEDIUM — core Flutter/package mechanics are HIGH confidence (official docs, source code, pub.dev registry, direct machine probing); store-submission checklist content is MEDIUM (community sources, cross-checked against official Flutter deployment docs); exact iOS silent-mode behavior is un-testable in this dev environment (see Environment Availability) and therefore carries a LOW-confidence execution risk despite HIGH-confidence documentation on the correct API to use.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Splash Screen Composition**
- **D-01:** Splash layout follows the established reveal screen pattern — Madinah image in the top section, Bismillah text below. Image asset is `images.jpeg` (Masjid an-Nabawi at sunset with the green dome). — **Reversibility:** reversible — layout and image are local changes.
- **D-02:** Text section below the image shows three lines: Arabic Bismillah ("بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ"), romanised transliteration ("Bismillahirrahmaanirraheem"), and English translation ("In the name of God, the Most Gracious, the Most Merciful"). White text on dark background, matching the reveal screen's three-line pattern.

**Splash Animation Style**
- **D-03:** Madinah image animates like the reveal screen — fades in with saturation build-up and glow effect, not static. Same `flutter_animate` chain pattern established in `burdah_reveal_screen.dart`.
- **D-04:** Bismillah text fades in as a whole (not word-by-word or character-by-character), then does the same glow-and-breathe illumination effect from the reveal screen — warm golden shadow that pulses.
- **D-05:** Audio (6.1s Qari Abdul Basit Bismillah clip) plays alongside the animation, starting when the splash screen loads.

**Splash-to-Home Transition**
- **D-06:** Crossfade overlap — splash fades out while Home screen simultaneously fades in. No gap or black frame between them.

**Release Readiness**
- **D-07:** Full store submission scope — includes native splash config (`flutter_native_splash`), app icons (`flutter_launcher_icons`), bundle ID setup, signing config, AND store metadata (descriptions, screenshots, privacy policy placeholder). — **Reversibility:** one-way — bundle ID and signing identity, once submitted, cannot be easily changed.
- **D-08:** App icon uses `logo.jpeg` (Rawdah interior image — green, gold, and blue Islamic architecture). — **Reversibility:** reversible — icon can be regenerated from any source image.
- **D-09:** Store listing name is "BurdahApp".

### Claude's Discretion
- **Background colour:** Claude decides whether splash uses black or the app's themed green, based on what works best visually with the Madinah sunset image tones and the white text.
- **Animation timing:** Claude decides how to distribute the animation choreography across the 6.1s audio duration — fade-in timing, saturation build, glow-breathe duration, and fade-out overlap.
- **Native splash colour:** Claude matches the `flutter_native_splash` pre-engine background to the chosen splash background colour so there's no visible flash.
- **Store metadata content:** Claude writes the store descriptions, selects appropriate categories, and generates the privacy policy placeholder.
- **Audio trimming tool/approach:** The MP3 needs to be trimmed to 6.1 seconds — Claude decides the tooling (ffmpeg, Dart script, etc.) for the pre-build trim.

### Deferred Ideas (OUT OF SCOPE)
None — discussion stayed within phase scope.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-------------------|
| SPLSH-01 | App displays animated "Bismillahirrahmaanirraheem" calligraphic text on launch | Architecture Pattern 1 (reuse `_RevealContent`'s glow-chain for the text block, `GoogleFonts.scheherazadeNew()` already offline-bundled); Recommended Project Structure (`splash_screen.dart`). |
| SPLSH-02 | App plays Qari Abdul Basit recitation audio (6.1s clip) during splash animation | Standard Stack (`audioplayers` ^6.8.1, verified); Architecture Pattern 2 (silent-switch-aware playback config); Common Pitfall 5 (precise 6.1s trim via `ffmpeg`, already installed on this machine). |
| SPLSH-03 | Splash fades smoothly into the main home screen after animation completes | Architecture Pattern 3 (route restructure, reuse existing `_fadePage`/`pushReplacement` convention); Common Pitfall 4 (historical `pushReplacement` transition bug, confirmed closed upstream on this pinned toolchain — still verify manually). |
| SPLSH-04 | Native splash screen prevents white flash during engine boot (color-matched to app theme); audio respects iOS silent switch without crashing/hanging; icons/permissions ready for store submission | Standard Stack (`flutter_native_splash` ^2.4.8, `flutter_launcher_icons` ^0.14.4); Architecture Pattern 2 (`respectSilence: true`); Common Pitfalls 1–3 (asset format/squareness, Android 12 splash config, default iOS category); Environment Availability (Xcode/iOS device gap — flagged for `checkpoint:human-verify`); Security Domain (signing-secret handling). |
</phase_requirements>

## Summary

This phase has two distinct halves that should be planned as separate waves: (1) an animated splash **experience** built entirely from patterns already proven in this codebase (`burdah_reveal_screen.dart` / `TransitionalRevealImage`), and (2) **release packaging** (native splash, icons, signing, store metadata) which is almost entirely configuration and CLI-tool work, not new application logic.

For the splash experience: reuse the exact `flutter_animate` chain pattern from `burdah_reveal_screen.dart` (fadeIn → saturation-build → glow-breathe → fadeOut) for the Madinah image, and the glow/breathe `Shadow`-based text effect for the three-line Bismillah text block. Do not hand-roll new animation primitives — extend `TransitionalRevealImage` or copy its `_RevealContent` pattern into a new `SplashScreen`. Audio playback via `audioplayers` needs one non-default configuration: the package's default iOS category is `AVAudioSessionCategory.playback`, which **ignores** the hardware silent switch — the opposite of what SPLSH success criterion #4 requires. Setting `AudioContextConfig(respectSilence: true).build()` (or `AudioContextIOS(category: AVAudioSessionCategory.ambient)` directly) is the documented way to make playback silence-switch-aware.

For release packaging: `flutter_native_splash` and `flutter_launcher_icons` are both build-time codegen tools driven by `pubspec.yaml`/`flutter_native_splash.yaml` config and a `dart run` command — verified current on pub.dev (2.4.8 and 0.14.4 respectively, both published within the last 14 months, both with 8,000+ likes). The two raw source assets in the repo root have real problems that must be fixed before they can be used: `logo.jpeg` (locked by D-08 as the icon source) is 399×501 — **not square** — and both `flutter_native_splash` and `flutter_launcher_icons` require a square PNG; `images.jpeg` (locked by D-01 as the splash background) is **actually WebP-encoded data with a `.jpeg` extension**, verified by direct byte inspection on this machine. Both are fixable with `sips` (already on this Mac, no new install needed) before moving them into `assets/`.

The single biggest planning risk in this phase is environment, not code: this development machine has **no usable Xcode** (command-line-tools-only, confirmed via `flutter doctor`) and **no iOS simulator or physical iOS device attached** (confirmed via `flutter devices`). SPLSH success criterion #4 ("audio behaves correctly on iOS with the silent switch engaged") and all of D-07's iOS signing/`flutter build ipa` work are therefore **not verifiable in this session** — the plan must implement per documented best practice and gate the actual on-device/simulator verification behind a `checkpoint:human-verify` task, consistent with the existing STATE.md blocker note.

**Primary recommendation:** Build the splash as a new `SplashScreen` widget that copies the `_RevealContent` pattern (image `flutter_animate` chain + text glow chain) at ~6.1s total duration, start `audioplayers` with `respectSilence: true` alongside it, wire it as the new `/` route with the existing `_fadePage` transition helper (verify manually that the fade-out/fade-in overlap satisfies D-06 — a related go_router bug was closed upstream, so this should already work in the pinned 17.x version), then treat `flutter_native_splash`/`flutter_launcher_icons`/signing/store-metadata as a second, mostly-mechanical wave gated by fixed source assets.

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Pre-engine native splash (no white flash) | OS / Native (Android `styles.xml` + iOS `LaunchScreen.storyboard`) | — | `flutter_native_splash` generates native platform resources shown before the Flutter engine boots; this is outside Dart/Flutter's control by definition. |
| Animated Bismillah splash content | Flutter Client (widget tree) | — | Pure in-app `flutter_animate` + `Image.asset`/`Text` rendering, first Flutter frame the app draws. |
| Splash audio playback | Flutter Client (`audioplayers` plugin → platform audio session) | OS / Native (`AVAudioSession` on iOS, `AudioManager` on Android) | Dart-side `audioplayers` call configures the platform audio session; actual silent-switch behavior is enforced by the OS based on that configuration. |
| Splash → Home route transition | Flutter Client (`go_router` / Navigator 2.0) | — | Declarative route change + `CustomTransitionPage`, no server or OS involvement. |
| App icon | Build / Packaging (`flutter_launcher_icons` codegen → Android `mipmap`/iOS `Assets.xcassets`) | — | Generated once at build/config time, not runtime. |
| Signing / bundle ID / store metadata | Build / Packaging + External (Play Console / App Store Connect) | — | Local Gradle/Xcode signing config plus manual entry into each store's console — no app runtime code involved. |

## Standard Stack

### Core (new to this phase)
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| `audioplayers` | ^6.8.1 | Plays the bundled 6.1s Bismillah clip on splash | `.claude/CLAUDE.md`-mandated. [VERIFIED: pub.dev registry] — confirmed via `pub.dev/api/packages/audioplayers`: latest `6.8.1`, published 2026-06-27, 3,437 likes, 150/160 pub points. |
| `flutter_native_splash` | ^2.4.8 | Native pre-engine splash (solid color, no white flash) | `.claude/CLAUDE.md`-mandated. [VERIFIED: pub.dev registry] — latest `2.4.8`, published 2026-05-29, 9,750 likes, 150/160 pub points. |
| `flutter_launcher_icons` | ^0.14.4 | Generates Android + iOS launcher icons from `logo.jpeg` | `.claude/CLAUDE.md`-mandated. [VERIFIED: pub.dev registry] — latest `0.14.4`, published 2025-06-10, 8,005 likes, 150/160 pub points. |

### Already installed — reuse, do not re-add or substitute
| Library | Version (pinned in `pubspec.yaml`) | Reused For |
|---------|-------------------------------------|-----------|
| `flutter_animate` | ^4.5.2 | Splash image + text animation chains (exact `.animate().fadeIn().then().custom()...` pattern from `burdah_reveal_screen.dart`) |
| `google_fonts` | ^8.2.0 | `GoogleFonts.scheherazadeNew()` for the Arabic Bismillah line — already offline-bundled, `allowRuntimeFetching = false` already set in `main.dart` |
| `go_router` | ^17.3.0 | New `/` splash route + `pushReplacement()` to the existing Home route (needs a path rename — see Architecture Patterns) |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `audioplayers` | `just_audio` | Only if future phases add background/playlist audio; unnecessary for one 6.1s foreground clip — CLAUDE.md already made this call. |
| `flutter_native_splash` static image | Embedding the Madinah photo directly in the native splash's `image:` key | Rejected — native splash images must be square PNG (see Common Pitfalls); the Madinah photo is 16:9 and belongs in the animated Flutter content, not the pre-engine native layer. Native splash should be solid-color-only. |

**Installation:**
```bash
flutter pub add audioplayers
flutter pub add --dev flutter_native_splash flutter_launcher_icons
```
(`flutter_native_splash` and `flutter_launcher_icons` are build-time-only codegen tools — conventionally added as `dev_dependencies`, matching how `flutter_lints` is already scoped in this `pubspec.yaml`.)

**Version verification:** Confirmed directly against the pub.dev registry API (`https://pub.dev/api/packages/<name>`) on 2026-07-26 — see table above for exact publish dates and version numbers. `npm view`-equivalent for Dart/Flutter is the pub.dev API; there is no separate CLI verification step needed beyond `flutter pub add`, which will re-resolve against the same registry at plan-execution time.

## Package Legitimacy Audit

> Ecosystem note: the `gsd-tools package-legitimacy check` seam only supports `npm|pypi|crates` — pub.dev (Dart/Flutter) is not a supported ecosystem for that automated check. In its place, this audit was performed by querying the pub.dev registry API directly (`pub.dev/api/packages/<name>` and `.../score`), which **is** the ecosystem's own authoritative registry (equivalent evidentiary weight to `npm view` against the npm registry), plus cross-referencing each package's GitHub source repository.

| Package | Registry | Age (latest publish) | Likes / Pub Points | Source Repo | Verdict | Disposition |
|---------|----------|----------------------|---------------------|-------------|---------|-------------|
| `audioplayers` | pub.dev | 2026-06-27 (~1 mo old) | 3,437 likes / 150/160 | github.com/bluefireteam/audioplayers | OK | Approved |
| `flutter_native_splash` | pub.dev | 2026-05-29 (~2 mo old) | 9,750 likes / 150/160 | github.com/jonbhanson/flutter_native_splash | OK | Approved |
| `flutter_launcher_icons` | pub.dev | 2025-06-10 (~13 mo old) | 8,005 likes / 150/160 | github.com/fluttercommunity/flutter_launcher_icons | OK | Approved |

**Packages removed due to [SLOP] verdict:** none
**Packages flagged as suspicious [SUS]:** none

All three packages are already explicitly named and version-pinned in `.claude/CLAUDE.md`'s Recommended Stack (project-level decision, not this session's discovery) — this audit independently re-confirmed their registry existence, recency, and community adoption rather than taking the CLAUDE.md recommendation on faith. No `[ASSUMED]` package names in this phase.

## Architecture Patterns

### System Architecture Diagram

```
Cold app launch (Android/iOS)
        │
        ▼
┌───────────────────────────────┐
│ Native pre-engine splash       │  ← flutter_native_splash-generated
│ (solid color, matches theme)   │     Android styles.xml / iOS
│ NO IMAGE — flash-free handoff  │     LaunchScreen.storyboard
└───────────────┬────────────────┘
                │  Flutter engine boots, first frame ready
                ▼
┌────────────────────────────────────────────┐
│ SplashScreen widget (new, '/' route)        │
│  ┌────────────────────────────────────────┐│
│  │ Image.asset(madinah) .animate()         ││  flutter_animate chain,
│  │   fadeIn → saturation-build → glow      ││  mirrors _RevealContent
│  │   → fadeOut  (top ~60% of screen)       ││  pattern in
│  ├────────────────────────────────────────┤│  burdah_reveal_screen.dart
│  │ 3-line Bismillah text .animate()        ││
│  │   fadeIn (as whole) → glow-breathe      ││
│  │   → fadeOut  (bottom ~40% of screen)    ││
│  └────────────────────────────────────────┘│
│  AudioPlayer.play(AssetSource(bismillah))   │  audioplayers,
│    started ~concurrently with animation     │  respectSilence: true
│    (D-05 — not frame-synced to audio pos.)  │
└───────────────┬──────────────────────────────┘
                │  animation onComplete callback fires
                ▼
     context.pushReplacement('/home')      ← _fadePage transition
                │                             (crossfade overlap, D-06)
                ▼
┌────────────────────────────────┐
│ HomeScreen (existing, path      │
│ renamed from '/' → '/home')     │
└──────────────────────────────────┘
```

### Recommended Project Structure
```
lib/
├── screens/
│   └── splash_screen.dart        # new — mirrors burdah_reveal_screen.dart's
│                                  #   _RevealContent pattern for image+text,
│                                  #   adds audioplayers playback
├── widgets/
│   └── transitional_reveal_image.dart  # existing — consider extracting a
│                                        #   shared "glow chain" helper if
│                                        #   the text-glow logic would
│                                        #   otherwise be duplicated 3x
│                                        #   (reveal screen + splash)
assets/
├── audio/                        # new — bismillah_trimmed.mp3 (6.1s)
├── images/
│   └── madinah_sunset.png        # new — converted from root images.jpeg
│                                  #   (see Common Pitfalls — real format
│                                  #   is WebP, must re-encode)
└── icon/
    └── app_icon_source.png       # new — square-padded from root logo.jpeg
```

### Pattern 1: Reuse the reveal-screen animation chain verbatim
**What:** `burdah_reveal_screen.dart`'s `_RevealContent` already implements exactly the fade-in → saturation-build → glow-hold → fade-out sequence D-03/D-04 ask for, at 600ms/800ms/2000ms/600ms stage durations (2000ms text-glow, 800ms image-saturation).
**When to use:** For the splash screen's image and text blocks — scale stage durations up so total ≈ 6.1s (the audio length) instead of the reveal screen's shorter total.
**Example:**
```dart
// Source: lib/screens/burdah_reveal_screen.dart (existing, this codebase)
Image.asset(assetPath, fit: BoxFit.cover)
    .animate(onComplete: (_) => onComplete())
    .fadeIn(duration: 600.ms, curve: Curves.easeIn)
    .then()
    .custom(
      duration: 800.ms,
      builder: (context, value, child) => ColorFiltered(
        colorFilter: ColorFilter.matrix(_saturationMatrix(1.0 + 0.4 * value)),
        child: child,
      ),
    )
    .then()
    // ...hold + fadeOut stages, retimed to sum to ~6.1s
```

### Pattern 2: iOS silent-switch-respecting audio playback
**What:** `audioplayers`' default `AudioContext` builds iOS category `playback`, which **ignores** the ring/silent switch. SPLSH-04's success criterion #4 explicitly wants the opposite (respect device muting).
**When to use:** Set this once, before calling `.play()`, on the `AudioPlayer` instance used for the splash clip.
**Example:**
```dart
// Source: pub.dev/packages/audioplayers getting-started guide (github.com/bluefireteam/audioplayers/blob/main/getting_started.md)
// + audioplayers_platform_interface source (audio_context_config.dart)
final player = AudioPlayer();
await player.setAudioContext(
  AudioContextConfig(respectSilence: true).build(),
  // equivalent explicit form:
  // AudioContext(iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient)),
);
await player.play(AssetSource('audio/bismillah_trimmed.mp3'));
```
Wrap the `.play()` call in try/catch — SPLSH-04 also requires the app to "never crash or hang" if audio fails (e.g. simulator/emulator with no audio hardware, or an interrupted session); on catch, let the visual animation continue and complete normally without the clip.

### Pattern 3: Route restructure for splash-as-initial-route
**What:** `appRouter`'s `initialLocation: '/'` currently points to `HomeScreen`. The splash must take over `'/'`; `HomeScreen` needs a new path.
**When to use:** During router changes for this phase.
**Example:**
```dart
// Pattern extends lib/router/app_router.dart (existing)
GoRoute(
  path: '/',
  pageBuilder: (context, state) => _fadePage(state, const SplashScreen()),
),
GoRoute(
  path: '/home',
  pageBuilder: (context, state) => _fadePage(state, const HomeScreen()),
),
// ...splash's onComplete calls: context.pushReplacement('/home')
```
This preserves the existing "never `context.go()`, always `push`/`pushReplacement`" convention documented in `app_router.dart`'s file comment (Phase 3 RESEARCH.md Anti-Pattern) — `pushReplacement` also correctly drops splash from history so the back button from Home never returns to it.

### Anti-Patterns to Avoid
- **Embedding the Madinah photo in `flutter_native_splash`'s `image:` config:** the pre-engine native splash image must be a square PNG per the package's own requirements (see Pitfall 1) — a 16:9 photo will be awkwardly cropped/centered by the native Android/iOS splash renderer. Keep the native splash color-only; let the animated Flutter widget own the photo.
- **Using `respectSilence` (or leaving the default) inconsistently between Android and iOS:** Android's `AudioManager` and iOS's `AVAudioSession` have different silent/DND semantics — `AudioContextConfig(respectSilence: true).build()` produces sane per-platform output (`AVAudioSessionCategory.ambient` on iOS) from one call; don't hand-configure `AudioContextAndroid` and `AudioContextIOS` separately unless a platform-specific edge case demands it.
- **Third-party "animated splash" wrapper packages** — explicitly excluded in `.claude/CLAUDE.md`'s "What NOT to Use"; hand-roll via `flutter_animate` as above.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Pre-engine white-flash prevention | Custom native `Activity`/`AppDelegate` splash code | `flutter_native_splash` | Purpose-built, handles Android 12+'s separate splash API and iOS `LaunchScreen.storyboard` generation automatically — this is exactly the kind of native boilerplate that's easy to get subtly wrong per-platform. |
| Multi-density app icon generation | Manually exporting every `mipmap-*dpi`/`AppIcon.appiconset` size from `logo.jpeg` | `flutter_launcher_icons` | Android alone needs 5+ densities plus adaptive-icon foreground/background layers; iOS needs its own `Contents.json`-described set. One tool, one source image, one command. |
| iOS silent-switch audio category logic | Hand-writing native Swift `AVAudioSession` configuration via a platform channel | `audioplayers`' `AudioContextConfig`/`AudioContextIOS` | The plugin already wraps this exact API surface (`AVAudioSessionCategory`, `AVAudioSessionOptions`) — a platform channel would duplicate a solved problem and reintroduce the crash/hang risk SPLSH-04 explicitly warns against. |
| Release keystore generation | Writing a custom key-generation script | `keytool` (bundled with the JDK) | Standard Java tooling, exactly what `flutter build appbundle` signing expects — see Environment Availability for this machine's specific `keytool` path. |

**Key insight:** every piece of this phase that touches native platform code (splash rendering, icon generation, audio session category) already has a purpose-built, actively-maintained Flutter package covering it end-to-end. The only genuinely custom code in this phase is the Dart-side `SplashScreen` widget's animation choreography — and even that should be copied from `burdah_reveal_screen.dart` rather than designed fresh.

## Common Pitfalls

### Pitfall 1: `images.jpeg` and `logo.jpeg` are not usable as-is
**What goes wrong:** `flutter_native_splash` and `flutter_launcher_icons` both require square PNG source images (ideally 1024×1024). `images.jpeg` (1920×1080, locked by D-01 for the splash photo) is not square, and — more seriously — is **not actually a JPEG**: `file images.jpeg` reports `RIFF ... Web/P image` (WebP data with a misleading `.jpeg` extension), verified directly on this machine. `logo.jpeg` (locked by D-08 as the icon source) is a genuine JPEG but is 399×501 (portrait, not square).
**Why it happens:** Both files were dropped into the repo root with names describing intent, not verified content/dimensions.
**How to avoid:**
- Convert `images.jpeg` to a real image format before bundling: `sips -s format png images.jpeg --out assets/images/madinah_sunset.png` — verified working on this machine (produces genuine `PNG image data, 1920 x 1080`). `images.jpeg` is only used inside the animated Flutter `SplashScreen` widget (`Image.asset` decodes via Skia and would likely have handled the mislabeled WebP fine at runtime regardless — but shipping mislabeled/wrong-extension assets is fragile and should be fixed at the source).
- Square/pad `logo.jpeg` before running `flutter_launcher_icons`: `sips -Z 1024 logo.jpeg --out /tmp/scaled.png && sips -p 1024 1024 /tmp/scaled.png --out assets/icon/app_icon_source.png` — both steps verified working on this machine (produces 815×1024 then padded 1024×1024). Note the upscale from a 501px-tall source to 1024px will show some softness; that's an inherent source-asset quality ceiling, not a tooling bug.
**Warning signs:** `flutter_launcher_icons`/`flutter_native_splash` codegen either errors outright on a non-square/wrong-format source, or silently produces a stretched/cropped/off-center result — always visually inspect the generated launcher icon and splash on both platforms after running the generator.

### Pitfall 2: Android 12+ splash has a separate, stricter config section
**What goes wrong:** Android 12 introduced its own native `SplashScreen` API (distinct from the `styles.xml`-based approach used on older Android and by default on iOS). `flutter_native_splash` requires configuring this separately under an `android_12:` key, and — per multiple documented upstream issues (github.com/jonbhanson/flutter_native_splash issues #399, #413) — setting both a `background_image` and a `color` under `android_12` at once produces build errors, and omitting an icon there falls back to the launcher icon clipped to a circle.
**Why it happens:** Android 12's splash API only supports a solid window background + a centered icon (with its own safe-zone/circle-mask rules) — it cannot render an arbitrary full-bleed background image the way pre-12 Android and iOS splash configs can.
**How to avoid:** Given this phase's decision to keep the native splash **color-only** (no image — see Anti-Patterns), the `android_12:` section only needs `color:` (and `color_dark:` if dark mode differs) set to match the chosen background color. Do not set `android_12.image` unless a dedicated square icon-safe-zone asset is prepared for it.
**Warning signs:** AAPT build errors mentioning `drawable/branding` not found, or a native splash that shows the wrong/circular-cropped image only on Android 12+ test devices/emulators.

### Pitfall 3: `audioplayers`' default iOS audio category ignores the silent switch
**What goes wrong:** Without explicit configuration, `AudioContextConfig()`'s defaults (`respectSilence: false`) build to iOS category `AVAudioSessionCategory.playback` — audio plays even with the hardware silent switch engaged. SPLSH-04 explicitly wants the opposite.
**Why it happens:** `playback` is the sensible default for apps whose whole purpose is audio (podcast/music players); it's the wrong default for a decorative splash sound.
**How to avoid:** Explicitly call `player.setAudioContext(AudioContextConfig(respectSilence: true).build())` (produces `AVAudioSessionCategory.ambient`, documented to be "silenced by the Ring/Silent switch and by screen locking") before `.play()`.
**Warning signs:** Splash audio audible on a physical iPhone even with the side switch flipped to silent — this cannot be caught on Android or in any simulator; it requires a physical iOS device (see Environment Availability).

### Pitfall 4: `pushReplacement` transitions historically had a rendering bug (now closed upstream)
**What goes wrong:** flutter/flutter#138320 documented that `pushReplacementNamed` failed to show the transition animation at all when both the source and destination routes define a `pageBuilder` — which is exactly this app's `_fadePage` pattern used everywhere. If unfixed in the pinned toolchain, D-06's crossfade requirement would silently fail (splash would just vanish, no fade).
**Why it happens:** Was a genuine upstream Navigator/go_router interaction bug in Flutter 3.13/3.17-era versions.
**How to avoid:** The issue is closed/resolved upstream, and this project pins Flutter 3.44.8 / go_router ^17.3.0 (both current 2026 releases, far newer than the affected versions) — it should already work. Still, manually verify the splash→home transition visually shows a crossfade (not an instant cut) as part of this phase's UAT, since it's directly testing a previously-buggy code path.
**Warning signs:** Splash disappears and Home appears with a hard cut instead of an overlapping fade.

### Pitfall 5: MP3 trim precision at frame boundaries
**What goes wrong:** MP3 audio is frame-encoded (~26ms/frame at common bitrates); a naive stream-copy trim (`ffmpeg -i in.mp3 -t 6.1 -c copy out.mp3`) snaps the cut to the nearest frame boundary, not exactly 6.100s, and can leave a decoder pop/click at the cut point.
**Why it happens:** `-c copy` never decodes/re-encodes, so it can't cut mid-frame.
**How to avoid:** Re-encode the trim instead of stream-copying: `ffmpeg -i "Surah Al-Fatiha By Qari Abdul Basit 'Abd us-Samad.mp3" -t 6.1 -c:a libmp3lame -q:a 2 assets/audio/bismillah_trimmed.mp3`. `ffmpeg` (v7.1) is already installed on this machine at `/opt/homebrew/bin/ffmpeg` — no new install needed. [ASSUMED — this specific re-encode flag combination is standard ffmpeg practice from training knowledge, not fetched from ffmpeg's own docs this session; low risk, easy to audibly verify by ear before locking in the trimmed asset.]

## Code Examples

### `flutter_native_splash.yaml` — color-only, matches themed background
```yaml
# Source: pub.dev/packages/flutter_native_splash — Configuration section
flutter_native_splash:
  color: "#0A642B"          # AppColors.lightPrimaryGreen or chosen splash bg
  color_dark: "#0A642B"     # AppColors.darkBackground
  android_12:
    color: "#0A642B"
    color_dark: "#0A642B"
  fullscreen: true
```
Generate/remove with:
```bash
dart run flutter_native_splash:create
dart run flutter_native_splash:remove   # if reverting
```

### `flutter_launcher_icons` config
```yaml
# Source: pub.dev/packages/flutter_launcher_icons — Configuration section
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon_source.png"
  remove_alpha_ios: true     # iOS marketing icon must not have alpha
```
Generate with:
```bash
dart run flutter_launcher_icons
```

### Android release signing (build.gradle.kts)
```kotlin
// Source: docs.flutter.dev/deployment/android — "Build and release an Android app"
import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```
Keystore generation on **this machine** (system `java`/`keytool` is not installed — see Environment Availability — use the JDK bundled with Android Studio instead):
```bash
"/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/keytool" \
  -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA \
  -storetype JKS -keysize 2048 -validity 10000 -alias upload
```
`android/key.properties` and the `.jks` file must be added to `.gitignore` — never committed.

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|---------------|--------|
| Single `styles.xml`-based splash for all Android versions | Separate native `SplashScreen` API for Android 12+, requiring `flutter_native_splash`'s `android_12:` config block | Android 12 (API 31) | Must configure the `android_12:` section explicitly or the app falls back to a plain launcher-icon-in-a-circle splash on modern Android. |
| `audioplayers` `defaultToSpeaker` on `AudioContextIOS` | Moved to `AVAudioSessionOptions.defaultToSpeaker` | audioplayers ~3.x | Not directly relevant to this phase (no speaker-routing need) but confirms the `AudioContextIOS` API surface has shifted across major versions — always check current pub.dev docs/source rather than older tutorials when writing the audio context call. |

**Deprecated/outdated:** None directly blocking this phase; the pinned dependency versions (Flutter 3.44.8, go_router 17.3.0, flutter_animate 4.5.2) are all current as of this research date.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | The specific ffmpeg re-encode flags (`-c:a libmp3lame -q:a 2`) recommended for the 6.1s trim are standard practice, not confirmed against ffmpeg's own docs this session | Common Pitfalls (Pitfall 5), Code Examples | Low — worst case is a slightly different bitrate/quality than ideal; trivially audible-verified before locking the asset in, and easily re-run if unsatisfactory. |
| A2 | Store metadata content (descriptions, category selection, privacy-policy placeholder wording) will be Claude-authored per CONTEXT.md's "Claude's Discretion" — no external research was done on exact current copy-length limits or category taxonomies for Play Console / App Store Connect this session | Summary, (not otherwise detailed — left to planner/execution) | Medium — store consoles occasionally reject copy for length/policy reasons; this is normally caught and correctable at actual submission time, not a phase-blocking risk. |

**If this table is empty:** N/A — two low/medium-risk assumptions logged above; neither blocks planning.

## Open Questions

1. **Can SPLSH-04's iOS silent-switch requirement actually be verified this phase?**
   - What we know: The correct API call (`AudioContextConfig(respectSilence: true).build()` → `AVAudioSessionCategory.ambient`) is well-documented and should be implemented regardless.
   - What's unclear: This dev machine has no usable Xcode, no iOS simulator, and no physical iOS device attached (see Environment Availability) — actual on-device silent-switch behavior cannot be observed in this session.
   - Recommendation: Implement per the documented pattern, then insert a `checkpoint:human-verify` task requiring physical iPhone testing with the silent switch engaged before this phase is considered fully done — matches the existing STATE.md blocker note for Phase 4.

2. **Will the existing `test/widget_test.dart` smoke test need updating?**
   - What we know: It currently pumps `BurdahApp` and expects to immediately find `'Design System Test'` text — but the router's `'/'` route already points to `HomeScreen`, not the design-system screen, so this test may already be stale independent of this phase's changes.
   - What's unclear: Whether it's currently passing at all, and whether adding a Splash screen at `'/'` (replacing Home) will further break or coincidentally not affect it, since `nyquist_validation` is disabled for this project (`.planning/config.json`) and no test-infrastructure audit was performed this session.
   - Recommendation: Planner should have the execution wave run `flutter test` early to establish baseline pass/fail state before adding the splash route, so any breakage introduced by this phase's changes is clearly attributable.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter SDK | Everything in this phase | ✓ | 3.44.8 (stable) | — |
| Android SDK / emulator | Android splash/build/test | ✓ | SDK 36, emulator running Android 17 (API 37) | — |
| Xcode (full) | iOS build (`flutter build ipa`), iOS simulator, Info.plist/signing work | ✗ — only Command Line Tools installed (`flutter doctor` reports "Xcode installation is incomplete") | — | No fallback for actual iOS build/signing — install full Xcode from the App Store before D-07's iOS submission work can be executed. |
| iOS Simulator or physical iPhone | Verifying D-06/SPLSH-04 iOS behavior, esp. silent-switch audio | ✗ — no simulator (requires Xcode), no physical device in `flutter devices` output | — | None — this must become a `checkpoint:human-verify` task; cannot be validated in this environment at all this phase. |
| `keytool` (system Java) | Android release keystore generation | ✗ system `java`/`keytool` reports "Unable to locate a Java Runtime" | — | ✓ Use the JDK bundled with the already-installed Android Studio instead: `/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/keytool` — verified working on this machine. |
| `ffmpeg` | Trimming the Bismillah audio clip to 6.1s | ✓ | 7.1 (Homebrew, `/opt/homebrew/bin/ffmpeg`) | — |
| `sips` (macOS built-in) | Fixing/converting `images.jpeg` and `logo.jpeg` before bundling | ✓ | macOS built-in, no version needed | — |
| CocoaPods | iOS dependency install (`pod install`, implicitly run by `flutter build`) | ✓ | 1.17.0 | — |

**Missing dependencies with no fallback:**
- Full Xcode install and an attached iOS simulator/physical device — blocks all iOS-side verification (D-06 iOS-specific behavior, D-07 iOS signing/submission) for this session. Plan must include a `checkpoint:human-verify` (or explicit deferral) for this work.

**Missing dependencies with fallback:**
- System `java`/`keytool` — use the Android-Studio-bundled JDK path documented above instead of requiring a separate JDK install.

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-------------------|
| V2 Authentication | No | App has no accounts/login (REQUIREMENTS.md Out of Scope). |
| V3 Session Management | No | No sessions. |
| V4 Access Control | No | No user roles/permissions. |
| V5 Input Validation | No | Splash/icon/signing work involves no user-supplied input. |
| V6 Cryptography | Partial — signing keys | Android upload keystore (`.jks`) and iOS distribution certificate are cryptographic material; never commit `key.properties` or the `.jks` file to git (must be `.gitignore`d — standard practice per Flutter's own deployment docs, not a custom crypto implementation). |
| V14 Configuration | Yes | Store submission config (bundle ID, signing config) is one-way/irreversible per D-07 — treat as a locked decision requiring care, not a reversible code change. |

### Known Threat Patterns for this phase's stack

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|----------------------|
| Committing signing secrets (`key.properties`, `.jks`, iOS distribution certs/provisioning profiles) to version control | Information Disclosure | `.gitignore` entries for `android/key.properties`, `*.jks`, `*.p12`, `ios/**/*.mobileprovision` — verify these are added as part of the signing-config task, not left as a TODO. |
| Slopsquatted/typosquatted pub.dev package name substituted for a legitimate one | Tampering (supply chain) | Package Legitimacy Audit above — all three new packages independently confirmed against the pub.dev registry API + GitHub source, not taken on faith from CLAUDE.md's own recommendation. |
| Third-party postinstall/build scripts in a Flutter/Dart package | Tampering | Dart/`pub` packages do not have an npm-style arbitrary `postinstall` script hook — the closest analog (`flutter_launcher_icons`/`flutter_native_splash`'s `dart run <pkg>:create` codegen commands) only writes to known, git-visible asset/config paths (`android/app/src/main/res/**`, `ios/Runner/Assets.xcassets/**`, `ios/Runner/Base.lproj/LaunchScreen.storyboard`) — diff these generated files after running the tool rather than blind-trusting the codegen output. |

## Sources

### Primary (HIGH confidence)
- pub.dev registry API (`pub.dev/api/packages/{audioplayers,flutter_native_splash,flutter_launcher_icons}` and `.../score`) — versions, publish dates, like counts, pub points, verified 2026-07-26 via direct `curl`.
- `docs.flutter.dev/deployment/android` — Android release signing steps (keytool, `key.properties`, `build.gradle.kts` config), fetched directly.
- `docs.flutter.dev/deployment/ios` — iOS signing/provisioning, `flutter build ipa`, App Store Connect upload steps, fetched directly.
- github.com/bluefireteam/audioplayers/blob/main/packages/audioplayers_platform_interface/lib/src/api/audio_context_config.dart — direct source read confirming default `AudioContextConfig()` builds iOS category `playback` (silent-switch-ignoring), and that `respectSilence: true` changes this.
- github.com/bluefireteam/audioplayers/blob/main/packages/audioplayers_android/android/src/main/AndroidManifest.xml — direct source read confirming the Android plugin declares zero `uses-permission` entries (no `INTERNET` permission auto-merged for local-asset playback).
- On-machine verification (this session, 2026-07-26): `flutter --version` (3.44.8), `flutter doctor` (Xcode incomplete, Android toolchain OK), `flutter devices` (no iOS device/simulator), `file`/`sips` inspection of `images.jpeg` (actual WebP data) and `logo.jpeg` (genuine JPEG, 399×501 non-square), `sips` conversion/pad commands tested and confirmed working, `keytool` path confirmed at the Android-Studio-bundled JDK location.

### Secondary (MEDIUM confidence)
- github.com/bluefireteam/audioplayers/blob/main/getting_started.md — `AssetSource`/`AudioContext`/`dispose()` usage examples (WebFetch summary, cross-checked against the primary source-code read above).
- github.com/flutter/flutter/issues/138320 — `pushReplacementNamed` transition-animation bug, confirmed closed/resolved upstream.
- github.com/jonbhanson/flutter_native_splash issues #399, #413 — Android 12 `android_12.image`/`color` conflict and branding-image-not-working reports.
- pub.dev/packages/audioplayers and pub.dev/packages/flutter_native_splash and pub.dev/packages/flutter_launcher_icons package pages (WebFetch summaries of config structure, generate/remove commands).

### Tertiary (LOW confidence — general community sources, cross-checked but not vendor-authoritative)
- WebSearch results on Google Play Data Safety form requirements, screenshot size guidance, and feature-graphic dimensions (2026-dated blog posts, multiple independent sources broadly agree but none are Google's own docs fetched directly this session).
- WebSearch results on flutter_launcher_icons/flutter_native_splash "square PNG, 1024×1024 recommended" sizing guidance (community tutorials, consistent across sources, not the package's own README fetched verbatim for this specific claim).

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — all three new packages verified directly against the pub.dev registry API, cross-referenced with source repos.
- Architecture (splash widget/animation/routing): HIGH — entirely reuses existing, already-shipped patterns in this codebase (`burdah_reveal_screen.dart`, `app_router.dart`).
- iOS audio silent-mode behavior: HIGH confidence on *what API to call*, LOW confidence on *verified real-device behavior* — cannot be tested in this environment this session (see Environment Availability, Open Questions #1).
- Release/store submission mechanics (Android): HIGH — official Flutter docs fetched directly, and every prerequisite tool (Android SDK, `sips`, `ffmpeg`, Android-Studio-bundled `keytool`) verified present and working on this machine.
- Release/store submission mechanics (iOS): MEDIUM on documentation, LOW on this-machine executability — full Xcode is not installed; the documented steps are correct but cannot be run/verified here.
- Pitfalls: HIGH — several (asset format mismatch, non-square icon source, missing Xcode) were discovered via direct on-machine verification rather than general research, and are specific to this exact repo state.

**Research date:** 2026-07-26
**Valid until:** 30 days for package versions/pub.dev data (fast-moving pub.dev ecosystem); the on-machine environment findings (Xcode, keytool, asset format issues) are valid until the next `flutter doctor`/Xcode install change on this specific machine, or until `images.jpeg`/`logo.jpeg` are replaced/converted.
