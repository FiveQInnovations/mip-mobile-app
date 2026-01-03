---
status: backlog
area: rn-mip-app
created: 2026-01-02
---

# Firebase Navigation Events (app_open, screen_view, content_view)

## Context
The spec requires tracking navigation-related analytics events. These help understand user engagement and which content is most popular.

## Tasks
- [ ] Track `app_open` event when app launches
- [ ] Track `screen_view` event on each navigation (with screen name)
- [ ] Track `content_view` event when page/item viewed (with page UUID, title, type)
- [ ] Integrate events into navigation flow (TabNavigator, page screens)
- [ ] Test events appear in Firebase console

## Notes
- Depends on ticket 028 (Firebase setup)
- Per spec required events: `app_open`, `screen_view`, `content_view`
- content_view should include page UUID, title, and type
