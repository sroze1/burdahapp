# Pitfalls Research

**Domain:** Flutter mobile app — PDF viewing + custom animation + Arabic/RTL sacred-text content
**Researched:** 2026-07-24
**Confidence:** MEDIUM (individual web sources are LOW-tier per source-hierarchy classification, but findings are corroborated across multiple independent official `flutter/flutter` and package-repo GitHub issues, so the pattern itself is HIGH-confidence even though any single citation is not authoritative)

## Critical Pitfalls

### Pitfall 1: PDF viewer memory leaks / OutOfMemoryError on real device hardware

**What goes wrong:**
The PDF renders fine in the emulator/simulator during development, then crashes on physical mid-range Android devices or after the user zooms and pans repeatedly. Syncfusion's PDF viewer and other PDFium-backed viewers have open issues showing iOS releases only ~10% of memory after a zoom/pan, so memory climbs with every page turn until the app is killed. Fast scrolling through image-heavy PDFs (which a calligraphic Arabic manuscript page-scan effectively is) also shows visible rasterization lag ("white gaps") because the renderer can't decode pages fast enough.

**Why it happens:**
Developers test with a handful of page-turns in a simulator with unlimited RAM and never stress-test with 50+ page flips or on a 2-3 year old Android phone. The Burdah PDF is likely a scanned/high-res manuscript, which is exactly the "image-heavy" case that triggers this.

**How to avoid:**
Pick a PDF rendering approach that supports lazy/on-demand page rendering (render current ± 1 page, dispose others) rather than loading the whole document into memory at once. Test with the actual production PDF (not a placeholder) on a real low/mid-range Android device early, and specifically hammer the zoom-in/zoom-out/page-turn cycle 30+ times in a row before considering the PDF viewer phase done.

**Warning signs:**
Memory usage (visible in Android Studio profiler / Xcode Instruments) climbs and never comes back down after repeated page turns; app becomes sluggish or crashes after ~10-20 page changes; visible white flash/lag when swiping quickly.

**Phase to address:**
PDF Viewer implementation phase — must include a device-memory stress test as an explicit verification step, not just "PDF opens and displays."

---

### Pitfall 2: Gesture conflict between page-swipe and pinch-to-zoom

**What goes wrong:**
The spec requires both "swipe navigation" (page-by-page, book-like) and "pinch-to-zoom." These two gesture systems fight for the same touch input: a `PageView`'s horizontal drag recognizer and a zoom widget's pan/scale recognizer both claim horizontal drags, so pinch-zooming can accidentally flip the page, or panning a zoomed-in page can accidentally trigger a page turn instead of panning.

**Why it happens:**
Naively wrapping a zoomable widget (e.g. `PhotoView` or `InteractiveViewer`) inside a `PageView` without coordinating gesture state. This looks correct in a quick manual test (a single deliberate pinch or a single deliberate swipe) and only breaks under realistic mixed-gesture use.

**How to avoid:**
Explicitly track zoom scale state per page. Disable `PageView` swipe physics (`NeverScrollableScrollPhysics` or controller-lock) whenever the current page's zoom scale is not at its reset/initial value; only re-enable page-swipe once the user has zoomed back out to 1x. This is the documented working pattern from the Flutter community for this exact PDF-reader-with-zoom combination.

**Warning signs:**
During manual testing, zooming in on a page unexpectedly flips to the next/previous page; or panning across a zoomed page does nothing because the swipe gesture "wins" the arena.

**Phase to address:**
PDF Viewer implementation phase — should be called out as an explicit UAT check ("zoom in, then pan in all directions, confirm no page change occurs").

---

### Pitfall 3: Arabic font/script rendering breaks — separated letters, wrong weights, broken justification

**What goes wrong:**
Arabic script requires letters to join into contextual ligature forms (initial/medial/final/isolated). Flutter has multiple open, unresolved issues where custom Arabic fonts render with letters disconnected/separated instead of properly joined — especially after Flutter version upgrades or under the newer Impeller rendering engine. Separately, font-weight properties often silently fail to apply to custom fonts (Flutter does not infer weight from the file name; every weight variant must be explicitly declared in `pubspec.yaml`), and RTL `justify` text alignment can start from the wrong side when a line contains a single word.
For an app whose entire value proposition is "beautiful, reverent, sacred-feeling calligraphy," broken letter joining is a launch-blocking visual bug, not a cosmetic nit.

