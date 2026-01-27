---
status: backlog
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
- Creates visual inconsistency and poor use of screen space on mobile

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

## Research Findings (Scouted)

### Cross-Platform Reference

**iOS Implementation Analysis:**

iOS uses identical CSS spacing values in `ios-mip-app/FFCI/Views/HtmlContentView.swift`:
- h1: `margin-top: 36px, margin-bottom: 20px` (lines 69)
- h2: `margin-top: 32px, margin-bottom: 16px` (line 70)
- h3: `margin-top: 28px, margin-bottom: 12px` (line 71)
- p: `margin: 16px 0` (line 72)

**iOS layout structure** (`ios-mip-app/FFCI/Views/TabPageView.swift`, lines 45-60):
- Uses `ScrollView` with `VStack`
- HtmlContentView has `.padding(.horizontal, 0)` (no horizontal padding)
- Has `.padding(.top, 2)` and `.padding(.bottom, 8)` (minimal vertical padding)
- No additional spacing around HTML content

**React Native Reference (Legacy):**

React Native uses the same spacing values in `rn-mip-app/components/HTMLContentRenderer.tsx`:
- h3: `marginTop: 28, marginBottom: 12` (lines 349-356)
- p: `marginTop: 16, marginBottom: 16` (lines 326-330)
- Container: `paddingHorizontal: 16, paddingVertical: 12` (lines 470-473)

**Pattern Identified:**
All three platforms (iOS, Android, React Native) use **identical CSS spacing values**. The excessive spacing issue is **NOT due to different CSS values**, but likely due to:
1. HTML structure from API containing extra elements
2. WebView CSS collapsing margin behavior vs WKWebView
3. Android-specific padding/spacing around HtmlContent component

### Current Implementation Analysis

**Android HtmlContent.kt** (`android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt`):

**CSS Spacing (lines 64-127):**
- body: `padding: 0 16px` - Horizontal padding inside WebView
- h1: `margin-top: 36px, margin-bottom: 20px`
- h2: `margin-top: 32px, margin-bottom: 16px`
- h3: `margin-top: 28px, margin-bottom: 12px`
- p: `margin: 16px 0`

**Android TabScreen.kt** (`android-mip-app/app/src/main/java/com/fiveq/ffci/ui/screens/TabScreen.kt`):

**Page Layout (lines 175-217):**
- Column with `.verticalScroll(rememberScrollState())`
- Title: `Modifier.padding(start = 16.dp, end = 16.dp, top = 24.dp, bottom = 16.dp)` (line 196)
- HtmlContent: `Modifier.fillMaxWidth()` (line 215) - **No extra padding**
- Ends with `Spacer(modifier = Modifier.height(32.dp))` (line 227)

**Key Finding:** The Android TabScreen adds a Title above the HTML content with 16dp bottom padding. This, combined with the h3 margin-top of 28px (≈28dp), creates approximately 44dp of spacing before the first h3 heading.

### Root Cause Hypothesis

**Excessive spacing likely occurs from margin stacking:**

1. **Title to HTML content gap:** 16dp bottom padding on Title (line 196)
2. **H3 top margin:** 28px (28dp) on the h3 element (line 84 in HtmlContent.kt)
3. **Total:** ~44dp of space between "More Resources" tagline and "FFC Online Store" subheading

**Additional factors:**
- WebView may not collapse margins like native views do
- The HTML content might have extra paragraph or div elements creating more spacing
- Web version might have tighter spacing or different HTML structure

### Implementation Plan

**Option 1: Reduce h3 top margin (Recommended)**

Reduce the h3 `margin-top` from 28px to a smaller value (e.g., 16px or 20px) to create tighter spacing between sections:

```css
h3 {
    margin-top: 16px;  /* Reduced from 28px */
    margin-bottom: 12px;
    /* ... other styles ... */
}
```

**Pros:**
- Simple CSS change
- Affects all h3 headings consistently
- Matches iOS tighter layout feel

**Cons:**
- Changes spacing for ALL h3 elements, not just the problematic one
- May need to test other pages to ensure it doesn't make spacing too tight elsewhere

**Option 2: Add specific CSS rule for first h3 after page title**

Target the first h3 in the content to reduce its top margin:

```css
/* In HtmlContent.kt CSS, add: */
h3:first-of-type {
    margin-top: 8px;  /* Reduced only for first h3 */
}
```

**Pros:**
- Only affects the first h3, preserving spacing elsewhere
- Surgical fix for the specific problem

**Cons:**
- Assumes the problem is always the first h3
- More complex selector

**Option 3: Investigate HTML structure from API**

Before changing CSS, verify what HTML structure is coming from the API:
- Check if there are extra `<p>` or `<div>` elements creating space
- Look for empty elements between tagline and subheading
- Compare web version HTML structure

**Testing command:**
```bash
curl -u "fiveq:demo" "https://ffci.fiveq.dev/mobile-api/page/uezb3178BtP3oGuU" | jq -r '.page_content' | grep -A 20 "More Resources"
```

### Code Locations

| File | Lines | Purpose | Changes Needed |
|------|-------|---------|----------------|
| `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt` | 90-96 | h3 CSS styling | Reduce `margin-top` from 28px to 16px or 20px |
| `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/screens/TabScreen.kt` | 196 | Title padding | Optional: Reduce bottom padding from 16dp to 8dp |
| `ios-mip-app/FFCI/Views/HtmlContentView.swift` | 71 | iOS h3 styling | Update to match Android changes for consistency |

### Estimated Complexity

**Low** - This is a CSS spacing adjustment. The fix is straightforward:
1. Reduce h3 margin-top value in HtmlContent.kt
2. Optionally reduce Title bottom padding in TabScreen.kt
3. Test on Resources page to verify spacing improvement
4. Apply same changes to iOS for cross-platform consistency
