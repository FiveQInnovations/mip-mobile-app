---
status: done
area: android-mip-app
phase: core
created: 2026-03-07
---

# Fix Media Ministry Iframe Not Rendering on Android

## Context

On the `Media Ministry` page, the app shows a very large blue content block where the website displays an embedded `firefighters.org` media frame.

The page source includes an iframe (`https://firefighters.org/motm`), but Android WebView currently does not render the expected embedded content in-app.

## Goals

1. Render the `FFC's Monthly Media` iframe content on Android
2. Keep embedded content responsive in narrow mobile layout
3. Avoid introducing regressions for other HTML content pages

## Acceptance Criteria

- [x] `Media Ministry` page displays iframe content instead of a blank/empty blue block
- [x] Embedded frame remains within viewport width on Android
- [x] No new crashes or severe WebView rendering regressions on related pages

## Notes

- Page URL: `https://ffci.fiveq.dev/resources/ffc-media-ministry`
- Embedded source observed in page HTML: `https://firefighters.org/motm`
- Existing related ticket: `tickets/225-media-ministry-embed-too-wide.md` (iOS-focused historical work)
- What changed:
  - In `HtmlContent.kt`, enabled WebView capabilities required by embedded sites (`domStorageEnabled`, mixed-content compatibility mode, third-party cookies).
  - Added responsive CSS for `iframe`, `embed`, and `object` so embeds render within app width.
- How I verified:
  - Built and installed Android debug app, then tested on emulator.
  - Reproduced path: Home -> Search -> `Media Ministry` -> top result.
  - Confirmed the previously blank blue block now shows live monthly media iframe content.
  - Captured proof screenshots:
    - `/tmp/android_media_ministry_top_after_fix.png`
    - `/tmp/android_media_ministry_mid_after_fix.png`

## References

- Android HTML renderer: `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt`
