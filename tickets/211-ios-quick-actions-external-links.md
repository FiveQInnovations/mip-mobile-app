---
status: done
area: ios-mip-app
phase: core
created: 2026-01-24
---

# iOS Quick Actions External Links Should Open in Browser

## Context

The Quick Actions (Resources) section on the home screen includes items like "Peace With God" and "Facebook" that have external URLs. These should open in the device's browser (Safari) rather than navigating within the app.

## Problem

Items with BOTH `uuid` AND `externalUrl` were navigating internally because the code checked `uuid` first. If a uuid existed, it used `NavigationLink` even if an external URL was also present.

## Solution

Swapped the conditional order to check `externalUrl` BEFORE `uuid` in both:
- `ResourcesScrollView.swift` (Resources/Quick Tasks section)
- `FeaturedSectionView.swift` (Featured section - same bug pattern)

Now items with external URLs correctly use SwiftUI's `Link` component which opens Safari.

## Goals

1. ✅ Ensure external links in Quick Actions open in Safari browser
2. ✅ Verify "Peace With God" opens its external link correctly
3. ✅ Verify "Facebook" opens its external link correctly

## Acceptance Criteria

- ✅ Tapping "Peace With God" Quick Action opens its external URL in Safari
- ✅ Tapping "Facebook" Quick Action opens its external URL in Safari
- ✅ External links are properly detected and handled differently from internal page navigation
- ✅ Internal links (UUID-based only) continue to navigate within the app
- ✅ Maestro test passes

## Files Modified

- `ios-mip-app/FFCI/Views/ResourcesScrollView.swift` - swapped condition order (externalUrl first)
- `ios-mip-app/FFCI/Views/FeaturedSectionView.swift` - swapped condition order (externalUrl first)

## Files Created

- `ios-mip-app/maestro/flows/ticket-211-external-links-ios.yaml` - Maestro test

## Test Results

Maestro test verified that tapping a card with externalUrl now opens Safari (biblegateway.com) instead of navigating internally.

## Notes

- The `Link` component in SwiftUI correctly opens URLs in Safari
- Both Featured and Resources sections had the same bug pattern - both fixed
- Maestro screenshots confirm Safari opens after tap (shows biblegateway.com URL)
