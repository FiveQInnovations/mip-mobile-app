---
status: backlog
area: rn-mip-app
phase: core
created: 2026-01-26
---

# Homepage Logo Should Appear on Homescreen

## Context

The main Firefighters for Christ logo should be visible on the homescreen, but it is currently not appearing. This is the large logo that should be displayed in the logo section of the homepage, separate from the small Maltese cross in the header.

## Goals

1. Ensure the main homepage logo appears and is visible on the homescreen
2. Verify logo is properly loaded and rendered
3. Maintain proper sizing and positioning

## Acceptance Criteria

- Main Firefighters for Christ logo is visible on the homescreen
- Logo appears in the expected location (logo section area)
- Logo loads correctly from the API/CMS
- Logo displays properly on both iOS and Android

## Notes

- This is separate from the small Maltese cross that should appear in the header (ticket 217)
- Logo should be loaded from `site_data.logo` field via API
- Check if logo URL is being fetched correctly
- Verify logo rendering logic (SVG vs raster image handling)

## References

- Related: [071](071-homepage-logo-smaller.md) - Homepage Logo Size (already completed)
- Related: [217](217-header-maltese-cross-appear.md) - Small Maltese Cross in Header
