---
status: done
area: ios-mip-app
phase: core
created: 2026-01-26
---

# Red Artifacts on Left Side of Resources Tab Content

## Context

Small red vertical line artifacts are appearing on the left side of content in the Resources tab on iOS. These artifacts are similar to issues that were already fixed on Android. The red lines appear as unintended visual elements that detract from the content presentation.

**Current State:**
- Small, thin vertical red lines visible on the left edge of content sections
- Artifacts appear in multiple locations on the Resources page
- Creates visual clutter and indicates CSS styling issues

## Goals

1. Remove red vertical line artifacts from Resources tab content
2. Ensure clean visual presentation without unintended red styling
3. Apply similar fixes that were successful on Android

## Acceptance Criteria

- No red vertical line artifacts visible in Resources tab content
- Content displays cleanly without unintended red styling
- Visual presentation matches intended design
- Fix aligns with Android solution approach

## Notes

**Related Android Fix:**
- Ticket [208](208-android-bracket-artifacts.md) - Red Bracket Artifacts in Content (Android)
- Android fix involved removing red styling from links that aren't buttons
- File: `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt`
- Lines 157-179: CSS rules to prevent red artifacts from link styling

**Android Solution Approach:**
The Android fix removed red styling from all links except buttons:
- Removed red background, borders, and padding from non-button links
- Specifically targeted decorative elements that might show red
- Reset inherited styles on buttons to prevent artifacts

**iOS Current Implementation:**
- File: `ios-mip-app/FFCI/Views/HtmlContentView.swift`
- Line 73: Links have red styling: `color: #D9232A; background: rgba(217, 35, 42, 0.08); border-bottom: 2px solid #D9232A;`
- Line 71: h3 headings have intentional red border-left: `border-left: 3px solid #D9232A;` (this is intentional design)

**Investigation Needed:**
1. **Check HTML Structure:** Verify what HTML elements are generating the red artifacts
   - May be unintended link styling
   - May be border-left on wrong elements
   - May be CSS bleeding from button/link styles

2. **Compare with Android:** Review Android CSS fixes and apply similar approach
   - Android removed red styling from non-button links
   - May need similar link style restrictions in iOS

3. **Check Specific Elements:** Identify which elements show red artifacts
   - Could be links styled incorrectly
   - Could be borders appearing where they shouldn't
   - Could be CSS pseudo-elements or decorative elements

**Possible Causes:**
1. **Link Styling Bleeding:** Red link styles (`border-bottom`, `background`) appearing on elements that shouldn't have them
2. **Border Artifacts:** Unintended `border-left` or other borders appearing
3. **CSS Inheritance:** Red styles from buttons/links inheriting to other elements
4. **Decorative Elements:** CSS pseudo-elements or decorative spans showing red

**Recommended Fix Approach:**
Apply similar CSS rules as Android fix:
1. Remove red styling from links that aren't buttons
2. Ensure button styles don't bleed to other elements
3. Reset inherited styles that might cause red artifacts
4. Specifically target any decorative elements showing red

**Implementation:**
Update CSS in `HtmlContentView.swift` to:
- Restrict red link styling to actual text links (not decorative elements)
- Remove red backgrounds/borders from non-button links near buttons
- Ensure button styles are properly scoped
- Add rules to prevent red artifacts similar to Android fix

**Resources Page:**
- Page UUID: `uezb3178BtP3oGuU`
- Contains multiple resource cards with buttons
- Artifacts appear on left side of content sections

## References

- Android Fix: [208](208-android-bracket-artifacts.md) - Red Bracket Artifacts in Content
- Android Implementation: `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt` (lines 157-179)
- iOS HTML Renderer: `ios-mip-app/FFCI/Views/HtmlContentView.swift` (lines 67-132)
- Resources Page UUID: `uezb3178BtP3oGuU`

---

## Research Findings (Scouted)

### Cross-Platform Reference (Android)

The Android fix for this exact issue (ticket 208) provides a proven solution pattern. Android had red artifacts appearing from link styling bleeding to decorative elements.

**Android Solution (HtmlContent.kt lines 157-179):**

```kotlin
/* Base link styles - but NOT for buttons or image links */
a:not([class*="_button"]):not([class*="_image-link"]):not([class*="image-link"]) {
    color: #D9232A;
    text-decoration: none;
    font-weight: 600;
    background: rgba(217, 35, 42, 0.08);
    padding: 4px 6px;
    border-bottom: 2px solid #D9232A;
    border-radius: 4px;
}

/* Remove red styling from ALL links except buttons - prevent artifacts */
a:not([class*="_button"]) {
    /* Only apply red styling to text links, not decorative elements */
}

/* Specifically target any decorative elements that might show red */
._button-group + a:not([class*="_button"]),
a:not([class*="_button"]) + ._button-group,
._button-group ~ a:not([class*="_button"]) {
    background: none !important;
    border: none !important;
    border-bottom: none !important;
    padding: 0 !important;
    border-radius: 0 !important;
}

/* Ensure buttons completely override base link styles */
a[class*="_button"] {
    /* Reset all inherited styles that might cause red artifacts */
    background-image: none !important;
    background-position: initial !important;
    background-repeat: initial !important;
    background-attachment: initial !important;
    background-size: initial !important;
}
```

