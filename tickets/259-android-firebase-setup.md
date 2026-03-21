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

- [ ] Use the same Firebase project as iOS or add the Android app with package name `com.fiveq.ffci` (or as configured in `AndroidManifest.xml` / Gradle)
- [ ] Download `google-services.json` and place it under `android-mip-app/app/`
- [ ] Apply Google services Gradle plugin and add Firebase Analytics dependency (Firebase BOM recommended)
- [ ] Initialize Firebase in `MipApplication` / `Application` onCreate if required by chosen SDK version
- [ ] Confirm Release/Debug builds pick up the correct config for the active product flavor (if multi-site variants exist later)
- [ ] Verify builds succeed and sessions or debug events appear in the Firebase console

## Notes

- Depends conceptually on the same Firebase project decisions as ticket 028 (iOS)
- Per spec: Firebase Analytics is required for production
- Config should be per-site when multi-site Android variants ship (see ticket 231)
- **React Native** (`rn-mip-app`) is out of scope

## References

- `android-mip-app/app/build.gradle.kts`
- `android-mip-app/build.gradle.kts`
- `android-mip-app/app/src/main/java/com/fiveq/ffci/MipApplication.kt`
