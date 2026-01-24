---
status: backlog
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
