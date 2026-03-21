---
status: backlog
area: ios-mip-app
phase: production
created: 2026-01-02
---

# Firebase External Link Event (iOS)

## Context

The spec requires tracking when users open external URLs (e.g. Safari). This helps show which external resources users use. This ticket is for **ios-mip-app**; Android later.

## Tasks

- [ ] Track `external_link` when opening a URL outside the app (Safari / `openURL`)
- [ ] Include link URL and context (page UUID, link label or href text when available)
- [ ] Integrate in `HtmlContentView` link handling and any other external-link paths (e.g. menu tabs, featured/quick actions that use `openURL`)
- [ ] Verify events in the Firebase console

## Notes

- Depends on ticket 028 (Firebase setup, iOS)
- Per spec: `external_link`
- **React Native** `HTMLContentRenderer` / `Linking.openURL` is out of scope for this ticket
