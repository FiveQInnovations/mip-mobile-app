---
status: qa
area: rn-mip-app
phase: core
created: 2026-01-16
---

# Scrollable Cards - Add Scroll Indicators

## Context

From the Jan 13, 2026 meeting with Mike Bell, the horizontal scrollable cards in the Quick Tasks section look "awkward" with half a card showing. Visual cues are needed to indicate scrollability.

## Goals

1. Add visual indicators to show cards are scrollable
2. Improve user experience with horizontal scrolling
3. Make scrollable content more discoverable

## Acceptance Criteria

- Clear visual indicators show content is scrollable
- Options to implement:
  - Arrow indicators
  - Partial card visibility with proper styling
  - Other visual cues to indicate scrollability
- Cards maintain consistent sizing and spacing
- Improved user experience for horizontal scrolling

## Notes

- Currently looks "awkward" with half-card showing
- Blocked by design input from Adam Hardy
- May involve making cards same size as featured cards

## References

- Meeting transcript: meetings/ffci-app-build-review-jan-13.md

---

## Research Findings (Scouted)

### Current Implementation Analysis

The scrollable cards section (labeled "Resources" but formerly called "Quick Tasks") is implemented in `HomeScreen.tsx` using a horizontal `ScrollView` component.

**Key implementation details:**

1. **ScrollView Component** (lines 219-236 in `HomeScreen.tsx`)
   - Uses `horizontal` prop for horizontal scrolling
   - Has `showsHorizontalScrollIndicator={false}` which hides the native scroll indicator
   - Styled with `styles.horizontalScroll` and `styles.horizontalScrollContent`

2. **Card Styling** (lines 316-322 in `HomeScreen.tsx`)
   - Cards use `styles.carouselCard` which sets:
     - Fixed width: 280px
     - Right margin: 16px
     - Border: 1px solid #e2e8f0

3. **ContentCard Component** (`ContentCard.tsx`)
   - Self-contained card component with image, title, and description
   - Default card width is 280px (line 72)
   - Image container height: 158px (16:9 aspect ratio, line 75)
   - Includes shadow/elevation for depth

4. **Scroll Container Styling** (lines 312-315 in `HomeScreen.tsx`)
   - Horizontal padding: 16px on both sides
   - Extra padding-right: 8px for the last item
   - Results in partial visibility of next card (intentional but looks "awkward")

**The Problem:**
- The half-card showing at the end was intentional to indicate scrollability
- However, client feedback indicates it looks "awkward" and "not polished"
- Current implementation has NO visual indicators beyond the partial card visibility

### Implementation Plan

Based on meeting transcript (lines 723-755) and codebase analysis, here's the recommended approach:

**Option 1: Arrow Indicators (Recommended)**
1. Add left/right arrow overlays that appear when content is scrollable
2. Position arrows absolutely over the ScrollView edges
3. Use Ionicons (already imported) - `chevron-back` and `chevron-forward`
4. Show/hide arrows based on scroll position (hide left arrow at start, hide right arrow at end)
5. Style arrows with semi-transparent background for visibility

**Option 2: Adjust Card Sizing**
1. Make scrollable cards same size as featured cards (full width)
2. Use `snapToInterval` prop for smooth card-by-card scrolling
3. Add pagination dots below to indicate position

**Option 3: Hybrid Approach**
1. Keep current card sizing but add subtle fade gradient at edges
2. Add small chevron icons on the section header
3. Adjust padding to show more of the next card (e.g., 30% instead of 50%)

**Recommended: Option 1** - Provides clear visual affordance without requiring major layout changes.

### Code Locations

| File | Line Range | Purpose | Changes Needed |
|------|------------|---------|----------------|
| `rn-mip-app/components/HomeScreen.tsx` | 219-236 | ScrollView implementation | Add state for scroll position, arrow buttons |
| `rn-mip-app/components/HomeScreen.tsx` | 309-322 | Styles for horizontal scroll | Add arrow button styles |
| `rn-mip-app/components/HomeScreen.tsx` | 1, 9 | Imports | Already has Ionicons imported |
| `rn-mip-app/components/ContentCard.tsx` | 1-117 | Card component | No changes needed |

### Variables/Data Reference

**Key variables in scope:**
- `quickTasks` - Array of task items to display (line 138-149 in HomeScreen.tsx)
- `DEFAULT_QUICK_TASKS` - Fallback data (lines 87-112)
- `styles.horizontalScroll` - Container style (line 309)
- `styles.horizontalScrollContent` - Content padding style (lines 312-315)
- `styles.carouselCard` - Individual card style (lines 316-322)

**New state needed:**
- `scrollX` - Track scroll position for showing/hiding arrows
- `canScrollLeft` - Boolean to show/hide left arrow
- `canScrollRight` - Boolean to show/hide right arrow

**Icon options from Ionicons:**
- `chevron-back` / `chevron-forward` - Already used in app (search.tsx, line 188)
- `arrow-back` / `arrow-forward` - Already used in app (page/[uuid].tsx, line 65)
- `caret-back` / `caret-forward` - Alternative option

### Meeting Context

From Jan 13, 2026 meeting (transcript lines 723-755):
- **Mike Bell**: "it just looks a little awkward... half of the next card kind of showing up on the screen"
- **Adam Hardy**: "I would put kind of indicator there... maybe some kind of other indicator"
- **Mike Bell**: Suggested "maybe you have some sort of arrow that would indicate you can scroll"
- **Blocked by**: Design input from Adam Hardy (mentioned in ticket notes)

### Estimated Complexity

**Medium** - 2-3 hours of development

**Reasoning:**
- Straightforward addition of arrow buttons
- Need to wire up `onScroll` handler to track position
- Need to calculate when to show/hide arrows
- Styling arrows with proper positioning and semi-transparency
- Testing on both iOS and Android simulators
- No changes to ContentCard component needed
- No API or data structure changes needed

**If card sizing changes are also requested**: Add 1-2 hours for adjusting card width calculations, testing different screen sizes, and ensuring proper snap behavior.