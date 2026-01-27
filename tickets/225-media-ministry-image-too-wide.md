---
status: backlog
area: rn-mip-app
phase: core
created: 2026-01-26
---

# Media Ministry Page - FFC's Monthly Media Embed Too Wide

## Context

On the "Media Ministry" page, the "FFC's Monthly Media" section displays an embedded view of another site (FFC Media website). The embedded content is too wide for the screen, causing items on the right side to be cut off and not fully visible. Users cannot see all media items without scrolling, and the right edge of the embedded content is truncated.

## Goals

1. Fix the width of the "FFC's Monthly Media" section to fit within the screen bounds
2. Ensure all media items are accessible and visible (either through proper sizing or horizontal scrolling)
3. Ensure navigation controls (scroll arrows) are fully visible

## Acceptance Criteria

- The "FFC's Monthly Media" section content fits within the screen width
- All media items in the carousel are accessible and can be viewed
- Horizontal scrolling works properly if needed to view all items
- Navigation arrows/controls are fully visible and functional
- No content is cut off at the right edge of the screen

## Notes

- The section is an embed of the FFC Media website, not a native component
- The embedded content appears to be a horizontal carousel with media items (audio messages)
- Each item shows speaker name, message title, and Play/Save buttons
- There's a left arrow navigation control visible, but right arrow may be cut off
- Some items show "← INVALID DATE" which may indicate additional data issues
- May need to adjust iframe/embed width constraints or implement responsive sizing for the embedded content

## References

- Screenshot: `/Users/anthony/.cursor/projects/Users-anthony-mip-mobile-app/assets/simulator_screenshot_457F9F30-2EF6-436D-BBD4-3A181F288EFF-1b31da3e-19ed-41f3-88c2-0ca8bfbadfd7.png`
