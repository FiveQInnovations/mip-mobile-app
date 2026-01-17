---
status: in-progress
area: rn-mip-app
phase: core
created: 2026-01-16
---

# Make Subpage Links More Obvious

## Context

From the Jan 13, 2026 meeting with Anthony Elliott, subpage links on content pages (like the About page) need to be more visually obvious and tappable. Currently they need "a little bit of love" to make it clearer they are clickable.

## Goals

1. Improve visual design of subpage links
2. Make clickable elements more obvious to users
3. Enhance navigation experience on content pages

## Acceptance Criteria

- Subpage links are clearly identifiable as clickable
- Visual cues indicate tappable elements
- Improved user experience on content pages
- Links maintain accessibility standards
- Design is consistent across all content pages

## Notes

- This affects pages like About, Resources, etc.
- Low priority polish item
- Focus on visual hierarchy and interaction design

## References

- Meeting transcript: meetings/ffci-app-build-review-jan-13.md

---

## Research Findings (Scouted)

### Current Implementation Analysis

**Subpage links** refer to the HTML anchor tags (`<a>`) rendered within page content (like the About page), NOT the collection item cards. These are links embedded in the HTML content that navigate to child pages.

**Key Finding from Meeting Transcript (lines 673-689):**
> "Let's say I want to find a local chapter. Adam, I might need some design hints here too, but I need to make these, make it more noticeable that this is a page that you can click on."

**Current Implementation:**
- Links are rendered by `HTMLContentRenderer` component using `react-native-render-html` library
- Styling defined in `tagsStyles.a` object at `HTMLContentRenderer.tsx:272-278`
- Current link styles:
  - `color: primaryColor` (red - `#D9232A`)
  - `fontWeight: '600'`
  - `borderBottomWidth: 1`
  - `borderBottomColor: primaryColor`
  - `textDecorationLine: 'none'`
- Links are functional - tapping navigates correctly via `renderersProps.a.onPress` handler (lines 117-170)

**Problem:**
Links blend into the content too much. Users need clearer visual cues that these are tappable/clickable elements.

### Implementation Plan

1. **Enhance link styling in HTMLContentRenderer** (`rn-mip-app/components/HTMLContentRenderer.tsx:272-278`)
   - Add more prominent visual indicators (consider: background color, padding, chevron icon, or stronger borders)
   - Ensure adequate tap target size (min 44x44 for iOS)
   - Maintain brand consistency with config colors
   
2. **Test on actual content pages**
   - Verify changes on About page (uuid: `xhZj4ejQ65bRhrJg` per HomeScreen.tsx:93)
   - Check other pages with subpage links (Resources, Chapters, etc.)
   - Ensure external links vs internal links are distinguishable if needed

3. **Maintain accessibility**
   - Ensure color contrast meets WCAG standards
   - Test with VoiceOver/TalkBack screen readers
   - Links must be clearly identifiable as interactive elements

### Code Locations

| File | Lines | Purpose | Changes Needed? |
|------|-------|---------|-----------------|
| `rn-mip-app/components/HTMLContentRenderer.tsx` | 272-278 | Link styling (`tagsStyles.a`) | **YES** - Enhance visual design |
| `rn-mip-app/components/HTMLContentRenderer.tsx` | 117-170 | Link press handler (`renderersProps.a`) | NO - Works correctly |
| `rn-mip-app/components/HTMLContentRenderer.tsx` | 183-306 | All HTML tag styles | Reference for consistency |
| `rn-mip-app/components/PageScreen.tsx` | 55-99 | Page rendering (uses HTMLContentRenderer) | NO - Container only |
| `rn-mip-app/components/TabScreen.tsx` | 260-309 | Tab page rendering (uses HTMLContentRenderer) | NO - Container only |
| `rn-mip-app/components/HomeScreen.tsx` | 93 | About page UUID reference | NO - Reference only |

**Note:** This is NOT about the collection item cards (TabScreen.tsx:370-406), which already have good visual design with cards, borders, shadows, and chevrons.

### Variables/Data Reference

**Key Variables:**
- `config.primaryColor` - Red (`#D9232A`) - Current link color
- `config.secondaryColor` - Blue (`#024D91`) - Alternative color option
- `config.textColor` - Dark (`#0f172a`) - Body text color
- `tagsStyles.a` - Object containing link styles (line 272)
- `renderersProps.a.onPress` - Link tap handler function (line 118)

**HTML Rendering:**
- `react-native-render-html` library handles HTML-to-React Native conversion
- `tagsStyles` object defines styles for all HTML elements
- `renderers` object provides custom components for specific tags
- `renderersProps` object provides props/handlers for specific tags

### Design Considerations

**Possible Visual Enhancements:**
1. **Subtle background** - Add light background color (e.g., `backgroundColor: 'rgba(217, 35, 42, 0.08)'`)
2. **Increased padding** - Add horizontal/vertical padding for larger tap targets
3. **Rounded corners** - Add `borderRadius` for modern look
4. **Chevron/arrow icon** - Add trailing icon to indicate navigation (would require custom renderer)
5. **Stronger underline** - Increase `borderBottomWidth` from 1 to 2
6. **Different color scheme** - Use secondary color or darker shade
7. **Hover/press states** - Add visual feedback on interaction (may require custom component)

**Constraints:**
- Must work within `react-native-render-html` styling system
- Cannot add icons without creating custom renderer component
- Must maintain readability and not disrupt content flow
- Should work for both light and dark content backgrounds

### Estimated Complexity

**Low-Medium Complexity**

**Rationale:**
- Single file change (`HTMLContentRenderer.tsx`)
- Styling-only modification (no logic changes)
- No new components needed (unless adding icons)
- Link handler already works correctly
- Main challenge is finding the right visual balance

**Time Estimate:**
- Simple styling changes: 30-60 minutes
- With icon/custom renderer: 2-3 hours
- Testing on multiple pages: 30 minutes
- Total: 1-3.5 hours depending on approach

**Risks:**
- Low - Isolated change, easy to revert
- Styling may need iteration to get visual balance right
- Must ensure changes don't break external link styling