# Feature Research

**Domain:** Islamic reading/poetry app (Burdah poems — Arabic devotional poetry, mushaf/mawlid-adjacent category)
**Researched:** 2026-07-24
**Confidence:** MEDIUM (feature landscape corroborated across multiple app-store listings and reviews; no single-source claims taken as fact — see Sources)

## Feature Landscape

This domain sits at the intersection of three existing app categories, each with its own established feature norms:

1. **Quran/mushaf reader apps** (Quran.com, Muslim Pro, iQuran, Al Quran Tafsir&ByWord) — the most mature and highest-bar category for reverent Arabic text presentation.
2. **Existing single-poem Burdah/Mawlid apps** (Qasida Burda Sharif, Burda Baith, Qaseeda Burda with Urdu) — direct competitors, low production value, single-purpose.
3. **General Urdu/Arabic poetry apps** (Rekhta) — shows what a *mature, multi-work* poetry app looks like once a collection grows beyond one poem, directly relevant to BurdahApp's stated goal of expanding beyond the first Burdah.

### Table Stakes (Users Expect These)

Features users assume exist. Missing these = product feels incomplete or broken for this domain.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Complete, accurate Arabic text | Every reviewed competitor (Quran apps, Burda apps) leads with full, faithful Arabic text — accuracy is non-negotiable for sacred content | LOW | Already solved via PDF-of-original approach (per PROJECT.md decision) — preserves calligraphy, sidesteps OCR/transcription risk |
| Pinch-to-zoom on text/pages | Present in every competitor reviewed (Quran apps and all Burda apps); Arabic script is dense and users need to zoom for comfort | LOW | Already in PROJECT.md scope. Must not conflict with page-swipe gesture (a recurring UX complaint in generic PDF readers) |
| Book-like page navigation (swipe) | Matches how reviewers describe the desired reading feel; also matches how sacred texts are traditionally read (page by page, not endless scroll) | MEDIUM | Already in PROJECT.md scope. Page-turn transitions should feel deliberate/reverent, not gimmicky |
| Offline access | Every Burda/Mawlid app reviewed advertises offline access as a core feature; users read devotional text without reliable connectivity (mosque, travel, night) | LOW | Trivial here since content is bundled PDF assets, not fetched — inherent, not an extra build cost |
| No ads / no interstitials | Not universal, but the highest-regarded app in the space (Quran.com) is explicitly praised as "ad-free with the cleanest interface," while Muslim Pro is heavily criticized for ad load — reviews show ads are a top complaint in this category | LOW (as absence) | This is a design decision more than a feature: simply never add ad SDKs. See Anti-Features. |
| Fast, distraction-free launch to content | Sacred-text apps that are described as reverent get there by getting out of the user's way; competitors bloated with extra sections get criticized as "trying to do too much" | LOW | Aligns directly with PROJECT.md's splash → main → Burdah list → reader flow — keep it that lean |
| RTL-correct Arabic rendering | Any Arabic content app must correctly right-align/shape Arabic glyphs; a broken RTL implementation (mixed alignment, wrong glyph joining) is an instant credibility killer for an Islamic content app | MEDIUM | Flutter has built-in RTL support (`Directionality`) but requires deliberate testing since the rest of the app UI (nav, buttons) may need to be LTR while the Arabic content pane is RTL |
| Legible, appropriately-sized Arabic typography | Reviewed best practice: Arabic needs ~10–15% larger size and more line-height than Latin equivalents; thin font weights are hard to read in Arabic | LOW–MEDIUM | Since PROJECT.md uses PDF pages (not live-rendered text), this applies mainly to any in-app Arabic labels ("Burdah," button text, list titles), not the poem itself |

### Differentiators (Competitive Advantage)