**Why it happens:**
Developers pick a nice-looking Arabic/calligraphic font from Google Fonts or a foundry without test-rendering the specific glyphs used in the Burdah text on the specific Flutter version/rendering engine (Skia vs Impeller) targeted for release. Font shaping bugs are version and engine dependent, so "it worked in my last project" does not transfer.

**How to avoid:**
Before committing to a calligraphic font, render the actual Burdah title text and a full sample page's worth of Arabic text in a throwaway test screen on both Android and iOS, on the exact Flutter version pinned for this project, and visually verify correct letter joining, diacritics (tashkeel) placement, and weight rendering. If using Impeller (default on newer Flutter/iOS), test specifically on that engine — some Arabic shaping bugs are Impeller-only. Declare every font weight file explicitly in `pubspec.yaml` rather than relying on a single file to serve multiple weights.

**Warning signs:**
Arabic letters appear visually disconnected (each letter in its isolated form rather than flowing into neighbors); bold/weight variants render identically to regular; text that should read right-aligned starts from the left when justified.

**Phase to address:**
Design/typography setup phase, before PDF content or animation work begins — font choice is foundational and expensive to change late. Should be verified again in the final visual-polish phase.

---

### Pitfall 4: RTL/LTR mixed-direction UI bugs beyond just "flip the layout"

**What goes wrong:**
Flutter has long-standing, still-open bugs when RTL Arabic text mixes with LTR content (numbers, English UI labels, mixed strings): corrupted text overflow, inconsistent cursor/selection behavior, and text-direction "bleeding" into unrelated widgets. Teams that treat RTL support as "set `Directionality.rtl` once at the app root" miss that icons, animation directions (e.g., a slide transition that should move right-to-left, not left-to-right, for RTL content), and numeral formatting also need explicit RTL-aware handling.

**Why it happens:**
RTL is treated as a single global switch instead of a property that must be verified on every screen and every custom-animated transition individually. This app has custom animations (splash text animation, screen transitions) which are exactly the kind of hand-rolled component that `Directionality` doesn't automatically fix.

**How to avoid:**
Set `Directionality` explicitly per text-bearing widget based on the actual content being displayed (Arabic Burdah text vs. any English UI chrome), don't rely solely on app-wide locale. Manually verify every custom animation/transition in the context of RTL — the splash screen's Bismillah text animation and any page transition should be checked for correct visual direction, not just correct final layout.

**Warning signs:**
Text overflows in unexpected ways with longer Arabic strings; page-turn animations feel "backwards" relative to reading direction; any English UI text near Arabic text (e.g., a page-number indicator) renders in the wrong position or order.

**Phase to address:**
UI/animation implementation phase — RTL correctness should be an explicit UAT check on every screen, not assumed from a single global setting made in the architecture phase.

---

### Pitfall 5: The "native splash screen flash" cannot be fully eliminated

**What goes wrong:**
Both Android and iOS show their own native, unstyled loading screen (which defaults to white) before Flutter's first frame renders — before your custom animated Bismillah splash even starts. Teams that don't know this ship an app with a jarring white flash immediately followed by the "real" splash animation, which looks broken and undermines the reverent, elegant first impression the app is going for.

**Why it happens:**
`flutter_native_splash` and similar tools are frequently misunderstood as replacing the platform's native pre-render screen; in reality they can only recolor/rebrand that native screen (matching background color, adding a static logo) — the transition to the actual animated Flutter splash still happens as a second, distinct step.

**How to avoid:**
Configure `flutter_native_splash` (or equivalent) to set the native pre-render screen's background color and, if desired, a static logo that visually matches the first frame of the custom animated splash, so the handoff between "native OS splash" → "Flutter custom animated splash" is seamless rather than a color/content jump. Explicitly test cold-launch timing on a real low-end device (slower to reach first Flutter frame) — not just an emulator, and also test launching from a fresh install vs. any deep-link/notification path.

