---
status: in-progress
area: android-mip-app
phase: core
created: 2026-03-06
---

# Improve Hero Title Contrast Across Resource Subpages (Android)

## Context

Multiple content pages reached from Resources/Search show white hero-title text over very light hero backgrounds, making titles difficult to read.

This appears to be a systemic styling gap rather than a one-page issue. Some pages (for example `Our Story`) render acceptable contrast, while several resource pages do not.

## Goals

1. Apply a consistent hero treatment so title text remains readable across resource/content pages
2. Match website readability intent where hero text is visually separated from background imagery
3. Resolve the issue in a reusable way (shared CSS rules), not page-by-page overrides

## Acceptance Criteria

- [ ] Hero titles are readable across resource pages on Android
- [ ] Light-background hero sections receive a darkening overlay (or equivalent contrast treatment)
- [ ] White title text meets practical readability on all tested pages
- [ ] Fix is implemented in shared renderer styling and verified on multiple pages

## Notes

- Pages observed with low-contrast hero titles:
  - `What We Believe`
  - `Connect With Us`
  - `Chaplain Resources`
  - `FFC Chaplain Program`
  - `Chapter Resources`
  - `FAQ`
- Comparison page with acceptable contrast:
  - `Our Story`

## References

- Android HTML renderer: `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt`
- Related page-specific tickets:
  - `tickets/242-android-what-we-believe-hero-title-contrast.md`
  - `tickets/244-android-connect-hero-title-contrast.md`
