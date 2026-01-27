---
status: qa
area: ios-mip-app
phase: core
created: 2026-01-26
---

# Small Maltese Cross Should Appear on Left Side of Header

## Context

A small Maltese cross icon should appear on the left side of the header, but it is currently not visible. This is separate from the main homepage logo and should be a small icon in the persistent header.

## Goals

1. Ensure the small Maltese cross appears on the left side of the header
2. Verify proper positioning and sizing
3. Visual verification only (no testing required)

## Acceptance Criteria

- Small Maltese cross icon is visible on the left side of the header
- Icon is properly sized (small, not dominating the header)
- Icon appears consistently across all screens with the header

## Notes

- **No testing required** - visual check only
- This is separate from the main homepage logo (ticket 216)
- Related to ticket 070 which replaced header logo with Maltese Cross (already completed)
- Check if the icon asset is being loaded correctly
- Verify header component is rendering the icon

## Implementation Notes (from ticket 216 work)

### Reference Implementations

**Android (HomeScreen.kt line 91-99):**
- Uses local drawable resource: `R.drawable.header_logo` 
- Asset location: `drawable-xxhdpi/header_logo.png`
- Size: 32dp
- Positioned top-left in header
- Comment notes: "App icon (Maltese cross) top-left - matches RN assets/adaptive-icon.png"

**React Native (HomeScreen.tsx line 23-26):**
- Uses local asset: `require('../assets/adaptive-icon.png')`
- Positioned in header

**iOS Current State (HomeHeaderView.swift):**
- Currently displays API logo (`siteMeta.logo`) in header
- Should be replaced with local Maltese cross asset (similar to Android/RN)
- Main homepage logo (ticket 216) is now separate and loads from API URL

### Implementation Approach
- Replace API logo loading in `HomeHeaderView.swift` with local asset
- Use `Image` with `Image("header_logo")` or similar asset reference
- Size should match Android (32pt equivalent)
- Position top-left in header (opposite side from search button)

## References

- Related: [070](070-header-logo-maltese-cross.md) - Header Logo Replacement (already completed)
- Related: [216](216-homescreen-logo-appear.md) - Main Homepage Logo
