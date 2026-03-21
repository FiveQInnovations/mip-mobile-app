---
status: done
area: ios-mip-app
phase: production
created: 2026-01-02
---

# Firebase Navigation Events (iOS): app_open, screen_view, content_view

## Context

The spec requires navigation-related analytics events. These help understand engagement and which content is most popular. This ticket is for the **native iOS app** (`ios-mip-app`); Android later.

## Tasks

- [x] Track `app_open` when the app becomes active / on cold start (as appropriate for Analytics)
- [x] Track `screen_view` on meaningful navigation (e.g. tab changes, pushed page context) with a stable screen name
- [x] Track `content_view` when a page or collection item is shown (include page UUID, title, type where available)
- [x] Wire logging into the SwiftUI navigation flow (e.g. `ContentView`, `TabPageView`, app lifecycle in `FFCIApp`)
- [x] Verify events in the Firebase console

## Notes

- Depends on ticket 028 (Firebase setup, iOS)
- Per spec: `app_open`, `screen_view`, `content_view`
- `content_view` should include page UUID, title, and type
- **Reporting:** For “what content is used,” prioritize **`content_view`** and the **`page_title`** parameter (plus `page_uuid` / `content_type` for joins and filters). `screen_view` supports navigation structure; `app_open` supports session/foregrounding.
- **React Native** tab/stack navigation is out of scope for this ticket

## Implementation (`ios-mip-app`)

- **`FFCI/Analytics/MipAnalytics.swift`** — `logAppOpen()`, `logScreenView(screenName:screenClass:)`, `logContentView(pageUuid:title:contentType:)` (custom params `page_uuid`, `page_title`, `content_type`).
- **`ContentView`** — `scenePhase == .active` → `app_open`.
- **`MainTabView`** — `screen_view` on first appear and on tab change: `home` or `tab/<menu_page_uuid>`; external-url tabs unchanged (no in-app screen).
- **`HomeView`** — `content_view` for home (`page_uuid` `__home__`, `content_type` `home`, title from `SiteMeta`).
- **`SearchView`** — `screen_view` `search` when the sheet appears.
- **`TabPageView`** — when page data loads, `screen_view` `page/<uuid>` plus `content_view` using `PageData.title` and `effectivePageType`; dedupes repeat payloads for the same uuid/title/type (e.g. stale-while-refresh).

**QA:** Verified in Firebase DebugView: `app_open`, `screen_view`, and `content_view` (including `page_title`, e.g. content drill-down).
