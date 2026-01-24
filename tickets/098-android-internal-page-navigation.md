---
status: backlog
area: android-mip-app
phase: core
created: 2026-01-24
---

# Android Internal Page Navigation

## Context

Internal pages may contain buttons or links that should navigate to other internal pages within the app. Currently, tapping these elements may not work or may open external browser instead of in-app navigation.

## Goals

1. Buttons on internal pages should navigate to other internal pages
2. Internal links should use in-app navigation, not external browser
3. External links should still open in browser appropriately

## Acceptance Criteria

- Tapping a button/link to an internal page navigates within the app
- URL-to-route mapping works correctly (e.g., `/about` → About page)
- External links (https://external-site.com) open in browser
- Deep linking support (if applicable)

## Notes

- Requires URL parsing to determine internal vs external
- May need UUID-to-URL mapping from API
- RN implementation had similar challenges (ticket 052)

## References

- Previous tickets: 051 (external links), 052 (internal link mapping), 076 (subpage links)
- `wsp-mobile` API provides page UUID and URL information
