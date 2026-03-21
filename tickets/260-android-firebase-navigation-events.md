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
- [ ] Verify events in the Firebase console

## Notes

- Depends on ticket **259** (Android Firebase setup)
- Per spec: `app_open`, `screen_view`, `content_view`
- Align event names and parameters with iOS (029) where practical for reporting consistency

## References

- `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/navigation/NavGraph.kt`
- `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/screens/TabScreen.kt`
- `android-mip-app/app/src/main/java/com/fiveq/ffci/MainActivity.kt`
