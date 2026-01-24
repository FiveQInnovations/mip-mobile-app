---
status: backlog
area: rn-mip-app
phase: core
created: 2026-01-23
---

# Connect Tab Routing Shows Chapters Content

## Context

During visual testing of ticket 084, it was discovered that tapping the Connect tab appears to navigate to Chapters content instead of Connect-specific content. The page displayed shows "Connect with an FFC Chapter" which seems to be Chapters tab content, not the expected Connect tab content.

## Current Behavior

- Tapping Connect tab shows content that appears to belong to Chapters
- Cannot verify Connect tab's active icon state due to this routing issue
- The "Connect with an FFC Chapter" page may be shared content or incorrect routing

## Goals

1. Investigate whether this is a routing bug or intentional content sharing
2. Ensure Connect tab displays the correct content
3. Verify Connect tab navigation works independently of Chapters tab

## Acceptance Criteria

- [ ] Connect tab shows Connect-specific content (not Chapters content)
- [ ] Connect tab navigation is independent from Chapters tab
- [ ] Tapping Connect while on Chapters doesn't appear to "do nothing"

## Technical Notes

Investigate:
- Menu configuration in Kirby CMS for Connect tab
- Tab routing in `TabNavigator.tsx`
- Whether Connect and Chapters share a page UUID
- API response for mobile menu to see what page is assigned to Connect tab

## References

- Discovered during: [084](084-icon-management-website.md) - Icon Management in Website
- Connect tab added in: [072](done/072-connect-tab-navigation.md) - Add "Connect" Tab
- Tab implementation: `rn-mip-app/components/TabNavigator.tsx`
