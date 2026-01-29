---
status: done
area: ios-mip-app
phase: core
created: 2026-01-26
---

# "Purpose for Gathering" Accordion Sections Not Expandable - Design Improvement Needed

## Issue Summary

**Problem:** Accordion items in "Purpose for Gathering" section were not expanding and lacked visual polish. Radio buttons were visible but items remained collapsed. Additionally, blockquote elements inside colored sections had incorrect background colors on Android.

**Solution:** 
- Added CSS to force accordion items open with proper spacing
- Added JavaScript to force all `<details>` elements open and show hidden accordion content
- Hidden radio buttons since items are always open
- Fixed blockquote backgrounds in colored sections to be transparent (inheriting section background)
- Added JavaScript to fix inline color inheritance for blockquotes
- Applied to both iOS and Android

**CMS Fix:** Removed redundant gray `section_bg_color` from "Guiding Policies" section so the red background block renders correctly.

**Files Changed:**
- `ios-mip-app/FFCI/Views/HtmlContentView.swift` - Added accordion CSS + JavaScript + blockquote fixes
- `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt` - Added accordion CSS + JavaScript + blockquote fixes, enabled JS

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

---

## Research Findings (Scouted)

### Cross-Platform Reference

**Android Implementation (Reference for iOS):**
- **File:** `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt`
- **CSS Location:** Lines 63-353 (inline `<style>` block)
- **Current Status:** No accordion-specific CSS styling exists
- **Existing Patterns:** 
  - Card-like styling for buttons with border-radius, padding, and shadows
  - Uses WebView with inline CSS for content rendering
  - Typography hierarchy: h3 uses `#024D91` color with left border accent (`#D9232A`)
  - Links styled with red accent color `#D9232A`

**React Native Implementation (Legacy Reference):**
- No accordion-specific handling found
- Basic HTML rendering without custom accordion styles

**Key Pattern to Adapt:**
- Android uses detailed inline CSS with proper heading hierarchy
- iOS should follow similar pattern: h3 for accordion titles with color `#024D91` and red accent border
- Both platforms render HTML in WebView, so CSS approach is consistent

### Current Implementation Analysis

**iOS HTML Renderer:**
- **File:** `ios-mip-app/FFCI/Views/HtmlContentView.swift`
- **CSS Section:** Lines 67-132
- **Current CSS Styles:**
  - h1, h2, h3, p, a, img, picture, buttons - all styled
  - **NO accordion-specific styles** (no `details`, `summary`, or `.accordion` selectors)
  - h3 currently styled with `#024D91` color, `#D9232A` left border (lines 71)

**Android HTML Renderer:**
- **File:** `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt`
- **CSS Section:** Lines 63-353
- **Current Status:** Also lacks accordion-specific styles
- **Similar h3 styling:** Lines 90-99 (blue color, red border)

**Backend/API:**
- **File:** `wsp-mobile/lib/pages.php`
- **Line:** 235 - `$pageContentHtml = $page->content()->page_content()->toBlocks()->toHTML();`
- **Process:** Kirby converts accordion blocks to HTML via `toBlocks()->toHTML()`
- **Plugin:** Uses `wsp-accordion` (Composer package from `fiveq/wsp-accordion`)
- **Expected HTML Structure:** Likely uses semantic HTML `<details>` and `<summary>` elements (standard for Kirby accordion blocks)

**CMS Content Structure:**
- **File:** `/Users/anthony/mip/sites/ws-ffci/content/1_about/2_what-we-believe/default.txt`
- **Line:** 5 (within JSON in Page-content field)
- **Accordion Block ID:** `e582cffb-350c-433e-885b-dab462ce799f`
- **Type:** `"type":"accordion"`
- **Items:** 4 accordion items with `title` and `details` fields:
  1. Fellowship (bullet list)
  2. Relationship (bullet list)
  3. Sharing God's Word (scripture quote)
  4. Prayer (ACTS acronym)

**Section Background Context:**
- Section has `section_bg_color: "#bfbfbf"` (gray) and `section_text_color: "#fff"` (white)
- Related to ticket #222 (section background colors)
- Accordion titles and content should work with gray background

### Expected HTML Structure

Based on Kirby accordion block conventions (semantic HTML):

```html
<details class="accordion" open>
  <summary class="accordion-title">Fellowship</summary>
  <div class="accordion-content">
    <ul>
      <li>To spur one another on toward love and good deeds.</li>
      <li>To encourage one another more and more...</li>
    </ul>
  </div>
</details>
<details class="accordion" open>
  <summary class="accordion-title">Relationship</summary>
  <div class="accordion-content">...</div>
</details>
<!-- etc -->
```

