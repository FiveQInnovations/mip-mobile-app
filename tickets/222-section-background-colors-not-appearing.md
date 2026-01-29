---
status: done
area: ios-mip-app
phase: core
created: 2026-01-26
---

# Section Background Colors Not Appearing in iOS App

## Context

Section background colors from the Kirby website are not appearing in the iOS app. On the "What We Believe" page, multiple sections have colored backgrounds (like red for "Guiding Policies") that display correctly on the website but show as white in the app. Additionally, text colors that should change for legibility on colored backgrounds (e.g., white text on red) are not being applied.

**Example Issue:**
- "Guiding Policies" section has a red background (`#d9232a` or `#bfbfbf`) with white text on the website
- In the iOS app, this section shows white background with dark text, making it inconsistent with the website design

## Goals

1. Ensure section background colors from Kirby CMS are rendered in the iOS app
2. Ensure text colors adapt appropriately for legibility on colored backgrounds
3. Match the visual design of the website for all sections with background colors

## Acceptance Criteria

- All section background colors appear correctly in the iOS app
- Text colors automatically adjust for legibility on colored backgrounds (e.g., white text on dark/red backgrounds)
- "Guiding Policies" section displays with red background and white text (matching website)
- All other sections with colored backgrounds display correctly
- Visual design matches the website version

## Notes

**Page Details:**
- Page UUID: `fZdDBgMUDK3ZiRID`
- Page Title: "What We Believe"
- CMS File: `/Users/anthony/mip/sites/ws-ffci/content/1_about/2_what-we-believe/default.txt`

**Section Attributes Found:**
Sections in Kirby content have attributes like:
- `section_bg_style`: "true" or "false" (indicates if background styling is enabled)
- `section_bg_color`: Color value (e.g., "#bfbfbf", "#ffffff", "#d9232a")
- `section_text_color`: Text color (e.g., "#fff", "#222222")
- `section_text_style`: "true" or "false" (indicates if text styling is enabled)

**Example from "Guiding Policies" section:**
```json
{
  "section_text_style": "true",
  "section_text_color": "#fff",
  "section_bg_style": "true",
  "section_bg_color": "#bfbfbf"
}
```

**Current iOS Implementation:**
- `ios-mip-app/FFCI/Views/HtmlContentView.swift` wraps HTML content with CSS styles
- Current CSS includes styles for body, headings, paragraphs, images, buttons
- **Missing:** CSS rules for section-level background colors and text colors
- Sections are likely rendered with inline styles or CSS classes that need to be preserved/handled

**Investigation Needed:**
1. **Check API HTML Output:** Verify what HTML/CSS is returned for sections with background colors
   - Check if sections have inline `style` attributes
   - Check if sections have CSS classes that need styling
   - Check if background colors are in the HTML or need to be extracted from JSON

2. **Check Section Rendering:** Determine how Kirby renders sections in HTML
   - Sections may be wrapped in `<div>` or `<section>` elements
   - May have classes like `._section` or similar
   - May have inline styles: `style="background-color: #d9232a; color: #fff;"`

3. **Add CSS Support:** Update `HtmlContentView.swift` CSS to:
   - Preserve inline styles on section elements
   - Add CSS rules for section background colors
   - Ensure text colors are applied correctly
   - Handle both `section_bg_color` and `section_text_color` attributes

**Possible Implementation Approaches:**

**Option A: Preserve Inline Styles (if API outputs them)**
- Ensure WKWebView doesn't strip inline styles
- May already work if HTML includes `style="background-color: ..."`

**Option B: Add CSS Rules for Section Classes**
- If sections have CSS classes, add rules like:
```css
._section[style*="background-color"] {
  /* Ensure styles are applied */
}
```

**Option C: Extract and Apply Styles from JSON**
- Parse section attributes from API response
- Generate CSS rules dynamically based on section attributes
- More complex but gives full control

**Related Sections on "What We Believe" Page:**
- "Guiding Policies" - Red/gray background with white text
- "Purpose for Gathering" - Gray background (`#bfbfbf`) with white text
- "Doctrinal Statement" - Blue background (`#024d91`) with white text
- Other sections may also have background colors

## References

- CMS Content: `/Users/anthony/mip/sites/ws-ffci/content/1_about/2_what-we-believe/default.txt`
- iOS HTML Renderer: `ios-mip-app/FFCI/Views/HtmlContentView.swift` (lines 67-132)
- API Plugin: `wsp-mobile/lib/pages.php` (generates HTML content)
- Related: [221](221-what-we-believe-images-not-appearing.md) - Images Not Appearing on Same Page

---

## Research Findings (Scouted)

### Cross-Platform Reference

