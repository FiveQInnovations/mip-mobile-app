---
status: backlog
area: android-mip-app
phase: core
created: 2026-03-06
---

# Improve Hero Title Contrast on "What We Believe" (Android)

## Context

On the Android app's "What We Believe" page, the hero title text is difficult to read because the text color and image treatment do not provide enough contrast.

The website version is more legible because the title is white and the hero image is visibly darker behind the text. Android should match this behavior so the page heading is readable at a glance and visually consistent with the web source of truth.

## Goals

1. Make the hero title clearly readable on Android
2. Match website behavior for title color and image darkening
3. Keep the update scoped to hero/header readability (no unrelated style changes)

## Acceptance Criteria

- [ ] The "What We Believe" hero title is easy to read in normal viewing conditions
- [ ] Hero title uses white (or equivalent high-contrast) text on Android
- [ ] Hero image has a darker overlay/treatment behind title text
- [ ] Visual result aligns with website behavior for the same page
- [ ] No regressions to other content page headings after the change

## Notes

- The issue appears in Android emulator screenshots where the page title blends into the hero image.
- Comparison screenshot from the website shows stronger contrast and better readability.
- Likely implementation area is Android WebView HTML/CSS styling for background/hero blocks.

## References

- Android renderer: `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt`
- Related page ticket: `tickets/221-what-we-believe-images-not-appearing.md`
- Related styling ticket: `tickets/206-android-pdf-list-styling.md`
- Evidence screenshot (Android): `quiver-slack-app.png`
- Evidence screenshot (Web): `/Users/anthony/.cursor/projects/Users-anthony-mip-mobile-app/assets/Screenshot_2026-03-06_at_10.15.00_PM-6ee6f225-0dd5-4a63-91d0-01ff31fc4adb.png`
