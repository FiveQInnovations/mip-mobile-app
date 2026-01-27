---
status: done
area: ios-mip-app
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

---

## Research Findings (Scouted)

### Visual Issue Analysis

From the screenshot, the issue is clearly visible:
- The "FFC's Monthly Media" section shows embedded content that extends beyond the screen width
- Text on the right is cut off (shows "MESSAGES OR..." with the rest truncated)
- Navigation controls may be partially or fully off-screen on the right side
- Media cards display speaker names and titles but right edges are not visible

### Cross-Platform Reference

**Android Implementation Status:**
The Android app (`android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt`) has the same CSS structure and **likely has the same issue** with wide embedded content. Key differences in Android:
- Lines 371-372: Uses `loadWithOverviewMode = true` and `useWideViewPort = true` WebView settings which help scale wide content
- Lines 181-184: Has `max-width: 100%` for images but **no constraints for iframes**
- Same CSS structure with no iframe-specific handling

**Pattern Similarity:**
Both platforms render HTML content using WebView components with similar CSS styling but lack proper constraints for embedded content like iframes.

### Current Implementation Analysis

**iOS Implementation (`ios-mip-app/FFCI/Views/HtmlContentView.swift`):**

The page content rendering flow:
1. **TabPageView.swift** (lines 45-60) - Displays page content in a ScrollView
   - Line 49-56: Renders `HtmlContentView` when `pageData.htmlContent` exists
   - Line 56: Height is dynamic based on `htmlContentHeight` binding
   - Line 57: `.padding(.horizontal, 0)` - No padding constraints from parent

2. **HtmlContentView.swift** (lines 53-139) - Wraps and styles HTML content
   - Line 25-41: Creates WKWebView with configuration
   - Line 31: `webView.scrollView.isScrollEnabled = false` - **Disables horizontal scrolling**
   - Line 38-39: Calls `wrapHtml()` to inject CSS styling
   - Line 66: Viewport meta tag: `width=device-width, initial-scale=1.0`

3. **CSS Styling in wrapHtml()** (lines 62-138):
   - Line 68: `body { padding: 0 16px 32px 16px; }` - Adds internal padding
   - Lines 74, 76: Images constrained with `max-width: 100%` and `width: 100%`
   - Lines 88-131: Button styling with width constraints
   - **MISSING: No CSS rules for `iframe`, `embed`, `object`, or other embedded content elements**

**The Root Cause:**
- The CSS successfully constrains standard HTML elements (images, buttons)
- **Iframes and embedded content are not constrained** - they render at their natural width
- With horizontal scrolling disabled (line 31), overflow content is simply cut off
- The embedded FFC Media content exceeds the screen width but cannot be scrolled

### Implementation Plan

**Step 1: Add iframe and embedded content constraints to iOS CSS**

File: `ios-mip-app/FFCI/Views/HtmlContentView.swift`
Location: In the `wrapHtml()` function's `<style>` section (around line 131, after button styles)

Add CSS rules to constrain iframes and other embedded content:
```css
iframe, embed, object {
    max-width: 100%;
    width: 100%;
    border: none;
}
/* Prevent horizontal overflow */
body {
    overflow-x: hidden;
}
/* Catch-all for any wide elements */
* {
    max-width: 100%;
    box-sizing: border-box;
}
```

**Step 2: Update Android implementation (for consistency)**

File: `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt`
Location: In the `styledHtml` CSS section (around line 352, after button styles)

Apply the same CSS constraints for Android to prevent the same issue.

**Step 3: Verify the fix**

1. Navigate to the Media Ministry page in the iOS simulator
2. Verify the "FFC's Monthly Media" section fits within screen width
3. Verify all media items and navigation controls are visible
4. Verify horizontal scrolling works if needed for carousel interaction
5. Test on Android emulator as well
6. Take before/after screenshots

### Code Locations

| File | Lines | Purpose | Changes Needed |
|------|-------|---------|----------------|
| `ios-mip-app/FFCI/Views/HtmlContentView.swift` | 62-138 | CSS styling in `wrapHtml()` function | Add iframe/embed CSS constraints |
| `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt` | 58-353 | CSS styling in `styledHtml` string | Add iframe/embed CSS constraints |
| `ios-mip-app/FFCI/Views/TabPageView.swift` | 45-60 | HtmlContentView rendering | No changes needed (verified correct usage) |

### Variables/Data Reference

**Key Properties:**
- `pageData.htmlContent` (String?) - The HTML content from API containing the embed
- `htmlContentHeight` (@State CGFloat) - Dynamic height binding for WebView content
- `wrapHtml(_ html: String)` (private func) - Function that wraps HTML with CSS styling

**WebView Configuration:**
- `webView.scrollView.isScrollEnabled = false` - Currently prevents scrolling; content will be constrained instead of scrollable
- Viewport: `width=device-width, initial-scale=1.0` - Ensures mobile-responsive rendering

### Estimated Complexity

**Low** - This is a straightforward CSS fix requiring:
1. Add ~10 lines of CSS to constrain embedded content
2. Apply to both iOS and Android for consistency
3. Test on simulators/emulators
4. Verify with screenshot comparison

The fix is purely additive (adding CSS rules) with no logic changes or new dependencies. The existing infrastructure (WebView, HTML wrapping, CSS injection) already supports this change.
