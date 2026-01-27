---
status: backlog
area: ios-mip-app
phase: core
created: 2026-01-26
---

# Images Not Appearing on "What We Believe" Page

## Context

Images on the "What We Believe" page are not appearing in the iOS app. The page content includes background images and other image elements that should be visible but are currently missing.

**Suspected Issue:** The images may be default/placeholder images that are not uploaded to Bunny CDN, causing them to fail to load.

## Goals

1. Identify which images are missing on the "What We Believe" page
2. Verify if image URLs are being generated correctly by the API
3. Check if images exist in Bunny CDN or need to be uploaded
4. Fix image rendering so all images appear correctly

## Acceptance Criteria

- All images on "What We Believe" page are visible and render correctly
- Background images (hero images) display properly
- Image URLs resolve to valid Bunny CDN URLs
- No broken image placeholders or missing images

## Notes

**Page Details:**
- Page UUID: `fZdDBgMUDK3ZiRID`
- Page Title: "What We Believe"
- CMS File: `/Users/anthony/mip/sites/ws-ffci/content/1_about/2_what-we-believe/default.txt`

**Image References Found:**
- Background image block references: `"image":[{"id":"aaron-owens-xdbnydw77jy-unsplash-1.jpg"}]`
- This appears to be a background/hero image at the top of the page

**Investigation Needed:**
1. **Check API Response:** Verify what HTML/image URLs are returned by `/mobile-api/page/fZdDBgMUDK3ZiRID`
2. **Check Image URLs:** Verify if image URLs point to Bunny CDN (`ffci-5q.b-cdn.net`) or local paths
3. **Check File Existence:** Verify if `aaron-owens-xdbnydw77jy-unsplash-1.jpg` exists in Kirby file storage
4. **Check CDN Upload:** Verify if the image has been uploaded to Bunny CDN
5. **Check HTML Rendering:** Verify if WKWebView in `HtmlContentView.swift` is properly loading images

