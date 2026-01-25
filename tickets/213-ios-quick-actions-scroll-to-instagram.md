---
status: backlog
area: ios-mip-app
phase: core
created: 2026-01-24
---

# iOS Quick Actions Right Arrow Should Scroll to Instagram

## Context

After fixing the Quick Actions order (ticket 212), the horizontal scrolling right arrow should be able to scroll all the way to Instagram at the end of the list.

## Problem

The right scroll arrow may not be calculating the scroll position correctly to reach the last card (Instagram) when it's properly positioned as the last item.

## Goals

1. Verify right arrow can scroll to the last Quick Action card (Instagram)
2. Ensure scroll position calculation accounts for all cards including the last one
3. Right arrow should disappear when scrolled to the end

## Acceptance Criteria

- Right arrow appears when not at the end of the scroll
- Right arrow can scroll to Instagram (last card)
- Right arrow disappears when scrolled to Instagram
- Left arrow appears when scrolled past the first card
- Scroll animation is smooth and reaches the end position correctly

## Related Files

- `ios-mip-app/FFCI/Views/ResourcesScrollView.swift` (scroll tracking logic)
- `ios-mip-app/FFCI/Views/HomeView.swift`

## Dependencies

- Ticket 212 must be completed first (Instagram must be last item)

## Notes

- Current scroll tracking uses `ScrollTracker` class
- Scroll position calculation may need adjustment for the last card
- Anchor point for last card scroll uses `.trailing` (line 106 in ResourcesScrollView.swift)
