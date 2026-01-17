---
status: backlog
area: rn-mip-app
phase: core
created: 2026-01-16
---

# Fix Tab Bar - Reduce to 4 Tabs

## Context

From the Jan 13, 2026 meeting with Mike Bell, the bottom tab bar currently shows 5 items and is getting cut off on mobile devices. It should be reduced to 4 tabs maximum for better usability.

## Goals

1. Reduce bottom navigation to 4 tabs maximum
2. Ensure all tabs display properly on mobile devices
3. Maintain essential navigation functionality

## Acceptance Criteria

- Bottom tab bar shows exactly 4 tabs
- All tabs display fully without being cut off
- Suggested tabs: Home, Resources, Chapters, Connect
- Navigation remains functional
- Design maintains visual consistency

## Notes

- Current 5-tab layout causes display issues
- Connect tab replaces the previous Get Involved tab
- This is related to ticket 072 (Connect tab implementation)

## References

- Meeting transcript: meetings/ffci-app-build-review-jan-13.md