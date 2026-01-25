---
status: done
area: ios-mip-app
phase: core
created: 2026-01-24
---

# iOS Connect Tab Missing Buttons

## Context

On the iOS app Connect tab, the "Follow Us" section displays a heading but no social media buttons/links below it. The section appears empty, preventing users from accessing social media links.

## Problem

The Connect tab page shows:
- "Join the Brotherhood" section with "Membership Form" button ✅
- "We Are Here For You" section with "Prayer Request" button ✅
- "Follow Us" section with heading but **no buttons/links** ❌

Users cannot access social media links that should be displayed in the Follow Us section.

## Goals

1. Display social media buttons/links in the "Follow Us" section
2. Render buttons for each social platform from the API's `social` array
3. Make buttons clickable and open external links in browser
4. Match styling with other buttons on the Connect page

## Acceptance Criteria

- "Follow Us" section displays buttons for each social media platform
- Buttons are styled consistently with other action buttons (red border, red text)
- Tapping a social media button opens the URL in external browser
- Buttons are properly spaced and aligned
- All social links from `siteData.siteData.social` array are displayed

## Implementation Notes

### Data Source

The `SiteMeta` model includes a `social: [SocialLink]?` array:
```swift
struct SocialLink: Codable {
    let platform: String
    let url: String
}
```

### Current Implementation

The Connect tab uses `TabPageView` which renders HTML content from the API. The HTML content may not include the social media buttons, or they may need to be rendered separately.

### Options

**Option 1: Render from HTML Content**
- If the HTML content includes social links, ensure they're properly rendered
- May need to check if links are being filtered out by `HtmlContentView`

**Option 2: Render Separately**
- Extract social links from `siteData.siteData.social`
- Render buttons below the HTML content in `TabPageView`
- Add a new section component for social media buttons

**Option 3: Hybrid Approach**
- Parse HTML content for social links
- Fall back to `siteData.siteData.social` if HTML doesn't include them
- Render buttons programmatically

## References

- `ios-mip-app/FFCI/API/ApiModels.swift` - `SocialLink` and `SiteMeta` models
- `ios-mip-app/FFCI/Views/TabPageView.swift` - Connect tab rendering
- `ios-mip-app/FFCI/Views/HtmlContentView.swift` - HTML content renderer
- Android/RN implementations may have similar social link rendering

## Related Tickets

- Ticket 200 - iOS Resources page HTML rendering (recently fixed)

---

## Research Findings (Updated)

### Root Cause Analysis

**CORRECTED:** The buttons ARE in the HTML content from Kirby as a "button group" block. The issue is that **iOS is missing CSS styles** for Kirby's button classes that Android already has.

**Evidence from Kirby Panel screenshot:**
- "Follow Us" section contains button group with: Facebook, Instagram, Website, Give
- Buttons are configured in Kirby CMS as `_button-group` with `_button-secondary` styling
- The HTML is being sent to the app, but iOS doesn't style it

### Cross-Platform Comparison

| Platform | Button CSS Styles | Buttons Visible |
|----------|------------------|-----------------|
| Android | ✅ Has styles (HtmlContent.kt lines 196-248) | ✅ Yes |
| iOS | ❌ Missing styles | ❌ No (unstyled/invisible) |

### Android's Working CSS (Reference)

**File:** `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt`
**Lines:** 196-248