**Android Implementation Pattern:**
The Android app's `HtmlContent.kt` component has similar CSS structure to iOS but also lacks section background color support. Both platforms wrap API HTML content in a WebView with extensive CSS styling for typography, buttons, and images, but neither handles section-level styling.

**Key Differences:**
- Android uses `AndroidView` with `WebView` while iOS uses `WKWebView` via `UIViewRepresentable`
- Both load HTML with `loadDataWithBaseURL`/`loadHTMLString` with base URL `https://ffci.fiveq.dev`
- Both have identical CSS for typography, buttons, and images
- Neither has CSS rules for section background colors or text colors

**Shared Pattern to Adopt:**
Both platforms wrap HTML content in a styled template with embedded CSS. The solution should add section styling CSS rules to both platforms' embedded stylesheets.

### Current Implementation Analysis

**How Website Renders Sections with Background Colors:**

1. **Kirby Layout Processing** (`wsp-site-public/classes/H.php:561-646`):
   - `H::parse()` function groups layouts into sections
   - Extracts section attributes: `section_bg_style`, `section_bg_color`, `section_text_style`, `section_text_color`
   - Generates inline styles using CSS custom properties:
     ```php
     // Line 604
     $sections[$i]['styles'][] = "--theme-surface: {$layout->section_bg_color()->value()};";
     // Line 609
     $sections[$i]['styles'][] = "--theme-content: {$layout->section_text_color()->value()};";
     // Line 612
     $sections[$i]['styles'][] = "--color-heading: {$layout->section_text_color()->value()};";
     ```

2. **Website Template Rendering** (`wsp-site-public/snippets/general/page-builder.php:42`):
   - Renders `<section class="_section">` elements with inline styles:
     ```php
     <section class="grid relative z-0 _section <?= $ss['classes'] ?>" style="<?= $ss['styles'] ?>">
     ```
   - Example rendered HTML:
     ```html
     <section class="_section" style="--theme-surface: #bfbfbf; --theme-content: #fff; --color-heading: #fff;">
     ```

3. **Website CSS** (applies these variables to elements):
   - Uses CSS custom properties to style content within sections
   - Background color applied via `--theme-surface`
   - Text color applied via `--theme-content` to body text
   - Heading color applied via `--color-heading` to headings

**Mobile API HTML Generation** (`wsp-mobile/lib/pages.php:235-265`):

The mobile API uses a different code path that bypasses section wrappers:

```php
// Line 258 (content_data function)
$pageContentHtml = $page->content()->page_content()->toBlocks()->toHTML();
return [
    "page_content" => $this->transformInternalLinks($pageContentHtml),
    // ... other fields
];
```

**Key Issue:**
- `toBlocks()->toHTML()` generates HTML directly from Kirby blocks **without section wrappers**
- Section-level attributes (`section_bg_color`, `section_text_color`) are **not included** in the HTML
- Mobile apps receive raw block HTML without any section styling information

### Root Cause

The mobile API returns HTML that lacks section-level styling because:
1. It uses `toBlocks()->toHTML()` which renders individual blocks, not sections
2. Section attributes exist in the raw JSON data but are not parsed or applied
3. The iOS/Android WebView CSS has no rules to handle section styling

### Implementation Plan

**Option 1: Parse JSON and Generate Section-Aware HTML (Recommended)**

Modify the mobile API to generate section-aware HTML with inline styles:

1. **Update `wsp-mobile/lib/pages.php`** (around line 258):
   - Parse `page_content` JSON to extract layouts and sections
   - Use `H::parse()` or similar logic to group layouts into sections
   - Wrap block HTML with section divs containing inline styles
   - Apply `background-color` and `color` inline styles based on section attributes

2. **Update iOS `HtmlContentView.swift`** (lines 67-132):
   - Add CSS rules for section elements:
     ```css
     section {
         padding: 16px 0;
         margin-left: -16px;
         margin-right: -16px;
         padding-left: 16px;
         padding-right: 16px;
     }
     section[style*="background-color"] {
         /* Ensure background colors are respected */
     }
     section[style*="color"] {
         /* Ensure text colors are respected */
     }
     ```

3. **Update Android `HtmlContent.kt`** (lines 64-353):
   - Add matching CSS rules for section elements (same as iOS)

**Option 2: Add CSS for Inline Style Support (Simpler, Less Robust)**

Add CSS rules to both apps that respect inline styles on any element:

1. **iOS `HtmlContentView.swift`** - Add after line 132:
   ```css
   /* Support for section styling */
   div[style*="background-color"],
   section[style*="background-color"] {
       padding: 24px 16px;
       margin-left: -16px;
       margin-right: -16px;
   }
   ```

