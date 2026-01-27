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