Features that set the product apart from the low-effort single-poem Burda apps currently on the store. Not required for v1, but this is where BurdahApp can clearly outclass existing competitors.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Premium, cohesive visual design (Turkish/Ghazali geometric motif, calligraphic type, turquoise/gold/burgundy palette) | Every existing Burda app reviewed is visually generic/low-effort (default Android UI, ad banners breaking immersion); a genuinely beautiful, reverent design is the single biggest gap in this niche today | MEDIUM–HIGH | Already the stated core differentiator in PROJECT.md — this *is* the product's positioning, not a nice-to-have |
| Animated, ritual-feeling splash (Bismillah + audio) | No competitor app reviewed does anything beyond a static logo splash; a short devotional audio+animation moment sets tone before the user even reaches content | MEDIUM | Already in PROJECT.md scope; keep short (6.1s) so it never feels like it's delaying the user |
| Extensible multi-Burdah architecture (collection, not single poem) | Nearly all existing competitors are single-poem, single-purpose apps; Rekhta shows the payoff of designing for a *growing collection* from day one (categorization, browsing, curated lists) | MEDIUM | Already in PROJECT.md scope ("Architecture extensible for adding more burdahs"). Design the data model (list of burdah metadata → PDF asset) now even though only one entry ships in v1 |
| Curated burdah list/browsing UI | As the collection grows, a well-designed list (title, author, maybe short description) becomes a differentiator vs. competitors that hard-code a single poem with no navigation | LOW (for v1, one entry) → MEDIUM (later, at scale) | Build the list screen now for 1 item; it's the seam that lets future burdahs slot in without redesign |
| Night/reading-mode theme tuned for the app's palette | Competitor Burda apps mostly ignore this; Quran apps do it well. A dedicated dark reading theme increases comfortable reading time (evening/night devotional reading is common) | MEDIUM | Deferred per PROJECT.md's lean v1 scope — flag as a natural v1.x add, not core MVP |
| Audio recitation of the Burdah itself (distinct from the splash Fatiha clip) | Existing Burda apps almost universally include recitation audio paired with text — this is close to expected in the category, but PROJECT.md explicitly defers it | HIGH (sourcing/timing correct recitation audio per poem, per-page or per-verse sync) | Explicitly out of scope for v1 per PROJECT.md. Correctly deferred — recitation-sync is a large scope increase; revisit once the reading experience itself is validated |

### Anti-Features (Commonly Requested, Often Problematic)

Features that seem good but create problems in this specific domain — sacred/devotional reading content.

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|------------------|-------------|
| Ads / interstitials (even "just for monetization") | Free apps commonly monetize this way; seems like an easy revenue path | Direct, repeatedly-cited top complaint against the category leader (Muslim Pro): "very distracting," ads appearing over devotional content, even inappropriate ad content causing brand controversy. Breaks the "reverent, distraction-free" core value stated in PROJECT.md | No monetization in v1 (matches PROJECT.md Out of Scope); if monetization is needed later, prefer one-time purchase or optional donation, never interruptive ads |
| Feature-creep "do everything" Islamic super-app (prayer times, qibla, hadith-of-the-day, calendar, community chat) | Muslim Pro's popularity suggests bundling everything drives downloads | Directly cited as making the UI "busy" and "trying to do too much" — dilutes the specific reverent-reading experience that is this app's actual value proposition | Stay single-purpose: Burdah reading only. This matches the PROJECT.md Core Value statement exactly |
| Text extraction from PDF for reflow/searchability | Seems like an obvious UX win (searchable, resizable text, accessibility) | PROJECT.md already flags this as "accuracy uncertain" — Arabic OCR/extraction of calligraphic religious text risks introducing transcription errors into sacred text, which is far worse than a minor UX limitation | Keep PDF-of-original as source of truth (current decision); revisit text-layer/search only with a verified, scholar-reviewed transcription pipeline, not automated OCR |
| Social sharing / social feed features (seen in Rekhta) | Rekhta's poetry-app audience uses sharing heavily; seems like free growth/virality | Devotional/sacred-text sharing carries higher risk of decontextualized or disrespectful use (screenshots taken out of context, meme-ification); also adds scope not requested | Not in v1. If ever added, keep minimal (e.g., share the poem's title/attribution + link to the app, not out-of-context verse snippets) |
| User accounts / cloud sync / login | Common pattern once bookmarking or cross-device continuity is desired | PROJECT.md explicitly scopes this out; for a single-poem v1 there is no meaningful state to sync, and auth adds real backend complexity for near-zero v1 value | Defer indefinitely; if bookmarking is added later, use local device storage first before considering accounts |
| In-app purchases / premium tiers | Muslim Pro's freemium model is a well-known pattern in this space | PROJECT.md explicitly scopes this out; freemium "paywall the free stuff" pattern is also directly cited as a user complaint against category leaders | None needed for a free, single-purpose reading app |
| Bookmarking/highlighting in v1 | Standard in every mature reading app (Quran apps, Rekhta) | PROJECT.md explicitly defers this — reasonable for v1 given there's currently only one poem to bookmark within; low value until the collection grows | Revisit as a v1.x feature once multiple burdahs exist and "jump back to where I was" becomes meaningful |