**Warning signs:**
Visible white flash before the Bismillah animation on physical device testing (especially older/slower phones); different splash behavior when app is cold-launched from the home-screen icon vs. from a system notification or deep link.

**Phase to address:**
Splash screen implementation phase — native splash config should be treated as a first-class deliverable alongside the animated Bismillah screen, not an afterthought.

---

### Pitfall 6: Audio playback ignoring or fighting the iOS silent/ring switch

**What goes wrong:**
Flutter audio plugins (`just_audio`, `audioplayers`, `flutter_sound`, `AssetsAudioPlayer`) have documented, inconsistent behavior around iOS's hardware silent switch — audio recitation may play even when the user has silenced their phone (jarring in a mosque/quiet setting, and religiously/socially awkward for Qur'anic recitation specifically), or conversely may fail to play at all depending on how the iOS `AVAudioSession` category is configured, regardless of the plugin's own "respect silent mode" flag.

**Why it happens:**
The plugin-level "respect silent mode" setting is unreliable across iOS versions/plugin versions per multiple open GitHub issues; correct behavior actually depends on manually configuring the underlying `AVAudioSession` category (e.g., `ambient` vs `playback`), which most Flutter developers don't realize they need to touch directly.

**How to avoid:**
Explicitly configure the iOS audio session category to respect the silent switch for this splash-audio use case (recitation should NOT blast through silent mode — this is a sacred audio clip, not a game sound effect), and test on a real physical iPhone with the ring/silent switch toggled, not just the simulator (the simulator does not have a hardware silent switch and cannot reproduce this bug).

**Warning signs:**
Bismillah recitation plays through the speaker even when the phone is in silent mode during manual device testing; behavior differs between simulator and real device (simulator masks this entire class of bug).

**Phase to address:**
Splash audio integration phase — must include physical-device testing with the silent switch toggled as an explicit verification step.

---

### Pitfall 7: Custom animation jank from layout-triggering setState instead of pure transform/opacity animation

**What goes wrong:**
The animated Bismillah splash text and any custom transitions look smooth in a quick dev-run but stutter/drop frames on mid-range devices. Root cause is almost always that the animation drives a layout-affecting property (width, height, padding, font size via `setState`) rather than a purely compositor-level property (`Transform`, `Opacity`), forcing Flutter to re-run layout/paint every frame instead of just re-compositing. First-run "shader compilation jank" is a second, distinct cause — the first time a new visual effect (custom shader, certain blur/blend effects) runs, there's a stutter while it JIT-compiles.

**Why it happens:**
It's easy to write animation code that "just works" using `setState` and `AnimatedContainer`-style size/position changes because it's the first pattern most tutorials teach; the jank isn't visible on a fast development machine/simulator, only on real mid/low-tier phones.

**How to avoid:**
Drive the splash text and transition animations through `AnimationController` + `Transform`/`Opacity`/`FadeTransition` rather than layout-affecting properties. Wrap animated subtrees in `RepaintBoundary` to limit repaint scope. Use `AnimatedBuilder`'s `child` parameter to avoid rebuilding static children every frame. If using custom shaders/effects, warm them up before the animation is first shown to the user (or accept a one-time negligible stutter and hide it inside the transition).

**Warning signs:**
Animation looks smooth on the dev's laptop-tethered device but visibly stutters when profiling with `flutter run --profile` on a real mid-range Android phone; Flutter DevTools performance overlay shows red/janky frames during the splash or transition.

**Phase to address:**
Splash screen / animation implementation phase — should include a profile-mode (not debug-mode) frame-rate check on a real device as part of verification.

---

### Pitfall 8: Over-restrictive permission requests trigger App Store / Play Store scrutiny

**What goes wrong:**
Analysis of popular religious apps found they average 21 requested permissions with ~3.7 flagged "dangerous" by Android — far more than such content-only apps actually need. Google and Apple both apply extra scrutiny to unnecessary permission requests and require accurate, complete privacy-policy disclosure; a mismatch between requested permissions and an app's disclosed purpose is a common rejection/delay trigger, not "religious content" itself (religious content per se is not against either store's policy).

