---
status: done
area: ios-mip-app
phase: production
created: 2026-01-02
---

# Firebase External Link Event (iOS)

## Context

The spec requires tracking when users open external URLs (e.g. Safari). This helps show which external resources users use. This ticket is for **ios-mip-app**; Android later.

## Tasks

- [x] Track `external_link` when opening a URL outside the app (Safari / `openURL`)
- [x] Include link URL and context (page UUID, link label or href text when available)
- [x] Integrate in `HtmlContentView` link handling and any other external-link paths (e.g. menu tabs, featured/quick actions that use `openURL`)
- [x] Verify events in the Firebase console

## Implementation (ios-mip-app)

- `MipAnalytics.logExternalLink`: event `external_link` with `link_url`, `link_domain`, `link_source`, optional `page_uuid`, `page_title`, `link_label` (values truncated to 100 chars for Firebase limits).
- **Menu tabs** (`ContentView` / `MainTabView`): external tabs (e.g. Give) → `link_source=menu_tab`, `page_uuid` from menu item, `link_label` = tab label.
- **`HtmlContentView`**: passes current page uuid/title into coordinator; external / form opens log `link_source=html_content`.
- **Home featured & resources**: `Button` + `openURL` replaces `Link` so analytics run before open; `link_source` = `featured` / `quick_task`, `page_uuid` = `__home__`.

## QA

Verified in Firebase DebugView:

- **Give (external main tab)**: `external_link` with `link_source` = `menu_tab`, tab `link_label`, `page_uuid` from menu.
- **HTML / forms** (`html_content`): external opens from page body — `page_uuid` / `page_title` from current page context where applicable.
- **Home Featured / Resources**: `featured` and `quick_task` sources with `page_uuid` = `__home__` and card labels when present.

## Notes

- Depends on ticket 028 (Firebase setup, iOS)
- Per spec: `external_link`
- **React Native** `HTMLContentRenderer` / `Linking.openURL` is out of scope for this ticket
