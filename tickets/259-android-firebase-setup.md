---
status: backlog
area: android-mip-app
phase: production
created: 2026-03-21
---

# Firebase Analytics Setup (Android)

## Context

The spec requires Firebase Analytics. Each site may need its own Firebase configuration. This ticket covers the **native Android app** (`android-mip-app`), parallel to ticket 028 (iOS).

## Tasks

- [ ] Use the same Firebase/GA4 property as iOS and add or select the Android app with package name `com.subsplashconsulting.s_F52C3B`
- [ ] Download `google-services.json` and place it under `android-mip-app/app/`
- [ ] Apply Google services Gradle plugin and add Firebase Analytics dependency (Firebase BOM recommended)
- [ ] Initialize Firebase in `MipApplication` / `Application` onCreate if required by chosen SDK version
- [ ] Confirm Debug and Release builds pick up the correct Firebase config for `com.subsplashconsulting.s_F52C3B`
- [ ] Set Android Firebase debug mode on the emulator with `adb shell setprop debug.firebase.analytics.app com.subsplashconsulting.s_F52C3B`
- [ ] Verify the app appears in Firebase/GA4 DebugView from an emulator session
- [ ] Verify at least one Android realtime user appears in GA4 Realtime after launching the debug build

## Notes

- Depends conceptually on the same Firebase project decisions as ticket 028 (iOS)
- Per spec: Firebase Analytics is required for production
- This app is now releasing into the transferred Google Play package `com.subsplashconsulting.s_F52C3B`; do not create Firebase config for the old package `com.fiveq.ffci`
- Config should be per-site when multi-site Android variants ship (see ticket 231)
- **React Native** (`rn-mip-app`) is out of scope

## Acceptance Criteria

- Debug and release Android builds succeed with Firebase Analytics installed.
- `google-services.json` is present at `android-mip-app/app/google-services.json` and corresponds to package `com.subsplashconsulting.s_F52C3B`.
- With Firebase debug mode enabled on an emulator, GA4/Firebase DebugView shows Android events from the FFCI app.
- GA4 Realtime shows an Android user/session after launching the emulator build.
- Play Console Advertising ID declaration and Data safety answers are updated to match the Firebase Analytics behavior before production submission.

## References

- `android-mip-app/app/build.gradle.kts`
- `android-mip-app/build.gradle.kts`
- `android-mip-app/app/src/main/java/com/fiveq/ffci/MipApplication.kt`
