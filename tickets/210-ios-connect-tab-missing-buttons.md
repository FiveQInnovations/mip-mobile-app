---
status: backlog
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

## Research Findings (Scouted)

### Root Cause Analysis

The social media buttons are **NOT missing due to a rendering bug** - they were never implemented. The HTML content from the API contains a "Follow Us" heading, but no actual buttons. Social media buttons must be rendered **programmatically** from the `siteData.siteData.social` array.

**Evidence:**
- iOS `TabPageView.swift` only renders HTML content via `HtmlContentView` (lines 49-60)
- React Native `TabScreen.tsx` only renders HTML via `HTMLContentRenderer` (lines 282-284)
- Android `TabScreen.kt` only renders HTML via `HtmlContent` composable (lines 209-217)
- **None of the platforms render social media buttons from the API's social array**

### Cross-Platform Status

This is a **missing feature across ALL platforms** (iOS, Android, React Native), not an iOS-specific bug:

| Platform | Status | Social Data Available | Social Buttons Rendered |
|----------|--------|----------------------|------------------------|
| iOS | ❌ Missing | Yes (via siteData) | No |
| Android | ❌ Missing | Yes (via siteData) | No |
| React Native | ❌ Missing | Yes (via api.ts) | No |
| Astro Prototype | ✅ Working | Yes | Yes |

### Astro Prototype Reference

The Astro prototype (`astro-prototype/src/components/GetConnected.astro`) shows the correct implementation pattern:

**Data Model:**
```typescript
// Lines 9-13
export interface SocialLink {
  url: string;
  label?: string;
  platform?: string;
}
```

**Rendering Logic:**
- Lines 71-84: Filters social links (excludes "donate")
- Lines 28-49: Maps platform names to icons (📘 Facebook, 📷 Instagram, etc.)
- Lines 118-150: Renders "Follow Us" section with buttons for each social link
- Opens links in external browser with `target="_blank"`

### iOS Implementation Plan

#### Step 1: Update Data Flow

**File:** `ios-mip-app/FFCI/ContentView.swift`

**Change at lines 91-96:**
```swift
// Before:
TabPageView(uuid: item.page.uuid)

// After:
TabPageView(uuid: item.page.uuid, socialLinks: siteData.siteData.social)
```

**Complexity:** Low - single line change to pass data

---

#### Step 2: Update TabPageView to Accept Social Links

**File:** `ios-mip-app/FFCI/Views/TabPageView.swift`

**Change at lines 13-14:**
```swift
// Add parameter
let socialLinks: [SocialLink]?

// Update init signature
TabPageView(uuid: String, socialLinks: [SocialLink]? = nil)
```

**Complexity:** Low - parameter addition

---

#### Step 3: Create Social Button View Component

**File:** `ios-mip-app/FFCI/Views/SocialButtonView.swift` (NEW FILE)

Create a reusable button component styled to match existing action buttons (red border, red text).

**Requirements:**
- Platform icon mapping (Facebook → 📘, Instagram → 📷, Twitter/X → 🐦, YouTube → 📺)
- Red border, red text (matching existing buttons)
- Opens URL in external browser via `UIApplication.shared.open(url)`
- Handles missing/invalid URLs gracefully

**Reference styling:**
- Match buttons in "Join the Brotherhood" / "Prayer Request" sections
- Border: `Color("PrimaryColor")` (red)
- Text: `Color("PrimaryColor")`
- Rounded corners, padding

**Complexity:** Medium - new component with styling

---

#### Step 4: Render Social Buttons in TabPageView

**File:** `ios-mip-app/FFCI/Views/TabPageView.swift`

**Insert after HTML content (after line 60):**
```swift
// Social media buttons
if let socialLinks = socialLinks, !socialLinks.isEmpty {
    VStack(alignment: .leading, spacing: 12) {
        Text("Follow Us")
            .font(.headline)
            .padding(.horizontal, 16)
            .padding(.top, 8)
        
        ForEach(socialLinks, id: \.url) { link in
            SocialButtonView(link: link)
                .padding(.horizontal, 16)
        }
    }
    .padding(.bottom, 16)
}
```

**Complexity:** Low - straightforward SwiftUI layout

---

### Code Locations

| File | Lines | Purpose | Needs Changes? |
|------|-------|---------|----------------|
| `ios-mip-app/FFCI/ContentView.swift` | 91-96 | Pass social links to TabPageView | ✅ Yes |
| `ios-mip-app/FFCI/Views/TabPageView.swift` | 13-14 | Add socialLinks parameter | ✅ Yes |
| `ios-mip-app/FFCI/Views/TabPageView.swift` | 60 | Insert social buttons after HTML | ✅ Yes |
| `ios-mip-app/FFCI/Views/SocialButtonView.swift` | NEW | Social button component | ✅ Yes (create) |
| `ios-mip-app/FFCI/API/ApiModels.swift` | 60-63 | SocialLink model | ❌ No (already exists) |
| `ios-mip-app/FFCI/API/MipApiClient.swift` | 54-90 | getSiteData API call | ❌ No (already works) |
| `ios-mip-app/FFCI/Views/HtmlContentView.swift` | ALL | HTML renderer | ❌ No |

### API Data Structure

The social links are available in the site data response:

```json
{
  "menu": [...],
  "site_data": {
    "title": "FFCI",
    "social": [
      { "platform": "Facebook", "url": "https://facebook.com/..." },
      { "platform": "Instagram", "url": "https://instagram.com/..." },
      { "platform": "YouTube", "url": "https://youtube.com/..." }
    ],
    ...
  }
}
```

**Note:** The API may include a `label` field in addition to `platform`, but iOS models don't currently support it. Use `platform` for button text.

### Platform Icon Mapping

Based on Astro prototype (lines 28-49):

| Platform (case-insensitive) | Icon | Button Text |
|------------------------------|------|-------------|
| facebook | 📘 | Facebook |
| instagram | 📷 | Instagram |
| twitter, x | 🐦 | Twitter/X |
| youtube | 📺 | YouTube |
| website, web | 🌐 | Website |
| default | 🔗 | [platform name] |

### Testing Checklist

- [ ] Social buttons appear in Connect tab below HTML content
- [ ] Buttons styled with red border and red text (matching Prayer Request button)
- [ ] Each button shows correct platform icon
- [ ] Tapping button opens URL in Safari/external browser
- [ ] "Follow Us" heading appears above buttons
- [ ] No buttons shown if `social` array is empty/nil
- [ ] Layout works on iPhone SE (small screen) and iPhone 15 Pro Max (large screen)
- [ ] VoiceOver reads button labels correctly

### Estimated Complexity

**Overall: Low-Medium**

- Step 1 (ContentView): Low - 1 line change
- Step 2 (TabPageView parameter): Low - parameter addition
- Step 3 (SocialButtonView): Medium - new component with styling and icon logic
- Step 4 (Render buttons): Low - straightforward SwiftUI

**Total Estimated Effort:** ~1-2 hours for implementation + testing

### Notes for Implementation

1. **Don't modify HtmlContentView** - HTML renderer is working correctly
2. **Match existing button styles** - Use same colors/fonts as other action buttons
3. **Handle edge cases:**
   - Empty social array → hide section
   - Invalid URLs → skip that button
   - Unknown platform → use generic 🔗 icon
4. **Consider future enhancement:** Parse HTML for "Follow Us" heading and inject buttons there instead of appending (more sophisticated but not required for MVP)