**Why it happens:**
Boilerplate templates, ad SDKs, or analytics packages pulled in "just in case" request permissions (contacts, location, microphone) the app doesn't actually use. A read-only PDF + audio-clip app needs essentially zero sensitive permissions.

**How to avoid:**
Audit the final `AndroidManifest.xml` / iOS `Info.plist` permission/usage-description entries before submission and remove anything not directly required by an actually-used feature. This app needs no location, contacts, camera, or microphone access — if any dependency silently adds such a permission, strip it or replace the dependency. Write an accurate, minimal privacy policy reflecting that the app stores no user data and requests no sensitive permissions.

**Warning signs:**
`flutter build` output or manifest merger warnings show permissions you didn't explicitly request (often pulled in transitively by a plugin); store review flags "permission use unclear" or requests a privacy policy update.

**Phase to address:**
Pre-submission / release-prep phase — should include an explicit manifest/plist permission audit as a checklist item before first store submission.

---

## Technical Debt Patterns

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|-----------------|-----------------|
| Load entire PDF into memory instead of lazy/paged rendering | Simpler code, faster to ship v1 | Crashes on real devices with high-res manuscript scans, especially as more burdahs are added | Never for the production PDF viewer — acceptable only in an early throwaway spike |
| Hardcode the single Burdah's metadata/path instead of a data-driven list structure | Faster initial screen build | Contradicts the explicit "extensible for adding more burdahs" requirement; forces a rewrite for milestone 2 | Only in a disposable prototype, never in the shipped architecture |
| Skip physical-device testing, rely on simulator/emulator only | Faster iteration during development | Misses iOS silent-mode bug, PDF memory-leak crashes, and real animation jank — all of which are invisible or behave differently on simulator | Never before release; fine for early UI-layout iteration only |
| Use a single font weight file for all weights ("just fake it with `fontWeight`") | Saves time picking/testing font weight files | Bold text silently renders identically to regular, undermining the calligraphic design goal | Never for the final release; acceptable placeholder during early wireframing |

## Integration Gotchas

| Integration | Common Mistake | Correct Approach |
|-------------|-----------------|-------------------|
| PDF viewer package (Syncfusion / pdfrx / flutter_pdfview) | Choosing Syncfusion for its rich feature set without noticing it requires a commercial or community license | Use a license-free option (e.g., `pdfrx`) unless the Syncfusion license terms are explicitly acceptable for this project |
| Audio plugin (just_audio / audioplayers) | Assuming the plugin's "respect silent mode" flag works out of the box on iOS | Manually configure the iOS `AVAudioSession` category and verify with the physical silent switch |
| Custom Arabic font | Bundling a font without verifying letter-joining/shaping on the target Flutter version and rendering engine (Skia/Impeller) | Render a full sample of the actual Burdah Arabic text in a throwaway screen on both platforms before locking in the font |
| flutter_native_splash | Assuming it removes the OS's own pre-render white screen | Configure it to recolor/match the native pre-screen so the handoff to the custom animated splash is seamless, and accept the native screen cannot be removed entirely |

## Performance Traps

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|-----------------|
| Loading the whole PDF document into memory per view | Works fine on first 1-2 pages/on simulator | Use lazy/on-demand page rendering, dispose off-screen pages | Breaks on real devices around page 15-30+ of a high-res scanned manuscript, or after ~10-20 zoom/pan cycles |
| Layout-based animation (setState driving size/position) | Smooth in debug on dev machine | Use Transform/Opacity-driven AnimationController animations, RepaintBoundary | Breaks (visible jank) on mid/low-tier real devices, invisible in debug-mode-on-fast-hardware testing |
| Bundling every future burdah PDF as a static asset from day one | Simple architecture at 1 burdah | Design the data layer so burdahs can be added via a manifest without bloating base install (e.g., per-burdah asset packs or future remote fetch) | Breaks (app size complaints, slow updates) once library grows past a handful of burdahs |

