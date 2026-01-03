---
status: in-progress
area: rn-mip-app
phase: bug
created: 2026-01-21
---

# Content Page Images Not Rendering

## Problem
Images are not appearing in the mobile app on content pages, even though they appear correctly in the browser version of the site.

## Testing Performed (2026-01-21)

**Browser Version (https://ffci.fiveq.dev/resources):**
- ✅ Shows multiple images:
  - Black and white image of firemen with hoses (top of page)
  - "Do You Know God?" - silhouette image
  - "Daily Verse & Bible Search" - man reading Bible image
  - "FFC Media Library" - computer screenshot image
  - "FFC Mobile App" - fireman with phone image

**Mobile App (iOS Simulator):**
- ❌ Shows NO images on Resources page
- ✅ HTML content is rendering (text, headings, links all visible)
- ✅ Confirmed `HTMLContentRenderer` component has image rendering support (lines 64-84)
- ✅ View hierarchy shows no `<img>` elements present in rendered HTML

## Root Cause Analysis

The `HTMLContentRenderer` component has proper image rendering code, but images are not appearing. Possible causes:

1. **API stripping images**: The mobile API endpoint may be returning HTML without images
2. **URL resolution**: Image URLs may be relative and not resolving correctly against `apiBaseUrl`
3. **HTML structure**: Images may be wrapped in `<figure>` or other elements not handled by the renderer
4. **Network/CORS**: Images may be blocked by iOS network security settings

## Investigation Steps

- [ ] Inspect API response to see if HTML includes image tags
- [ ] Check if image URLs are absolute vs relative
- [ ] Verify image rendering code handles all image tag variations (`<img>`, `<figure><img>`, etc.)
- [ ] Test image loading with network debugging enabled
- [ ] Check iOS network security settings (NSAppTransportSecurity)
- [ ] Compare HTML content from browser vs mobile API endpoint

## Related Files

- `rn-mip-app/components/HTMLContentRenderer.tsx` - Image rendering component
- `rn-mip-app/lib/api.ts` - API client that fetches page content
- `rn-mip-app/app.json` - iOS network security configuration

## Notes

- Text content renders correctly, so HTML parsing is working
- Image rendering code exists but may not be receiving image tags in HTML
- Issue affects all content pages, not just Resources page