```css
/* Button group - stack buttons vertically */
._button-group {
    display: flex;
    flex-direction: column;
    gap: 12px;
    margin: 16px 0;
}

/* Base button styles - use attribute selector to handle leading spaces in class */
a[class*="_button-priority"],
a[class*="_button-secondary"],
a[class*="_button"] {
    display: block !important;
    visibility: visible !important;
    opacity: 1 !important;
    width: 100%;
    min-height: 56px;
    padding: 18px 24px;
    border-radius: 12px;
    text-align: center;
    font-size: 20px;
    font-weight: 500;
    letter-spacing: 0.5px;
    text-decoration: none !important;
    border-bottom: none !important;
    box-sizing: border-box;
    margin: 8px 0 !important;
    position: relative;
    z-index: 1;
}

/* Primary button - red background */
a[class*="_button-priority"] {
    background-color: #D9232A !important;
    color: white !important;
    border: none !important;
}

/* Secondary button - outline style */
a[class*="_button-secondary"] {
    background-color: transparent !important;
    color: #D9232A !important;
    border: 2px solid #D9232A;
}

/* Regular button (non-priority) */
a[class*="_button"]:not([class*="_button-priority"]):not([class*="_button-secondary"]) {
    background-color: #D9232A !important;
    color: white !important;
    border: none !important;
}

/* Button span should inherit */
a[class*="_button-priority"] span,
a[class*="_button-secondary"] span,
a[class*="_button"] span {
    color: inherit;
}
```

### iOS Implementation Plan

#### Single File Change Required

**File:** `ios-mip-app/FFCI/Views/HtmlContentView.swift`
**Location:** `wrapHtml()` function, inside the `<style>` block (after line 79)

**Add the button CSS styles** from Android to the iOS `wrapHtml` function.

### Code to Add

Insert after line 79 (after the `._background picture img` rule):

```swift
                /* Button group - stack buttons vertically */
                ._button-group {
                    display: flex;
                    flex-direction: column;
                    gap: 12px;
                    margin: 16px 0;
                }
                /* Base button styles */
                a[class*="_button-priority"],
                a[class*="_button-secondary"],
                a[class*="_button"] {
                    display: block !important;
                    visibility: visible !important;
                    opacity: 1 !important;
                    width: 100%;
                    min-height: 56px;
                    padding: 18px 24px;
                    border-radius: 12px;
                    text-align: center;
                    font-size: 20px;
                    font-weight: 500;
                    letter-spacing: 0.5px;
                    text-decoration: none !important;
                    border-bottom: none !important;
                    box-sizing: border-box;
                    margin: 8px 0 !important;
                    background: rgba(217, 35, 42, 0.08);
                }
                /* Primary button - red background */
                a[class*="_button-priority"] {
                    background-color: #D9232A !important;
                    color: white !important;
                    border: none !important;
                }
                /* Secondary button - outline style */
                a[class*="_button-secondary"] {
                    background-color: transparent !important;
                    color: #D9232A !important;
                    border: 2px solid #D9232A;
                }
                /* Regular button */
                a[class*="_button"]:not([class*="_button-priority"]):not([class*="_button-secondary"]) {
                    background-color: #D9232A !important;
                    color: white !important;
                    border: none !important;
                }
                /* Button span should inherit */
                a[class*="_button-priority"] span,
                a[class*="_button-secondary"] span,
                a[class*="_button"] span {
                    color: inherit;
                }
```

### Code Locations

| File | Lines | Purpose | Needs Changes? |
|------|-------|---------|----------------|
| `ios-mip-app/FFCI/Views/HtmlContentView.swift` | 67-80 | CSS styles in wrapHtml() | ✅ Yes - add button styles |

### Testing Checklist

- [ ] "Follow Us" section shows Facebook, Instagram, Website, Give buttons
- [ ] Buttons have red outline style (secondary button style)
- [ ] Buttons are full-width and stacked vertically
- [ ] Tapping buttons opens URLs in Safari
- [ ] "Membership Form" button still works (primary style - red background)
- [ ] "Prayer Request" button still works (secondary style - red outline)
- [ ] Buttons work on Resources page too (if any button groups there)

### Estimated Complexity

**Low** - ~15 minutes

- Single file change
- Copy CSS from Android implementation
- No Swift code changes needed
- No new components required

### Notes

1. The previous scout findings were incorrect - buttons come from HTML, not the `social` array
2. The `social` array in `SiteMeta` is for a different purpose (footer social links)
3. Kirby button groups use specific CSS classes: `_button-group`, `_button-priority`, `_button-secondary`
4. Using attribute selectors `[class*="_button"]` handles Kirby's class naming with potential leading spaces