**Possible Causes:**
- Image file not uploaded to Bunny CDN (most likely per user's note)
- Image URL transformation not working correctly in API
- WKWebView not loading images due to CORS or security settings
- Image path references incorrect location

**Related Implementation:**
- iOS HTML rendering: `ios-mip-app/FFCI/Views/HtmlContentView.swift`
- API endpoint: `wsp-mobile/lib/pages.php` (generates HTML content)
- Image processing: `wsp-image` plugin (generates `<picture>` elements)
- Background blocks: `wsp-background` plugin (generates background images)

**Related Tickets:**
- [048](048-content-page-images-not-rendering.md) - Content Page Images Not Rendering (React Native - already fixed)

## References

- CMS Content: `/Users/anthony/mip/sites/ws-ffci/content/1_about/2_what-we-believe/default.txt`
- iOS HTML Renderer: `ios-mip-app/FFCI/Views/HtmlContentView.swift`
- API Plugin: `wsp-mobile/lib/pages.php`

---

## Research Findings (Scouted)

### Cross-Platform Reference

**Android Implementation (Reference):**
- Android uses `WebView` with CSS styling: `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt`
- Lines 186-216 include CSS rules for `picture` and `._background` elements
- Background blocks with images use CSS positioning (lines 195-216):
  - `._background` - relative positioning, 200px min-height
  - `._background picture` - absolute positioning to fill container
  - `._background picture img` - object-fit: cover, full width/height
- WebView loads HTML with `loadDataWithBaseURL("https://ffci.fiveq.dev", ...)`
- Lines 383-409: Custom `shouldInterceptRequest` adds Basic Auth headers for `ffci.fiveq.dev` resources

**iOS Implementation (Current):**
- iOS uses `WKWebView` with CSS styling: `ios-mip-app/FFCI/Views/HtmlContentView.swift`
- Lines 75-79 include similar CSS rules for `picture` elements
- Lines 77-79 handle `._background` blocks (but less comprehensive than Android)
- Lines 53-60: Has image fix logic for empty `src` attributes (extracts first URL from `srcset`)
- Line 39: Loads with `baseURL: URL(string: "https://ffci.fiveq.dev")`
- **Missing:** iOS does NOT have the auth header intercept logic that Android has (lines 383-409 in Android)

**Key Pattern Differences:**
- Android has more comprehensive CSS for `._background` blocks (absolute positioning, full coverage)
- Android intercepts requests to add Basic Auth headers; iOS does not
- Both handle `<picture>` elements through CSS, not custom renderers

### Current Implementation Analysis

**Page Content Structure:**
The "What We Believe" page has a hero section (first section in `page_content` blocks array):
- Block type: `background` with `image:[{"id":"aaron-owens-xdbnydw77jy-unsplash-1.jpg"}]`
- Located at section index 0, column 0, block 0 (id: `11c4bd79-08fd-4cc6-9763-c18b652cf8b8`)
- Renders a heading "What We Believe" over the background image

**API Processing Chain:**
1. API endpoint: `/mobile-api/page/fZdDBgMUDK3ZiRID`
2. `wsp-mobile/lib/pages.php` line 258: calls `$page->content()->page_content()->toBlocks()->toHTML()`
3. `wsp-background` plugin generates `<div class="_background">` with `<picture>` element inside
4. `wsp-image` plugin generates responsive `<picture>` elements with multiple `<source>` tags and fallback `<img>`

**iOS HTML Rendering:**
- `TabPageView.swift` lines 48-60: Renders `HtmlContentView` if `pageData.htmlContent` exists
- `HtmlContentView.swift` line 39: Sets baseURL to `https://ffci.fiveq.dev` for resource loading
- Lines 53-60: Fixes images with empty `src` by extracting first URL from `srcset`
- Lines 62-139: Wraps HTML in styled document with CSS for typography, images, and background blocks

**CSS Rules for Background Images (iOS):**
```css
._background { position: relative; width: 100%; min-height: 200px; margin-bottom: 16px; border-radius: 8px; overflow: hidden; }
._background picture { position: absolute; top: 0; left: 0; width: 100%; height: 100%; }
._background picture img { width: 100%; height: 100%; object-fit: cover; border-radius: 0; margin: 0; }
```

**Problem Diagnosis:**
The user suspects images are not uploaded to Bunny CDN. However, there's a **more critical issue discovered**:

**iOS is missing Basic Auth header injection that Android has.** 

The dev site `ffci.fiveq.dev` requires Basic Auth (`fiveq:demo`). Android's `HtmlContent.kt` lines 383-409 intercepts WebView resource requests and adds auth headers. iOS's `HtmlContentView.swift` does NOT have this logic, so:
- Initial HTML loads fine (passed through API client which has auth)
- But images/resources loaded by WKWebView fail with 401 Unauthorized
- This matches ticket 048's pattern where images weren't rendering in React Native

### Implementation Plan

**Step 1: Add Basic Auth header intercept to iOS (Primary Fix)**
1. Create a custom `WKNavigationDelegate` method to intercept resource loads
2. Add Basic Auth header (`Authorization: Basic ZmpdmVxOmRlbW8=`) to all requests for `ffci.fiveq.dev`
3. Reference Android implementation at `HtmlContent.kt` lines 383-409

**Step 2: Enhance background block CSS (Consistency with Android)**
1. Update `._background` CSS in `HtmlContentView.swift` to match Android's comprehensive rules
2. Ensure proper absolute positioning and object-fit for background images

**Step 3: Verify image URLs in API response (Optional - for completeness)**
1. Add logging to see actual image URLs returned by API
2. Verify if images point to Bunny CDN or local paths
3. If images are missing from CDN, that's a separate content issue to address

### Code Locations

| File | Line Range | Purpose |
|------|-----------|---------|
| `ios-mip-app/FFCI/Views/HtmlContentView.swift` | 25-42 | `makeUIView()` - Add WKURLSchemeHandler or intercept logic here |
| `ios-mip-app/FFCI/Views/HtmlContentView.swift` | 141-221 | `Coordinator` - Add auth header intercept in navigationDelegate methods |
| `ios-mip-app/FFCI/Views/HtmlContentView.swift` | 77-79 | Background block CSS - enhance to match Android |
| `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt` | 383-409 | **Reference:** Android's auth header intercept implementation |
| `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt` | 195-216 | **Reference:** Android's comprehensive background block CSS |
| `wsp-mobile/lib/pages.php` | 258, 235 | Calls `toBlocks()->toHTML()` - no changes needed |

### Variables/Data Reference

**Page Data:**
- UUID: `fZdDBgMUDK3ZiRID`
- Background block ID: `11c4bd79-08fd-4cc6-9763-c18b652cf8b8`
- Image reference: `aaron-owens-xdbnydw77jy-unsplash-1.jpg`

**Auth Credentials (Development Site):**
- Username: `fiveq`
- Password: `demo`
- Base64 encoded: `ZmldmVxOmRlbW8=` (for Authorization header)

**WKWebView Methods to Implement:**
- `webView(_:decidePolicyFor:decisionHandler:)` - Already exists, handles navigation
- **New:** Need to intercept resource loads for adding auth headers
- **Challenge:** WKWebView doesn't have `shouldInterceptRequest` like Android WebView
- **Solution:** Use `WKURLSchemeHandler` or custom `URLProtocol` registration

### Estimated Complexity

**Medium**

**Reasoning:**
- Primary issue is adding Basic Auth header injection to WKWebView resource loads
- WKWebView has limited intercept capabilities compared to Android WebView
- May need to use `WKURLSchemeHandler` with custom scheme or `URLProtocol` subclass
- CSS enhancement is trivial (copy from Android)
- Testing requires verifying images load with proper auth headers

**Related Work:**
- Similar to ticket 048 (React Native image rendering), but different fix approach
- Android already has this working - iOS needs to match functionality
- This issue affects ALL content pages with images, not just "What We Believe"
