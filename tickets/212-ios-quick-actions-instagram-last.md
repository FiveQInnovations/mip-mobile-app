---
status: backlog
area: ios-mip-app
phase: core
created: 2026-01-24
---

# iOS Quick Actions Should Show Instagram Last, Not Facebook

## Context

The Quick Actions (Resources) section on the home screen should display Instagram as the last item, but currently shows Facebook instead. The user has verified in the Kirby panel that both Facebook and Instagram exist, and both point to the same Kirby page (Privacy Policy).

## Problem

The Quick Actions list is not displaying Instagram as the last item. Facebook appears last instead of Instagram.

## Goals

1. Ensure Instagram appears as the last Quick Action card
2. Verify the order matches what's configured in Kirby panel
3. Fix any data ordering issues from the API

## Acceptance Criteria

- Instagram Quick Action card appears last in the horizontal scroll
- Facebook appears before Instagram (not last)
- Order matches Kirby panel configuration
- All Quick Actions are still visible and functional

## Related Files

- `ios-mip-app/FFCI/Views/ResourcesScrollView.swift`
- `ios-mip-app/FFCI/Views/HomeView.swift`
- API endpoint that provides `homepageQuickTasks` data

## Notes

- User verified in Kirby panel that both Facebook and Instagram exist
- Both currently point to the same Kirby page (Privacy Policy)
- May be an API ordering issue or data mapping problem
- After fixing, verify horizontal scrolling works correctly (see ticket 213)