Or possibly custom class-based structure:
```html
<div class="accordion">
  <div class="accordion-item">
    <div class="accordion-title">Fellowship</div>
    <div class="accordion-content">...</div>
  </div>
</div>
```

### Implementation Plan

**iOS (Primary Platform):**

1. **Add Accordion CSS to HtmlContentView.swift** (Lines 67-132)
   - Force all `<details>` elements to be open (expanded)
   - Style `<summary>` as prominent headings
   - Style accordion content with proper spacing
   - Create card-like appearance with borders/backgrounds
   - Ensure compatibility with gray section background (#bfbfbf)

2. **CSS Selectors to Add:**
   ```css
   /* Force accordion items open */
   details { display: block; }
   details[open] { display: block; }
   summary { display: list-item; }
   
   /* Accordion item styling */
   details, .accordion-item {
     background: rgba(255, 255, 255, 0.1);
     border: 1px solid rgba(255, 255, 255, 0.2);
     border-radius: 12px;
     padding: 20px;
     margin-bottom: 16px;
   }
   
   /* Accordion title styling */
   summary, .accordion-title {
     font-size: 20px;
     font-weight: 700;
     color: #fff;
     margin-bottom: 12px;
     cursor: default;
     list-style: none;
   }
   
   /* Hide default disclosure triangle */
   summary::-webkit-details-marker { display: none; }
   
   /* Accordion content styling */
   .accordion-content, details > *:not(summary) {
     color: #fff;
     font-size: 17px;
     line-height: 28px;
   }
   ```

3. **Test on iOS Simulator:**
   - Navigate to "What We Believe" page (UUID: `fZdDBgMUDK3ZiRID`)
   - Scroll to "Purpose for Gathering" section (gray background)
   - Verify all 4 items display open
   - Check visual design looks polished
   - Verify text is readable on gray background

**Android (Secondary - Apply Same Pattern):**

4. **Update Android HtmlContent.kt** (Lines 63-353)
   - Add identical accordion CSS styles
   - Ensure consistency with iOS implementation
   - Test on Android emulator

### Code Locations

| File | Purpose | Changes Needed |
|------|---------|----------------|
| `ios-mip-app/FFCI/Views/HtmlContentView.swift` | iOS HTML renderer with inline CSS | **ADD** accordion CSS styles (lines 67-132) |
| `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt` | Android HTML renderer with inline CSS | **ADD** accordion CSS styles (lines 63-353) |
| `wsp-mobile/lib/pages.php` | API that generates HTML | **NO CHANGES** - already generates accordion HTML |
| `/Users/anthony/mip/sites/ws-ffci/content/1_about/2_what-we-believe/default.txt` | CMS content source | **NO CHANGES** - content is correct |

### Key Variables/Data Reference

**Accordion Block (CMS):**
```json
{
  "type": "accordion",
  "blocks": "[{...}]",
  "id": "e582cffb-350c-433e-885b-dab462ce799f"
}
```

**Section Background:**
```json
{
  "section_bg_color": "#bfbfbf",
  "section_text_color": "#fff"
}
```

**Expected HTML Elements:**
- `<details>` - Accordion container
- `<summary>` - Accordion title/header
- `.accordion-content` or nested elements - Accordion body content

**Color Palette:**
- Primary Red: `#D9232A` (brand color)
- Primary Blue: `#024D91` (heading color)
- Section Background: `#bfbfbf` (gray)
- Section Text: `#fff` (white)

### Design Approach (Recommended)

**Card-Based Design with Subtle Transparency:**
- Each accordion item as a semi-transparent card
- Works well with gray background (#bfbfbf)
- White text with good contrast
- Border radius for modern feel (12px)
- Vertical spacing between cards (16px)
- Internal padding (20px)

**Typography Hierarchy:**
- Titles: 20px, bold, white
- Content: 17px, regular, white, 28px line-height
- Lists maintain proper spacing (8px between items)

**No Interactivity:**
- Remove disclosure triangles (since always open)
- No hover states needed
- Static display optimized for mobile reading

### Estimated Complexity

**Low-Medium**

**Reasoning:**
- **Simple CSS-only solution** - No JavaScript or native UI components needed
- **Well-defined scope** - Single CSS block addition to 1-2 files
- **Clear requirements** - Force open, improve visual design
- **Existing patterns** - Can follow button/heading styling already in place
- **Risk:** Unknown HTML structure from `wsp-accordion` plugin
  - If structure differs from expected `<details>/<summary>`, may need to adjust selectors
  - Can test by viewing page API response or inspecting rendered HTML
  
**Estimated Time:** 1-2 hours (includes testing both iOS and Android)
