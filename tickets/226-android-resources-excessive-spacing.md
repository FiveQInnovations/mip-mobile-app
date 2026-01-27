---
status: done
area: android-mip-app
phase: core
created: 2026-01-26
---

# Android Resources Page Excessive Spacing

## Context

On the Android app's Resources page, there is excessive vertical spacing between the "More Resources" heading (with tagline "Gear, materials, and specialized tools to serve your community.") and the "FFC Online Store" subheading. This spacing is noticeably larger than the corresponding spacing in the web browser version, creating an inconsistent user experience.

## Symptoms

- Large empty vertical space (whitespace) between the "More Resources" section tagline and the "FFC Online Store" subheading
- Spacing appears much larger than the web version of the same page
- **Missing text**: "Gear, materials, and specialized tools to serve your community." is invisible (white text on white background because the blue background isn't rendering behind it)
- Creates visual inconsistency and poor use of screen space on mobile
- **Header image discrepancy**: Header image appears different from web version (visual styling/cropping difference)

## Goals

1. Reduce excessive spacing between "More Resources" section and "FFC Online Store" subheading
2. Match spacing to be consistent with web version or appropriate for mobile layout
3. Improve visual hierarchy and content density on Resources page

## Acceptance Criteria

- Spacing between "More Resources" tagline and "FFC Online Store" subheading is visually appropriate
- Spacing is consistent with other sections on the Resources page
- Layout matches or improves upon web version spacing
- No excessive whitespace that detracts from content visibility

## Technical Investigation Needed

1. **Check HTML/CSS rendering** - Is there extra margin/padding in the HTML content?
2. **Check WebView CSS** - Are there CSS rules adding excessive spacing?
3. **Check content structure** - Is there empty content blocks or elements creating the gap?
4. **Compare with web version** - What spacing does the web version use?

## References

- Resources page UUID: `uezb3178BtP3oGuU`
- Android renderer: `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt`
- Related: ticket 207 (Android Resources Missing Buttons) - may have similar HTML/CSS issues
- Screenshot comparison showing spacing difference between web and Android app

---

## Research Findings (Verified via API)

### Actual Root Cause

**The scout's analysis was incorrect.** After examining the actual API response, the real issue is:

**The `._background` CSS class uses `position: relative` with `min-height: 200px` instead of `position: absolute`.** This causes background elements to render as 200px tall blocks that take up vertical space, instead of being positioned behind section content.

### Evidence from API Response

The "More Resources" section HTML from the API:

```html
<div class="_section" style="color: #fff">
  <div class="_heading">
    <h2 class="text-center text-2xl sm:text-3xl md:text-4xl font-bold">
      More Resources
    </h2>
  </div>
  <div class="_text text-center mb-12 text-xl sm:text-2xl font-normal">
    <p>Gear, materials, and specialized tools to serve your community.</p>
  </div>
  <div class="_background" style="--bgColor: #024d91;">
    <!-- EMPTY - just a background color, no image -->
  </div>
</div>
```

The **empty `._background` div** is meant to create a blue background behind the section text. On the web, this element is absolutely positioned within the `._section` parent.

### Current Android CSS (Wrong)

In `HtmlContent.kt` (lines 195-216):

```css
._background {
    position: relative;  /* BUG: Should be absolute! */
    width: 100%;
    min-height: 200px;   /* Creates 200px block when relative */
    margin-bottom: 16px;
    border-radius: 8px;
    overflow: hidden;
}
```

**Problem:** With `position: relative`, this empty `._background` div renders as a **200px tall block** in the document flow, creating the excessive spacing between sections.

### Why the Scout Was Wrong

The scout hypothesized:
- h3 `margin-top: 28px` + Title bottom padding = 44dp total

**Actual cause:**
- `._background` div = **200px** (plus 16px margin-bottom = **216px** of spacing!)

The scout's Option 3 correctly suggested investigating the API HTML structure, but the analysis focused on margin stacking rather than examining the actual HTML content.

### Implementation Plan

**Fix the `._background` positioning:**

In `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt`:

```css
._section {
    position: relative;  /* ADD - establish positioning context */
}
._background {
    position: absolute;  /* CHANGE from relative */
    top: 0;
    left: -16px;         /* Extend to edge (body has 16px padding) */
    right: -16px;
    bottom: 0;
    width: calc(100% + 32px);  /* Full width including body padding */
    min-height: 0;       /* CHANGE - don't need min-height when absolute */
    margin-bottom: 0;    /* CHANGE - no margin needed */
    z-index: -1;         /* ADD - place behind content */
    border-radius: 0;    /* CHANGE - full-bleed backgrounds */
}
```

**Note:** This requires also adding `._section { position: relative; }` to establish the positioning context for the absolute background.

### Secondary Issue: Tailwind Classes Not Defined

The HTML also contains Tailwind utility classes like `mb-12` (48px margin-bottom) which aren't defined in the Android CSS. This is a lower priority issue since fixing `._background` positioning is the main fix. The Tailwind classes could optionally be added for consistency with web.

### Code Locations

| File | Lines | Purpose | Changes Needed |
|------|-------|---------|----------------|
| `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt` | 195-216 | `._background` CSS | Change from `position: relative` to `position: absolute`, remove `min-height: 200px` |
| Same file | TBD | Add `._section` CSS | Add `position: relative` to establish positioning context |

### Testing

After fix, verify:
1. "More Resources" tagline to "FFC Online Store" spacing is reasonable
2. Background colors still appear behind section content
3. Pages with background images (hero sections) still display correctly

### Estimated Complexity

**Medium** - CSS positioning fix, but needs careful testing to ensure:
- Absolute positioning works correctly in WebView
- Background images and colors still display properly
- Other sections with `._background` elements are not broken

---

## Implementation (2026-01-26)

**Fixed:** Updated `HtmlContent.kt` CSS to properly position `._background` elements:

1. Added `._section { position: relative; }` to establish positioning context
2. Changed `._background` from `position: relative` to `position: absolute`
3. Set `top: 0; bottom: 0` to stretch background to full section height
4. Extended background beyond body padding: `left: -16px; right: -16px; width: calc(100% + 32px)`
5. Added `z-index: -1` to place background behind content
6. Added `background-color: var(--bgColor, transparent)` to use CSS custom property for background colors
7. Removed `min-height: 200px` and `margin-bottom: 16px` (no longer needed)

**Files Changed:**
- `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt` (lines 195-210)

**Test Results (2026-01-26):**
- ✅ **Progress:** White text "Gear, materials, and specialized tools to serve your community." is now visible against blue background
- ✅ **Progress:** Spacing improved - background no longer renders as 200px block
- ⚠️ **Needs Improvement:** Spacing between "More Resources" section and "FFC Online Store" still needs further refinement
- 📝 **Note:** Header image appears different from web version (visual discrepancy noted)

**Status:** Partial fix applied, further CSS adjustments needed for optimal spacing.