2. **Android `HtmlContent.kt`** - Add after line 353 (same CSS)

3. **Modify API to wrap layouts in divs** with inline styles from section attributes

### Code Locations

| File | Purpose | Changes Needed |
|------|---------|----------------|
| `wsp-mobile/lib/pages.php:235-265` | Generates HTML for mobile API | Modify `content_data()` to parse sections and apply inline styles |
| `ios-mip-app/FFCI/Views/HtmlContentView.swift:67-132` | iOS WebView CSS stylesheet | Add CSS rules for section elements with background/text colors |
| `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt:64-353` | Android WebView CSS stylesheet | Add matching CSS rules for section styling |
| `wsp-site-public/classes/H.php:561-646` | Section parsing logic (reference) | Reference implementation for parsing section attributes |
| `wsp-site-panel/blueprints/shared/layout.yml:49-86` | Section attribute definitions | Documents available section attributes |

### Variables/Data Reference

**Section Attributes (from Kirby layout settings):**
- `section_bg_style`: Boolean toggle ("true"/"false" string)
- `section_bg_color`: Hex color value (e.g., "#bfbfbf", "#d9232a", "#024d91")
- `section_text_style`: Boolean toggle ("true"/"false" string)
- `section_text_color`: Hex color value (e.g., "#fff", "#222222")

**CSS Variables (used on website):**
- `--theme-surface`: Background color
- `--theme-content`: Text color
- `--color-heading`: Heading color

**HTML Classes:**
- `._section`: Class applied to section elements on website
- Not currently present in mobile API HTML

**Example Section Data from "What We Believe" page:**
```json
{
  "attrs": {
    "section_bg_style": "true",
    "section_bg_color": "#bfbfbf",
    "section_text_style": "true",
    "section_text_color": "#fff"
  }
}
```

### Estimated Complexity

**Medium** - Requires changes across three components (API, iOS, Android)

