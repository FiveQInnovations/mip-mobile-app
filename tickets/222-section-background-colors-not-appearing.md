---
status: backlog
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
