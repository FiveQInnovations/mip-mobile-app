---
status: backlog
area: android-mip-app
phase: core
created: 2026-03-06
---

# Improve Hero Title Contrast on `Connect With Us` (Android)

## Context

On the Android `Connect` tab, the hero section title (`Connect With Us`) is rendered in white over a very light image/background area, making it difficult to read.

This is the same readability class of issue seen on other pages where hero text does not reliably meet contrast expectations against dynamic imagery.

## Goals

1. Ensure `Connect With Us` hero title has strong text/background contrast
2. Apply the same visual treatment used on web (or equivalent) for readability
3. Avoid regressions to other Connect tab styling

## Acceptance Criteria

- [ ] `Connect With Us` hero title is clearly readable on Android
- [ ] Title color/overlay treatment provides consistent contrast over light imagery
- [ ] Result matches website readability intent for the same content
- [ ] No regressions to Connect tab layout and spacing

## Notes

- Reproduction path: Open app → tap `Connect` tab
- Observed behavior: hero text blends with light hero background
- Expected behavior: title remains legible at first glance, similar to website treatment

## References

- Android HTML/CSS renderer: `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt`
- Related contrast ticket: `tickets/242-android-what-we-believe-hero-title-contrast.md`