## Security Mistakes

| Mistake | Risk | Prevention |
|---------|------|------------|
| Pulling in a plugin/SDK that silently requests unnecessary permissions (analytics, ads, etc.) | Store rejection/delay, user distrust for a "reverent, distraction-free" app that shouldn't need broad permissions | Vet every dependency's requested permissions; strip anything not used by an actual feature |
| No privacy policy despite bundling audio + content | Store rejection for incomplete metadata even though the app collects no user data | Publish a minimal, accurate privacy policy stating no data collection, before first submission |

## UX Pitfalls

| Pitfall | User Impact | Better Approach |
|---------|-------------|-------------------|
| White flash before the animated splash even starts | Undermines the "reverent, elegant" first impression the whole app is designed around | Recolor the native pre-splash screen to match the app's brand/background so the transition is seamless |
| Pinch-zoom accidentally flipping pages | Frustrating, breaks immersion during quiet reading | Lock page-swipe physics while zoomed in; only re-enable at 1x zoom |
| RTL animations/transitions that visually move the "wrong way" for Arabic reading direction | Subtle but jarring, feels unpolished for a design-forward app | Explicitly verify every custom transition direction against RTL content, not just final static layout |
| Recitation audio playing over a silenced phone | Socially/religiously awkward, disrespectful in shared/quiet spaces given the sacred audio content | Correctly wire the iOS audio session to respect the hardware silent switch, and test on real device |

## "Looks Done But Isn't" Checklist

- [ ] **PDF viewer:** Often missing real-device memory stress testing — verify by zoom/pan/page-turn cycling 30+ times on a real mid-range Android phone with the actual production PDF, not a placeholder.
- [ ] **Arabic font:** Often missing letter-joining/shaping verification — verify by rendering the full actual Burdah title and a sample page's Arabic text on both Android and iOS with the pinned Flutter version, checking joined-letter forms and bold-weight rendering.
- [ ] **Splash screen:** Often missing native pre-screen color match — verify by cold-launching on a real (not simulated) low-end device and confirming there's no visible color/content jump before the animated Bismillah appears.
- [ ] **Splash audio:** Often missing iOS silent-mode behavior — verify by toggling the physical ring/silent switch on a real iPhone and confirming audio behaves as intended (respects silence, given the content is sacred recitation).
- [ ] **Zoom + swipe:** Often missing gesture-conflict handling — verify by zooming in then attempting to swipe/pan in all directions, confirming no accidental page change occurs.
- [ ] **Extensibility requirement:** Often missing a real data-driven structure — verify by confirming a second burdah entry can be added via data/config alone, no code changes, before calling the architecture phase complete.
- [ ] **Store submission:** Often missing a permission audit — verify by inspecting the final manifest/plist for any permission not directly justified by a used feature.

## Recovery Strategies

| Pitfall | Recovery Cost | Recovery Steps |
|---------|-----------------|------------------|
| PDF memory leak discovered late | MEDIUM | Swap in/optimize toward a lazy-page-rendering approach; add explicit page disposal; re-test on real device |
| Arabic font shaping broken late (post font-selection lock-in) | HIGH | Re-select and re-test a different font family across the whole app; touches typography system-wide |
| Gesture conflict discovered late | LOW | Add zoom-state tracking and conditionally lock PageView physics; isolated, well-documented fix |
| Non-extensible data structure discovered before milestone 2 | MEDIUM | Refactor single hardcoded burdah entry into a manifest/list-driven structure before adding the second burdah |
| Native splash white-flash discovered late | LOW | Reconfigure flutter_native_splash background color; no architectural change needed |
| Permission bloat discovered at submission | LOW-MEDIUM | Audit and strip unused permissions from manifest/plist, remove or replace offending dependency, resubmit |

## Pitfall-to-Phase Mapping

