---
status: backlog
area: ios-mip-app
phase: core
created: 2026-01-24
---

# iOS About Us Page Shows Double Chevron in Back Button

## Context

When navigating to the "About Us" page, the back button displays incorrectly with an extra left chevron - one before the word "Back" and one after.

## Problem

The custom back button implementation in `TabPageView` is showing alongside SwiftUI's default back button, resulting in duplicate chevrons.

## Goals

1. Remove duplicate chevron from back button
2. Ensure only one back button appears (either custom or default)
3. Fix navigation bar appearance for About Us and similar pages

## Acceptance Criteria

- Back button shows only one chevron (not two)
- Back button text/label is correct
- Navigation works correctly when tapping back
- No visual artifacts or duplicate UI elements

## Related Files

- `ios-mip-app/FFCI/Views/TabPageView.swift` (lines 94-103 - custom back button)
- `ios-mip-app/FFCI/Views/HomeView.swift` (navigation stack setup)

## Notes

- Custom back button is added via `ToolbarItem` with `chevron.left` icon (line 98)
- SwiftUI may be showing default back button alongside custom one
- May need to hide default back button using `navigationBarBackButtonHidden(true)` or adjust toolbar configuration
- Check if About Us is navigated to differently than other pages (e.g., from Quick Actions vs tab)
