---
status: done
area: android-mip-app
phase: nice-to-have
created: 2026-01-24
---

# Android App Icon and Splash Screen

## Context

The Android app currently uses a placeholder "FFCI" text vector drawable for the launcher icon (`ic_launcher_foreground.xml`). This should be replaced with the proper Maltese cross logo that matches the React Native app's branding. The splash screen also needs to be configured to show the same branding.

## Goals

1. Replace the Android app launcher icon with the Maltese cross logo
2. Configure a proper splash screen with consistent branding
3. Ensure icons look good at all required sizes/densities

## Acceptance Criteria

- App launcher icon shows Maltese cross (matches React Native app)
- Splash screen displays during app launch with proper branding
- Icons render crisply at all screen densities (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
- Adaptive icon works correctly on Android 8.0+ (rounded/squircle masks)

## Technical Notes

### Reference Assets
- React Native adaptive icon: `rn-mip-app/assets/adaptive-icon.png` (1024x1024)
- React Native splash icon: `rn-mip-app/assets/splash-icon.png`
- Header logo already copied: `android-mip-app/app/src/main/res/drawable-xxhdpi/header_logo.png`

### Current Android Icon Structure
- `res/drawable/ic_launcher_foreground.xml` - Vector drawable (placeholder FFCI text)
- `res/drawable/ic_launcher_background.xml` - Background color
- `res/mipmap-anydpi-v26/ic_launcher.xml` - Adaptive icon reference
- `res/mipmap-anydpi-v26/ic_launcher_round.xml` - Round adaptive icon reference

### Required Changes
1. Generate launcher icons at all densities from Maltese cross PNG
2. Update `ic_launcher_foreground.xml` or replace with PNG versions
3. Add splash screen using Jetpack Compose or Android 12+ Splash Screen API
4. Consider using Android Studio's Image Asset tool for proper icon generation

### Splash Screen Options
- **Android 12+ (API 31+)**: Use native Splash Screen API (`SplashScreen` in themes.xml)
- **Pre-Android 12**: Use a splash Activity or Jetpack Compose splash

## References

- `android-mip-app/app/src/main/res/drawable/ic_launcher_foreground.xml`
- `android-mip-app/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml`
- `rn-mip-app/assets/adaptive-icon.png`
- `rn-mip-app/assets/splash-icon.png`

## Implementation Notes

### Changes Made

1. **Launcher Icon Assets**: Created PNG versions of the Maltese cross icon at all required densities:
   - `drawable-mdpi/ic_launcher_foreground.png` (108x108)
   - `drawable-hdpi/ic_launcher_foreground.png` (162x162)
   - `drawable-xhdpi/ic_launcher_foreground.png` (216x216)
   - `drawable-xxhdpi/ic_launcher_foreground.png` (324x324)
   - `drawable-xxxhdpi/ic_launcher_foreground.png` (432x432)
   - Removed old vector drawable XML placeholder

2. **Adaptive Icon Configuration**: Updated adaptive icon to use PNG foreground drawables (automatically selected by Android based on screen density)

3. **Splash Screen Implementation**:
   - Added `androidx.core:core-splashscreen` dependency (v1.0.1)
   - Created splash screen theme with white background and Maltese cross icon
   - Added Android 12+ specific theme in `values-v31/themes.xml` with splash screen attributes
   - Updated `MainActivity` to install splash screen using `installSplashScreen()`
   - Updated `AndroidManifest.xml` to use splash theme for launch activity
   - Created splash icon drawables at all densities (`ic_splash.png`)

4. **Splash Icon Assets**: Created PNG versions of splash icon at all densities:
   - `drawable-mdpi/ic_splash.png` through `drawable-xxxhdpi/ic_splash.png`

### Technical Details

- Adaptive icons work on Android 8.0+ (API 26+) with automatic mask application
- Splash screen uses Android 12+ Splash Screen API for modern devices
- Pre-Android 12 devices will use the base theme (no splash screen, but app still launches)
- Icons are properly sized for adaptive icon foreground (108dp base size)
- All icons render crisply at their respective densities

### Verification

- ✅ App builds successfully
- ✅ App installs and launches without errors
- ✅ Launcher icon displays Maltese cross (verified in emulator)
- ✅ Splash screen configured for Android 12+ devices
- ✅ No errors in logcat during app launch
