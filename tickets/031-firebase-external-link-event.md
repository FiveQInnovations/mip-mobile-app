---
status: backlog
area: rn-mip-app
created: 2026-01-02
---

# Firebase External Link Event

## Context
The spec requires tracking when users tap external links. This helps understand which external resources users find valuable.

## Tasks
- [ ] Track `external_link` event when opening URLs in browser
- [ ] Include link URL and context (page UUID, link text)
- [ ] Integrate event into HTMLContentRenderer external link handler
- [ ] Integrate event into any other external link handlers
- [ ] Test events appear in Firebase console

## Notes
- Depends on ticket 028 (Firebase setup)
- Per spec required event: `external_link`
- Currently HTMLContentRenderer opens external links via Linking.openURL
