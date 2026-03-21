---
status: qa
area: android-mip-app
phase: nice-to-have
created: 2026-03-06
---

# Hide Kirby default description on media detail (Android)

## Context

On media (audio) item pages, `page_content` sometimes contains only Kirby’s default block copy: `Write your description here...`. That is meant for editors in the Panel, not end users.

## Goals

1. Do not render description HTML when visible text is only that placeholder.
2. When the CMS provides real copy in `page_content`, show it unchanged.
3. Avoid layout regressions around the audio player and surrounding content.

## Acceptance Criteria

- [x] If stripped visible text is only `Write your description here...` (ASCII or Unicode ellipsis), the description block is not shown.
- [x] Items with real `page_content` still render that HTML in the body below the player.
- [x] No regressions to media player layout.

## Implementation

- `PageData.htmlContentForDisplay()` in `android-mip-app/.../ui/util/PageHtmlContent.kt` — converts HTML to plain text for comparison, then returns `null` when it matches the placeholder (case-insensitive, whitespace normalized).
- `TabScreen` uses `htmlContentForDisplay()` instead of raw `htmlContent` when composing `HtmlContent`.

## Notes

- Reproduction path (before fix):
  1. Open app → **Media** → **Fixed Husbands**
  2. Placeholder line appeared under the player when only default description was set.
- Comparison: **God's Power Tools** (or any item with real body copy) should still show description.

## References

- `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/screens/TabScreen.kt`
- `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/util/PageHtmlContent.kt`
- `android-mip-app/app/src/main/java/com/fiveq/ffci/data/api/ApiModels.kt` (`PageData.htmlContent`)
