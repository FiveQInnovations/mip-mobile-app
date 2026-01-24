---
status: done
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

## Implementation Notes

### Changes Made

1. **Dedicated Logo Section**: Created a separate logo section with light gray background (`#F8FAFC`) matching iOS app design
2. **Responsive Logo Sizing**: Logo size is now responsive - 60% of screen width, clamped between 200dp (min) and 280dp (max)
3. **Aspect Ratio**: Maintains 5:3 aspect ratio (200:120) matching iOS implementation
4. **Content Scaling**: Uses `ContentScale.Fit` (equivalent to `resizeMode="contain"`) for proper logo scaling
5. **Error Handling**: Uses `SubcomposeAsyncImage` with proper loading/error states:
   - Loading: Shows nothing (no red placeholder)
   - Error: Falls back to site title text
   - Success: Displays logo with proper scaling
6. **Header Cleanup**: Removed small logo from header, kept only search icon (matching iOS pattern)

### Technical Details

- Uses `LocalConfiguration.current` to get screen width for responsive sizing
- `remember` used to cache calculated logo dimensions
- Logo URL handling supports both absolute URLs and relative paths
- Proper fallback to site title if logo URL is null or fails to load