| Pitfall | Prevention Phase | Verification |
|---------|-------------------|-----------------|
| PDF memory leak / OOM | PDF Viewer phase | Real-device stress test: 30+ zoom/pan/page-turn cycles on the actual production PDF |
| Gesture conflict (zoom vs. swipe) | PDF Viewer phase | Manual UAT: zoom in, attempt swipe/pan in all directions, confirm no page change |
| Arabic font shaping/weight bugs | Design/Typography setup phase (before content/animation work) | Render full actual Arabic text sample on pinned Flutter version, both platforms, check letter joining + weights |
| RTL/LTR mixed-direction bugs | UI/Animation implementation phase | Per-screen and per-transition RTL visual check, not just a global Directionality setting |
| Native splash white flash | Splash Screen phase | Cold-launch on a real low-end device, confirm no visible color/content jump |
| Audio ignoring iOS silent switch | Splash Audio integration phase | Toggle real iPhone's physical silent switch, confirm correct behavior |
| Animation jank (layout-based vs. transform-based) | Splash Screen / Animation phase | Profile-mode (not debug) frame check on a real mid-range device |
| Non-extensible data structure | Architecture / data-layer phase | Confirm a second burdah can be added via data/config alone, no code change |
| Store rejection from permission bloat | Release-prep / submission phase | Manual manifest/plist permission audit before first submission |

## Sources

- [flutter/flutter #34610 — Mixing RTL and LTR text bugs](https://github.com/flutter/flutter/issues/34610)
- [flutter/flutter #117902 — Corrupted overflow in mixed RTL text](https://github.com/flutter/flutter/issues/117902)
- [flutter/flutter #138788 — Arabic RTL justify wrong direction with single word](https://github.com/flutter/flutter/issues/138788)
- [flutter/flutter #143941 / #143975 / #160841 — Custom Arabic font rendering issues](https://github.com/flutter/flutter/issues/143941)
- [flutter/flutter #119805 — Impeller incorrect Arabic text rendering](https://github.com/flutter/flutter/issues/119805)
- [flutter/flutter #50216 — Configured font weights not aligning with custom font](https://github.com/flutter/flutter/issues/50216)
- [syncfusion/flutter-widgets #2192 — OutOfMemoryError loading large PDF](https://github.com/syncfusion/flutter-widgets/issues/2192)
- [syncfusion/flutter-widgets #2032 — Memory leak in syncfusion_flutter_pdfviewer](https://github.com/syncfusion/flutter-widgets/issues/2032)
- [syncfusion/flutter-widgets #632 — Multiple PDFViewer scrolling/performance issues](https://github.com/syncfusion/flutter-widgets/issues/632)
- [espresso3389/pdfrx #319 — Slow loading of some PDF files](https://github.com/espresso3389/pdfrx/issues/319)
- [fluttergems.dev — PDF package comparison](https://fluttergems.dev/pdf/)
- [Medium — Resolve Gesture Conflicts in Flutter with Scroll and Pinch-to-Zoom](https://medium.com/@valerii.novykov/how-to-resolve-gesture-conflicts-in-flutter-with-scroll-and-pinch-to-zoom-6d6b2f525550)
- [fireslime/photo_view #172 — PhotoView pan-down gesture](https://github.com/fireslime/photo_view/issues/172)
- [flutter_native_splash pub.dev page + issue #739 — white screen on notification launch](https://github.com/jonbhanson/flutter_native_splash/issues/739)
- [florent37/Flutter-AssetsAudioPlayer #349 — iOS silent mode not respected](https://github.com/florent37/Flutter-AssetsAudioPlayer/issues/349)
- [Canardoux/flutter_sound #1028 — No sound in iOS silent mode](https://github.com/Canardoux/flutter_sound/issues/1028)
- [Comparitech — 50% of religious apps may violate Google Play policies](https://www.comparitech.com/news/religious-apps-study/)
- [digia.tech — Smooth, high-performance Flutter animations guide](https://www.digia.tech/post/flutter-animation-performance-guide/)
- [xvrh/lottie-flutter #98 — Performance degradation with size](https://github.com/xvrh/lottie-flutter/issues/98)

---
*Pitfalls research for: Flutter Islamic reading app (PDF + custom animation + Arabic/RTL)*
*Researched: 2026-07-24*