## Feature Dependencies

```
Extensible burdah list/data model
    └──requires──> Burdah metadata schema (title, author, PDF asset path)
                       └──enables──> Adding future burdahs without code changes

PDF page-by-page viewer
    └──requires──> Bundled PDF asset per burdah
    └──enhances──> Pinch-to-zoom (same viewer surface)

Splash animation + audio
    └──independent of── Burdah list / reader (sequential, not dependent)

Night/reading-mode theme (v1.x)
    └──enhances──> PDF viewer (theming layer around the PDF surface, not PDF content itself)

Audio recitation of burdah text (v1.x/v2, deferred)
    └──requires──> Per-page or per-verse audio segmentation
                       └──requires──> Sourced/licensed recitation audio per burdah
    └──conflicts with── "ship lean v1" goal if pulled forward — large scope increase

Bookmarking (v1.x, deferred)
    └──enhances──> Burdah list (more valuable once >1 burdah exists)
    └──requires──> Local persistence (no accounts needed)

Text extraction/search (future, deferred)
    └──conflicts with── PDF-of-original accuracy guarantee unless verified transcription exists
```

### Dependency Notes

- **Extensible burdah list requires a metadata schema:** This must be designed in the *first* implementation phase even though only one burdah ships, because retrofitting a "list of one hard-coded item" into a real collection later is exactly the kind of rework PROJECT.md's "Architecture extensible" constraint is meant to prevent.
- **Splash sequence is independent of the reader:** It can be built and polished in parallel with the burdah list/PDF viewer work; no shared state.
- **Night mode enhances but doesn't gate the PDF viewer:** It's a theming layer, so it's safe to defer without blocking the core reading experience.
- **Audio recitation conflicts with lean v1 scope:** Per-poem recitation audio (distinct from the splash clip) requires sourcing licensed reciter audio and syncing it to pages/verses — this is a meaningfully larger feature than anything else in v1 and is correctly deferred in PROJECT.md.
- **Text extraction conflicts with the accuracy guarantee:** Any future move to add searchable/reflowable text should be gated on a verified transcription (e.g., scholar-reviewed), not automated OCR, to avoid the exact risk PROJECT.md already flagged.

## MVP Definition

### Launch With (v1)

Minimum viable product — matches PROJECT.md's Active Requirements almost exactly; feature research confirms these are the right table-stakes + differentiators for launch, nothing more.

- [ ] Animated Bismillah splash with trimmed Al-Fatiha audio — sets reverent tone (differentiator, no competitor does this)
- [ ] Fade transition splash → main screen — polish expected of a premium reverent app
- [ ] Main screen with prominent "Burdah" entry point — lean, distraction-free (table stakes: fast path to content)
- [ ] Burdah list page (even with one entry) — the extensibility seam (differentiator groundwork)
- [ ] Burdah of Sayyida Khadija RA as first entry — the actual content (table stakes)
- [ ] Page-by-page PDF viewer with swipe navigation — table stakes, matches book-reading expectation
- [ ] Pinch-to-zoom on pages — table stakes, present in every competitor
- [ ] Islamic geometric design + calligraphic typography — the core differentiator vs. every existing low-effort Burda app
- [ ] RTL-correct handling wherever Arabic UI text appears — table stakes, credibility-critical
- [ ] Android + iOS from one Flutter codebase — platform requirement, not a feature but a launch gate

