---
status: backlog
area: ios-mip-app
phase: production
created: 2026-01-02
---

# Firebase Navigation Events (iOS): app_open, screen_view, content_view

## Context

The spec requires navigation-related analytics events. These help understand engagement and which content is most popular. This ticket is for the **native iOS app** (`ios-mip-app`); Android later.

## Tasks

- [ ] Track `app_open` when the app becomes active / on cold start (as appropriate for Analytics)
- [ ] Track `screen_view` on meaningful navigation (e.g. tab changes, pushed page context) with a stable screen name
- [ ] Track `content_view` when a page or collection item is shown (include page UUID, title, type where available)
- [ ] Wire logging into the SwiftUI navigation flow (e.g. `ContentView`, `TabPageView`, app lifecycle in `FFCIApp`)
- [ ] Verify events in the Firebase console

## Notes

- Depends on ticket 028 (Firebase setup, iOS)
- Per spec: `app_open`, `screen_view`, `content_view`
- `content_view` should include page UUID, title, and type
- **React Native** tab/stack navigation is out of scope for this ticket
