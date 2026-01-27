---
status: backlog
area: ios-mip-app
phase: core
created: 2026-01-26
---

# "Purpose for Gathering" Accordion Sections Not Expandable - Design Improvement Needed

## Context

On the "What We Believe" page, the "Purpose for Gathering" section contains expandable accordion items (Fellowship, Relationship, Sharing God's Word, Prayer) that work correctly on the website but do not expand/collapse in the iOS app. The user is fine with defaulting these sections to open (expanded) on mobile, but the current design needs improvement to look nicer and more polished.

**Current State:**
- Accordion sections appear but don't expand/collapse when tapped
- "Fellowship" appears open by default but lacks visual polish
- Other items (Relationship, Sharing God's Word, Prayer) don't expand
- No visual indicators (chevrons, icons) showing expandable nature
- Design looks unrefined compared to website version

## Goals

1. Default all "Purpose for Gathering" accordion items to open (expanded) on iOS app
2. Improve visual design and styling for these sections
3. Make the sections look polished and professional
4. Ensure good readability and visual hierarchy

## Acceptance Criteria

- All "Purpose for Gathering" items (Fellowship, Relationship, Sharing God's Word, Prayer) are displayed as open/expanded by default
- Sections have improved visual design with:
  - Clear visual separation between items
  - Proper spacing and padding
  - Visual hierarchy (titles stand out from content)
  - Professional appearance matching app design language
- Content is easily readable
- Design looks intentional and polished (not just default HTML rendering)

## Notes

**Page Details:**
- Page UUID: `fZdDBgMUDK3ZiRID`
- Page Title: "What We Believe"
- CMS File: `/Users/anthony/mip/sites/ws-ffci/content/1_about/2_what-we-believe/default.txt`
- Section: "Purpose for Gathering" (near end of page)

**Accordion Structure:**
The accordion block contains 4 items:
1. **Fellowship** - Bullet points about fellowship goals
2. **Relationship** - Bullet points about relationship goals
3. **Sharing God's Word** - Scripture quote and explanation
4. **Prayer** - ACTS acronym explanation

**Current Implementation:**
- Block type: `"type":"accordion"`
- Contains `blocks` array with items having `title` and `details`
- There's also a hidden text block (`"isHidden":true`) that appears to be a fallback/alternative rendering

**Design Considerations:**

**Option A: Card-Based Design**
- Each item as a card with subtle shadow/border
- Title as prominent heading
- Content with proper spacing
- Consistent padding and margins
- Visual separation between cards

**Option B: List-Based Design**
- Items as styled list items
- Title with accent color or border
- Content indented/subordinated
- Clear visual hierarchy

**Option C: Section-Based Design**
- Each item as a distinct section
- Background color or border to separate
- Title styling that matches app design language
- Content area with appropriate typography

**Recommended Approach:**
Since sections are always open, design them as permanent content sections rather than interactive accordions:
- Remove any accordion-specific styling/behavior
- Style as distinct content sections
- Use card-like appearance with subtle borders or backgrounds
- Ensure titles are prominent (h3 or styled headings)
- Add appropriate spacing between sections
- Consider using app's primary color (#D9232A) for accents

**CSS Styling Needed:**
Add CSS rules in `HtmlContentView.swift` for accordion items:
- Style accordion container
- Style accordion item titles (make them prominent)
- Style accordion item content (proper spacing, typography)
- Add visual separation between items
- Ensure responsive spacing

**Investigation Needed:**
1. **Check HTML Output:** Verify what HTML structure is generated for accordion blocks
   - Check API response for accordion HTML
   - Determine CSS classes or structure used
   - See if JavaScript is required for accordion functionality

2. **Check Current Rendering:** See how accordion currently appears in WKWebView
   - May be rendering but not styled
   - May need CSS to make it look good
   - May need to force all items open via CSS

3. **Design Mockup:** Consider visual design options
   - Card-based with subtle shadows
   - Section-based with borders/backgrounds
   - List-based with clear hierarchy

**Implementation Steps:**
1. Investigate accordion HTML structure from API
2. Add CSS to force all accordion items to be visible (open)
3. Style accordion items with improved design:
   - Card-like appearance
   - Proper spacing
   - Visual hierarchy
   - Professional polish
4. Test on device to ensure good appearance
5. Consider adding subtle animations/transitions (optional)

**Related Sections:**
- Section has gray background (`section_bg_color: "#bfbfbf"`) with white text (`section_text_color: "#fff"`)
- Related to ticket [222](222-section-background-colors-not-appearing.md) - Section background colors

## References

- CMS Content: `/Users/anthony/mip/sites/ws-ffci/content/1_about/2_what-we-believe/default.txt`
- iOS HTML Renderer: `ios-mip-app/FFCI/Views/HtmlContentView.swift`
- API Plugin: `wsp-mobile/lib/pages.php` (generates HTML content)
- Related: [222](222-section-background-colors-not-appearing.md) - Section Background Colors