### Add After Validation (v1.x)

Features to add once the core reading experience is shipped and validated with real users.

- [ ] Night/reading-mode theme — add once users report reading in low light, or once the app has enough usage data to justify the design work
- [ ] Bookmarking / last-read-position — add once a second or third burdah ships and "where was I" becomes a real problem, not before
- [ ] Search within burdah text — only after a verified (non-OCR) transcription exists for at least one burdah; otherwise accuracy risk outweighs benefit

### Future Consideration (v2+)

Features to defer until the core collection and reading experience have product-market fit.

- [ ] Audio recitation per burdah (distinct from splash clip) — why defer: requires licensed reciter audio + verse/page-level sync, the single largest scope item in this domain; only worth it once the app has proven demand for reading Burdahs in-app
- [ ] Sharing individual verses/pages — why defer: risk of decontextualized use of sacred text; low priority vs. reading experience
- [ ] Multiple additional burdahs beyond Khadija RA — why defer to v2 rather than v1.x: each new burdah needs its own sourced/verified PDF; the *architecture* ships in v1, the *content expansion* is a rolling, ongoing effort rather than a single feature milestone

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|----------------------|----------|
| Accurate Arabic PDF content (Khadija RA burdah) | HIGH | LOW (already sourced) | P1 |
| Page-by-page swipe + pinch-zoom viewer | HIGH | MEDIUM | P1 |
| Islamic geometric design system + calligraphic type | HIGH | MEDIUM–HIGH | P1 |
| Animated Bismillah splash + audio | MEDIUM | MEDIUM | P1 |
| Extensible burdah list/data model | MEDIUM (now) / HIGH (later) | LOW | P1 |
| RTL correctness throughout | HIGH | MEDIUM | P1 |
| No ads / single-purpose scope | HIGH (retention/trust) | LOW (it's an absence) | P1 |
| Night/reading-mode theme | MEDIUM | MEDIUM | P2 |
| Bookmarking / last-read-position | MEDIUM | LOW–MEDIUM | P2 |
| Search within text | LOW (until >1 burdah, verified transcription) | MEDIUM–HIGH | P3 |
| Recitation audio per burdah | HIGH (long-term) | HIGH | P3 |
| Social sharing of verses | LOW | LOW–MEDIUM | P3 |

**Priority key:**
- P1: Must have for launch
- P2: Should have, add when possible
- P3: Nice to have, future consideration

## Competitor Feature Analysis

| Feature | Existing Burda apps (Qasida Burda Sharif, etc.) | Quran.com / mature Quran apps | Rekhta (poetry-collection app) | Our Approach |
|---------|--------------------------------------------------|-------------------------------|----------------------------------|--------------|
| Visual design quality | Low — generic Android UI, ad banners | High — clean, culturally appropriate | Medium-high — modern app polish | Differentiate hard here: Turkish/Ghazali geometric design is the core positioning |
| Text fidelity | Plain rendered text, zoomable | Multiple certified mushaf typesets | Multi-script (Urdu/Hindi/English) | PDF-of-original preserves exact calligraphy — stronger accuracy guarantee than either |
| Audio | Recitation + translation audio bundled | Multi-reciter, gapless, repeat | Ghazal audio/video | v1: splash-only audio; per-poem recitation deferred to v2 |
| Collection structure | Almost always single-poem apps | N/A (single unified text) | Rich categorization across many poems/forms | Build list/data-model for multi-burdah now, ship with 1 entry — sets up the differentiator Rekhta demonstrates at scale |
| Monetization/ads | Ad-supported, low production value | Quran.com ad-free; Muslim Pro ad-heavy (criticized) | Free with light ads | No ads, no IAP in v1 — matches PROJECT.md and avoids category's #1 complaint |
| Offline access | Yes (universal in category) | Yes | Partial (some content needs connectivity) | Fully offline — content is bundled, not fetched |
| Bookmarking | Present in most | Present, often with sync | Present | Deferred to v1.x — low value with a single-entry list today |

## Sources

- [Top 10 Quran Apps: Translation, Audio & Offline Support](https://bestforandroid.com/quran-apps/) — WEB/LOW confidence, cross-referenced against multiple app listings
- [Connected Quran Apps - Quran.com](https://quran.com/apps)
- [Al Quran (Tafsir & by Word) - App Store](https://apps.apple.com/us/app/al-quran-tafsir-by-word/id1437038111)
- [Top 5 Quran apps on iOS and Android : 2020 report - Tarteel](https://tarteel.ai/blog/top-5-quran-apps-on-ios-and-android---2020-report/)
- [Top 10 Quranic Apps - Quranica](https://quranica.com/articles/quranic-apps/)
- [Qasida Burda Sharif - Google Play](https://play.google.com/store/apps/details?id=net.alahazrat.qasidaburdasharif&hl=en_US)
- [Qasida Burda Sharif Al-Busiri - Google Play](https://play.google.com/store/apps/details?id=com.Qaseeda.Burda.Shareef.AlBurda.AlBusiri&hl=en)
- [Burda Baith - Google Play](https://play.google.com/store/apps/details?id=com.itwindow.basheer.burdabaith&hl=en_US&gl=US)
- [Qaseed Burda Shareef with URDU - Google Play](https://play.google.com/store/apps/details?id=com.PakApps.QaseedaBurda&hl=en)
- [Mastering Arabic Mobile App Design - Medium](https://medium.com/@omrankhleifat/arabic-app-aesthetics-navigating-the-sands-of-right-to-left-design-0b5a7c29fc31)
- [RTL Arabic Website Design Best Practices - Aivensoft](https://aivensoft.com/en/blog/rtl-arabic-website-design-guide)
- [Designing Mobile Apps for Arabic Speakers: RTL UI Guide](https://www.milaajbrandset.com/blog/rtl-mobile-app-design-arabic-users/)
- [Rekhta: World of Urdu poetry - App Store](https://apps.apple.com/us/app/rekhta-world-of-urdu-poetry/id1060422293)
- [Urdu Shayari & poetry | Rekhta - Google Play](https://play.google.com/store/apps/details?id=org.Rekhta&hl=en_US)
- [PDF Dark Mode: How to Read PDFs Comfortably at Night - Androxus](https://androxus.com/blogs/read-pdfs-comfortably-at-night)
- [From Zoom Struggles to Smooth Scrolls - Zacedo](https://www.zacedo.com/blog/from-zoom-struggles-to-smooth-scrolls-the-ultimate-mobile-pdf-makeover/)
- [Muslim Pro Reviews (2026) - JustUseApp](https://justuseapp.com/en/app/388389451/muslim-pro-quran-athan-azan/reviews)
- [Some of the ad banners seem inappropriate for a Muslim application - Muslim Pro Help Center](https://support.muslimpro.com/hc/en-us/articles/200184909-Some-of-the-ad-banners-seem-inappropriate-for-a-Muslim-application)
- [Best Muslim Apps 2026: Honest Review - FivePrayer](https://www.fiveprayer.app/blog/best-muslim-apps-2026)
- [Muslim Pro - AlternativeTo](https://alternativeto.net/software/muslim-pro--prayer-times-azan-quran-and-qibla/about)

**Confidence note:** All findings are from general web search (LOW-tier provider per `classify-confidence`), not official documentation or curated sources — appropriate for this domain since "features of Islamic reading apps" is a market/competitive-landscape question, not a technical-documentation question. Findings were cross-corroborated across 3+ independent app listings/reviews per claim where possible (e.g., "ad-related complaints" appears across JustUseApp reviews, Muslim Pro's own help center, and FivePrayer's comparison), which raises practical confidence above a single-source LOW despite the provider tier.

---
*Feature research for: Islamic reading/poetry app (Burdah poems)*
*Researched: 2026-07-24*
