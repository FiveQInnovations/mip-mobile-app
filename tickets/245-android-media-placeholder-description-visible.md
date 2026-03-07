---
status: backlog
area: android-mip-app
phase: nice-to-have
created: 2026-03-06
---

# Hide Placeholder Description Text in Media Item Detail (Android)

## Context

In the Android Media tab, opening `Fixed Husbands` shows placeholder copy directly in the UI: `Write your description here...`.

This reads like authoring placeholder text rather than intentional user-facing content and reduces polish/credibility for production users.

## Goals

1. Prevent placeholder/fallback template strings from being displayed in media detail screens
2. Show description only when content is meaningful
3. Keep current behavior unchanged for valid, non-placeholder descriptions

## Acceptance Criteria

- [ ] Media detail screens do not show `Write your description here...` to users
- [ ] If description is blank/placeholder, description block is hidden (or replaced with intentional copy)
- [ ] Items with valid descriptions still render those descriptions
- [ ] No regressions to media player layout

## Notes

- Reproduction path:
  1. Open app
  2. Tap `Media`
  3. Tap `Fixed Husbands`
- Observed result: placeholder line appears below the player card.
- Comparison check: `God's Power Tools` shows normal metadata and does not exhibit the same placeholder copy.

## References

- Media detail UI: `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/screens/MediaDetailScreen.kt`
- Data model mapping: `android-mip-app/app/src/main/java/com/fiveq/ffci/data/api/ApiModels.kt`
