---
status: backlog
area: android-mip-app
phase: production
created: 2026-03-21
---

# Firebase Navigation Events (Android): app_open, screen_view, content_view

## Context

The spec requires navigation-related analytics events. This ticket implements them in **android-mip-app**, parallel to ticket 029 (iOS).

## Tasks

- [ ] Track `app_open` on cold start / process start (per Firebase / product guidance)
- [ ] Track `screen_view` on meaningful navigation (tabs, major destinations) with stable screen names
- [ ] Track `content_view` when a page or collection item is shown (page UUID, title, type when available)
- [ ] Wire into Compose navigation (`NavGraph`, `TabScreen`, `MainActivity`) without blocking the UI thread
- [ ] Set Android Firebase debug mode on the emulator with `adb shell setprop debug.firebase.analytics.app com.subsplashconsulting.s_F52C3B`
- [ ] Verify `app_open`, `screen_view`, and `content_view` appear in GA4/Firebase DebugView from an emulator session
- [ ] Verify GA4 Realtime shows an Android user/session after navigating through the app

## Notes

- Depends on ticket **259** (Android Firebase setup)
- Per spec: `app_open`, `screen_view`, `content_view`
- Align event names and parameters with iOS (029) where practical for reporting consistency
- Use the transferred production package name `com.subsplashconsulting.s_F52C3B`

## Acceptance Criteria

- Launching the Android app on the emulator produces an `app_open` event visible in GA4/Firebase DebugView.
- Navigating Home, Partnerships, Media, Connect, Give, and Search produces stable `screen_view` events visible in DebugView.
- Opening at least one content page or media detail produces a `content_view` event visible in DebugView with useful parameters such as title, UUID, type, or route where available.
- GA4 Realtime shows at least one Android user/session for the FFCI property during verification.
- Verification evidence is captured in the ticket or release notes with event names observed and the tested build/version.

## References

- `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/navigation/NavGraph.kt`
- `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/screens/TabScreen.kt`
- `android-mip-app/app/src/main/java/com/fiveq/ffci/MainActivity.kt`
