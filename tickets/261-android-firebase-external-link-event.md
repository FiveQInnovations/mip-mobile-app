---
status: backlog
area: android-mip-app
phase: production
created: 2026-03-21
---

# Firebase External Link Event (Android)

## Context

The spec requires tracking when users open external URLs (browser / Custom Tabs / intent). This ticket implements **`external_link`** in **android-mip-app**, parallel to ticket 031 (iOS).

## Tasks

- [ ] Track `external_link` when launching an outbound URL (e.g. `Intent.ACTION_VIEW`, Custom Tabs)
- [ ] Include URL and context (page UUID, link text or href when available)
- [ ] Integrate in `HtmlContent` link handling and any other external-link paths (menu tabs, featured cards, etc.)
- [ ] Verify events in the Firebase console

## Notes

- Depends on ticket **259** (Android Firebase setup)
- Per spec: `external_link`
- Align parameters with iOS (031) where practical

## References

- `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt`
- `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/screens/HomeScreen.kt`
