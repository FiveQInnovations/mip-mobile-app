---
status: backlog
area: ios-mip-app
phase: core
created: 2026-01-24
---

# iOS Quick Actions External Links Should Open in Browser

## Context

The Quick Actions (Resources) section on the home screen includes items like "Peace With God" and "Facebook" that have external URLs. These should open in the device's browser (Safari) rather than navigating within the app.

## Problem

Currently, external links in Quick Actions may not be properly detected or handled, causing them to either fail or navigate incorrectly.

## Goals

1. Ensure external links in Quick Actions open in Safari browser
2. Verify "Peace With God" opens its external link correctly
3. Verify "Facebook" opens its external link correctly

## Acceptance Criteria

- Tapping "Peace With God" Quick Action opens its external URL in Safari
- Tapping "Facebook" Quick Action opens its external URL in Safari
- External links are properly detected and handled differently from internal page navigation
- Internal links (UUID-based) continue to navigate within the app

## Related Files

- `ios-mip-app/FFCI/Views/ResourcesScrollView.swift` (lines 49-52 handle external links)
- `ios-mip-app/FFCI/Views/ResourcesCard.swift`
- `ios-mip-app/FFCI/Views/HomeView.swift`

## Notes

- Current implementation uses `Link` component for external URLs (line 50 in ResourcesScrollView.swift)
- May need to verify how external URLs are detected vs internal UUIDs
- Check if `task.externalUrl` is properly populated from API
