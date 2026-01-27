---
status: backlog
area: ios-mip-app
phase: core
created: 2026-01-26
---

# Remove Duplicate Title on Content Pages

## Context

Content pages currently display the page title twice:
1. In the navigation bar (via `.navigationTitle()`)
2. As a large title in the content area (via `Text()` with `.font(.title)`)

This creates visual redundancy and wastes vertical screen space. The title should appear only once.

## Goals

1. Remove the duplicate title from the content area
2. Keep the title in the navigation bar (standard iOS pattern)
3. Improve screen space utilization

## Acceptance Criteria

- Page title appears only once (in the navigation bar)
- Large title text is removed from the content area (lines 48-52 in `TabPageView.swift`)
- Navigation bar title remains functional and visible
- Content area starts directly with HTML content or other page elements
- Visual spacing is adjusted appropriately after title removal

## Notes

- **Decision:** Keep navigation bar title, remove content area title
  - Navigation bar title is standard iOS pattern
  - Saves vertical screen space
  - Provides consistent navigation context
  - Title remains visible when scrolling content
  
- Current implementation in `ios-mip-app/FFCI/Views/TabPageView.swift`:
  - Lines 48-52: Large title in content (`Text(pageData.title)` with `.font(.title)`)
  - Lines 92-93: Navigation bar title (`.navigationTitle(pageData.title)`)

- After removal, content area should start with:
  - HTML content (if present)
  - Or other page elements (audio player, collection children, etc.)
  - Padding/spacing may need adjustment after removing title padding

## References

- Implementation: `ios-mip-app/FFCI/Views/TabPageView.swift` (lines 48-52, 92-93)