**Key Android strategies:**
1. Use `:not([class*="_button"])` selector to exclude buttons from base link styling
2. Remove red styling from image links to prevent border/background artifacts
3. Target decorative elements near button groups to strip red styling
4. Reset all inherited background properties on buttons to prevent leakage

### Current Implementation Analysis

**iOS HtmlContentView.swift - Current CSS Issues:**

**Line 73 - Problematic base link styles:**
```css
a { 
    color: #D9232A; 
    text-decoration: none; 
    font-weight: 600; 
    background: rgba(217, 35, 42, 0.08); 
    padding: 4px 6px; 
    border-bottom: 2px solid #D9232A; 
    border-radius: 4px; 
}
```

**Problem:** This applies red styling to ALL `<a>` tags including:
- Image links (shouldn't have borders/backgrounds)
- Decorative link elements near buttons
- Empty or minimal link elements that appear as red artifacts
- Links used for structural purposes

**Lines 88-131 - Button overrides:**
Button styles attempt to override base link styles, but:
- Missing explicit reset of borders (`border-top`, `border-left`, `border-right`)
- No protection for decorative elements near buttons
- No handling of image links
- No specific artifact prevention rules

**Line 71 - Intentional red border (DO NOT CHANGE):**
```css
h3 { border-left: 3px solid #D9232A; }
```
This is intentional design for h3 headings and should remain.

**Where iOS renders HTML content:**
- File: `ios-mip-app/FFCI/Views/TabPageView.swift`
- Lines 49-56: HtmlContentView displays page HTML content
- Used for all page content including Resources tab
- CSS in HtmlContentView.swift applies to all rendered HTML

### Root Cause

**Identical to Android issue:** Base link styling (`<a>` tag rules on line 73) applies red color, red background, and red border-bottom to ALL links without discrimination. When HTML contains:
- Image links
- Decorative elements wrapped in links
- Empty or minimal link elements
- Links used for structural purposes near buttons

These elements inherit the red styling and appear as thin red vertical artifacts on the left side of content.

### Implementation Plan

Apply the proven Android CSS fixes to iOS HtmlContentView.swift:

**Step 1: Modify base link selector (line 73)**
- Change from: `a { ... }`
- Change to: `a:not([class*="_button"]):not([class*="_image-link"]):not([class*="image-link"]) { ... }`
- This prevents buttons and image links from inheriting red styles

**Step 2: Add image link reset rules (after line 76)**
- Insert new CSS block to strip red styling from image links
- Remove borders, backgrounds, padding from image link elements

**Step 3: Add decorative element protection (after line 86)**
- Insert CSS to target decorative elements near button groups
- Strip red styling from non-button links adjacent to or within button groups

**Step 4: Enhance button style resets (lines 88-131)**
- Add explicit border resets: `border-top: none !important; border-left: none !important; border-right: none !important;`
- Add background property resets to prevent inheritance artifacts
- Ensure complete override of base link styles

**Step 5: Test on iOS device/simulator**
- Navigate to Resources tab
- Verify no red vertical line artifacts appear
- Verify buttons still display correctly
- Verify text links still have red styling
- Verify h3 headings retain their intentional red border-left

### Code Locations

| File | Lines | Purpose | Needs Change |
|------|-------|---------|--------------|
| `ios-mip-app/FFCI/Views/HtmlContentView.swift` | 73 | Base link styling | ✅ YES - Add `:not()` selectors |
| `ios-mip-app/FFCI/Views/HtmlContentView.swift` | 76-86 | Image/background elements | ✅ YES - Add image link resets after line 76 |
| `ios-mip-app/FFCI/Views/HtmlContentView.swift` | 88-131 | Button styles | ✅ YES - Add more explicit border/background resets |
| `ios-mip-app/FFCI/Views/HtmlContentView.swift` | 71 | h3 heading red border-left | ❌ NO - Intentional design |
| `ios-mip-app/FFCI/Views/TabPageView.swift` | 49-56 | HTML content rendering | ❌ NO - Container only, no changes needed |
| `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt` | 157-179 | Android reference solution | ❌ NO - Reference only |

### Variables/Data Reference

**CSS Selectors:**
- `a:not([class*="_button"])` - All links except buttons
- `a:not([class*="_image-link"])` - All links except image links
- `._button-group` - Container for button groups
- `[class*="_button"]` - Matches any class containing "_button"

**FFCI Red Color:**
- Hex: `#D9232A`
- RGB: `rgba(217, 35, 42, 0.08)` for backgrounds

**Files to modify:**
- Only: `ios-mip-app/FFCI/Views/HtmlContentView.swift`

**Resources Page:**
- UUID: `uezb3178BtP3oGuU`
- API: `https://ffci.fiveq.dev/mobile-api/page/uezb3178BtP3oGuU`

### Estimated Complexity

**Low-Medium** - CSS modifications only, but requires careful copying of Android solution patterns and testing to ensure no regressions.

**Implementation time:** ~30-45 minutes
- ~10 minutes to apply CSS changes from Android
- ~10 minutes to verify changes compile
- ~15-20 minutes to test on iOS simulator
- ~5 minutes to verify no regressions on other pages

**Risk:** Low - CSS changes only, isolated to HTML rendering component. Can easily revert if issues arise.

**Testing Requirements:**
1. Navigate to Resources tab and verify no red artifacts
2. Verify buttons render correctly with proper styling
3. Verify text links still have red styling for actual link text
4. Test other pages with HTML content to ensure no regressions
5. Verify h3 headings retain red border-left styling