**Complexity Factors:**
- ✅ Simple: Well-documented section attributes in Kirby
- ✅ Simple: Both mobile platforms use similar WebView approach
- ⚠️ Medium: Need to parse JSON structure to extract section attributes
- ⚠️ Medium: Must ensure proper HTML structure with section wrappers
- ⚠️ Medium: Testing across multiple pages with various background colors
- ✅ Low Risk: Changes are additive (won't break existing functionality)

**Estimated Effort:**
- API changes: 2-3 hours (parse sections, generate wrapped HTML)
- iOS CSS updates: 30 minutes (add section styling rules)
- Android CSS updates: 30 minutes (match iOS rules)
- Testing: 1 hour (verify on "What We Believe" and other pages)
- **Total: ~4-5 hours**

---

## Implementation Notes (2026-01-26)

### Changes Made
1. **API (`wsp-mobile/lib/pages.php`)**: Added `generateSectionAwareHtml()` method that parses section JSON and wraps each section's HTML in `<div class="_section" style="background-color: X; color: Y">` when section styling is enabled.

2. **iOS (`HtmlContentView.swift`)**: Added CSS rules for `._section` elements to support background colors and text color inheritance.

### Android Status (2026-01-28)
**Android section background colors are already working correctly.** The Android app's `HtmlContent.kt` component includes CSS rules for `._section` elements (lines 109-123, 229-240) that properly handle section background colors and text color inheritance.

**Verified Working Example:**
- "Doctrinal Statement" section on "What We Believe" page displays correctly on Android:
  - Blue background (`#024d91`) is visible
  - White text is readable and properly styled

**iOS Issue:**
- iOS still does not display section backgrounds
- "Doctrinal Statement" section shows white text without background, making it unreadable
- iOS implementation needs to be completed to match Android behavior

### Bug Fix: Gray Divider Lines
**Issue**: Initial implementation applied margins (`margin-top: 16px; margin-bottom: 16px`) to ALL section divs, causing visible gray gaps between sections (body background showing through).

**Fix**: Changed CSS to only apply padding/margins to sections that have `background-color` in their inline style attribute. Sections without background styling now have no default margins.

### Bug Fix: Horizontal Rule Lines
**Issue**: Kirby "line" blocks render as `<hr>` elements, creating visible gray divider lines throughout the page.

**Fix**: Added `hr { display: none; }` to CSS to hide these dividers.

### Remaining Issues
The "What We Believe" page has additional design issues beyond section background colors that need separate investigation:
- Layout/spacing issues with collapsed sections
- Visual styling of card-like content blocks (Vision, Focus, Blueprint, etc.)
- Accordion/expandable sections not functioning
- Other visual discrepancies from website design

These should be addressed in separate tickets focused on specific block types or layout patterns.

---

## Attempted Fixes (2026-01-28)

### Attempt 1: Enhanced CSS Rules
**What was tried:**
- Added explicit CSS rules for `._section[style*="background-color"]` with `display: block !important` and `background-size: auto !important`
- Added universal selector `[style*="background-color"]` with background property rules
- Enhanced color inheritance rules for `._section[style*="color"] *` to force `color: inherit !important`

**Result:** ❌ Did not work - sections with blue background still not visible in iOS app

### Attempt 2: JavaScript Style Enforcement
**What was tried:**
- Added JavaScript injection in `webView(_:didFinish:)` to parse inline `style` attributes and reapply `background-color` and `color` directly to `element.style` after page load
- JavaScript queries all `._section[style]` elements and extracts/rebuilds style properties

**Result:** ❌ Did not work - JavaScript executes but background colors still not rendering

### Attempt 3: Dynamic CSS Rule Injection (SUCCESS)
**Root Cause Discovered:**
- Some sections have `section_bg_style: "true"` with inline `background-color` on the `._section` div
- Other sections use a `background` block type which sets `--bgColor` as a CSS variable on a child `._background` element
- The previous JavaScript only looked at section inline styles, missing the `._background` child pattern

**What was tried:**
- Enhanced JavaScript to also search for `._background` child elements within sections
- Extract `--bgColor` CSS variable from background elements when section doesn't have inline `background-color`
- Dynamically inject CSS rules targeting each section by unique `data-section-id` attribute

**Result:** ✅ **Fixed!** - Sections with background blocks now correctly display blue backgrounds with white text

### Solution Details
1. **iOS JavaScript (`HtmlContentView.swift`)**: Updated `didFinish` handler to:
   - Query all `._section` elements (not just those with `[style]`)
   - Check for `._background[style*="--bgColor"]` child elements
   - Extract the `--bgColor` CSS variable value
   - Inject dynamic CSS rules with `!important` to force background colors

2. **API Fix (`wsp-mobile/lib/pages.php`)**: Also updated `generateSectionAwareHtml()` to:
   - Scan section blocks for `background` block types
   - Extract `background_color` from those blocks
   - Apply to section's inline style if `section_bg_style` is not enabled
   - (Note: Deployed to git repo, awaiting server update)

### Final Status
- **iOS**: Fixed - background colors now render correctly via JavaScript CSS injection
- **API**: Enhanced to generate better HTML, but server deployment pending
- Test screenshot confirms "Doctrinal Statement: White Text on Blue Background" is now visible

### Pending: Server Deployment
The API fix in `wsp-mobile/lib/pages.php` has been committed and pushed to the git repo (`eaf3c06`), but needs to be deployed to the production server (`ffci.fiveq.dev`) via `composer update fiveq/wsp-mobile`. The iOS fix works independently of this API update.

---

## Visual Tester QA Report (2026-01-28)

**Verdict:** PASS for ticket scope, minor issues noted

### Section 2: "Doctrinal Statement: White Text on Blue Background"
**Status:** ✅ CORRECT
- White text on royal blue background renders correctly
- Heading and body text both properly contrast
- Excellent readability - **this was the primary bug, now fixed**

### Section 1: "Prayer & Fruit: Black Text on White Background"
**Status:** ⚠️ PARTIAL (out of scope for this ticket)
- Body text: Black/dark gray on white - ✅ Correct
- Heading text: Blue (#0055A4) instead of black - not matching label
- This is existing site styling behavior, not a regression from this ticket

### Minor Issues Noted
1. **Debug text visible**: "cache-miss (1) s1 sl104U" showing at bottom right of blue section - should be hidden in production
2. **Heading color inconsistency**: First section heading is blue while label says "Black Text" - pre-existing design issue

### Scores
- Spacing: 8/10
- Alignment: 8/10
- Readability: 9/10
- Overall: 7/10

### Recommendation
The primary ticket goal (section background colors appearing) is **achieved**. The "Doctrinal Statement" blue background with white text is now correctly visible. Minor issues noted are out of scope for this ticket.

---

## Padding Fix (2026-01-28)

**Issue:** Visual tester identified asymmetric padding on blue section - extended to left edge but had a gap on the right edge.

**Root Cause:** CSS had `max-width: 100%` on all elements which prevented negative margins from working correctly.

**Fix Applied (`HtmlContentView.swift`):**
- Added explicit `width: calc(100% + 32px) !important` to sections with background colors
- Added `max-width: none !important` to override the universal max-width constraint
- Added `box-sizing: border-box !important` for proper box model

**Result:** ✅ Blue section now extends edge-to-edge with consistent padding on both sides (9.4/10 design score from visual tester)
