---
phase: 02
slug: reading-experience-pdf-viewer
status: verified
threats_open: 0
asvs_level: 1
created: 2026-07-26
---

# Phase 02 — Security

> Per-phase security contract: threat register, accepted risks, and audit trail.

---

## Trust Boundaries

| Boundary | Description | Data Crossing |
|----------|-------------|---------------|
| Asset bundle → PDFium native renderer | Bundled PDF file bytes cross from Flutter asset loader into native PDFium C++ parser for rasterization | Binary PDF data (developer-controlled, not user-supplied) |

---

## Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation | Status |
|-----------|----------|-----------|----------|-------------|------------|--------|
| T-02-01 | Denial of Service | PdfDocumentViewBuilder.asset / PdfPageView | low | mitigate | errorBuilder/loadingBuilder in pdf_page_swiper.dart — shows "Something's not right" on load failure instead of crashing | closed |
| T-02-02 | Tampering | pdfrx native PDFium bindings | low | accept | Native PDFium memory-safety vulnerabilities out of project control; mitigated upstream by staying current on pdfrx updates. Not exploitable via user input in v1 (only bundled asset loaded). | closed |
| T-02-SC | Tampering | flutter pub add pdfrx | low | mitigate | pdfrx 2.4.7 verified in RESEARCH.md Package Legitimacy Audit: publisher espresso3389.jp verified on pub.dev, MIT license, 336 likes / 160 pub points. | closed |

---

## Accepted Risks Log

| Risk ID | Threat Ref | Rationale | Accepted By | Date |
|---------|------------|-----------|-------------|------|
| AR-02-01 | T-02-02 | Native PDFium memory-safety is upstream-managed; no user-supplied PDF input in v1 scope | plan-time disposition | 2026-07-25 |

---

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
|------------|---------------|--------|------|--------|
| 2026-07-26 | 3 | 3 | 0 | Claude (L1 grep-depth, short-circuit) |

---

## Sign-Off

- [x] All threats have a disposition (mitigate / accept / transfer)
- [x] Accepted risks documented in Accepted Risks Log
- [x] `threats_open: 0` confirmed
- [x] `status: verified` set in frontmatter

**Approval:** verified 2026-07-26
