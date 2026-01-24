---
status: backlog
area: android-mip-app
phase: nice-to-have
created: 2026-01-24
---

# Android Home Screen Logo Polish

## Context

The home screen logo is now loading (SVG support and Basic Auth were fixed), but the presentation could be improved to better match the iOS React Native app's visual quality.

## Goals

1. Ensure logo displays at optimal size and position
2. Match the visual quality of the iOS app's logo presentation
3. Handle different logo aspect ratios gracefully

## Acceptance Criteria

- Logo appears crisp and properly sized on all screen densities
- Logo position matches iOS app design (centered, appropriate spacing)
- No red background placeholder visible when logo loads
- Graceful fallback if logo fails to load

## Notes

- Logo URL comes from `siteMeta.logo` in API response
- Currently using Coil with SVG decoder and Basic Auth
- See `MipApplication.kt` for Coil configuration

## References

- `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/screens/HomeScreen.kt`
- `android-mip-app/app/src/main/java/com/fiveq/ffci/MipApplication.kt`
