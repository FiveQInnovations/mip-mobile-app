---
status: backlog
area: rn-mip-app
phase: core
created: 2026-01-03
---

# Internal Links URL-to-UUID Mapping

## Context
Internal links in HTML content (like "FFC Media Ministry" on the Resources page) should navigate within the app, but they currently use website URLs that need to be mapped to page UUIDs.

## Problem
On the Resources page, the "FFC Media Ministry" link points to: https://ffci.fiveq.dev/resources/ffc-media-ministry

This should navigate to the corresponding page within the app using its UUID, not open in a browser. The `HTMLContentRenderer.tsx` currently handles `/page/{uuid}` links but doesn't map website URLs to UUIDs.

## Tasks
- [ ] Review current internal link handling in `HTMLContentRenderer.tsx` (lines 146-175)
- [ ] Implement URL-to-UUID mapping for internal links
- [ ] Map `/resources/ffc-media-ministry` to its page UUID
- [ ] Test "FFC Media Ministry" link navigates to correct page in app
- [ ] Verify other internal links (like `/about`, `/resources/*`) map correctly
- [ ] Consider caching URL-to-UUID mappings for performance
- [ ] Test on both iOS and Android

## Solution Options

### Option A: API Endpoint for URL Mapping
Create API endpoint that accepts a URL path and returns the corresponding UUID:
- `GET /mobile-api/url-to-uuid?path=/resources/ffc-media-ministry`
- Returns: `{"uuid": "..."}`

### Option B: Client-side URL Pattern Matching
Map common URL patterns to UUIDs:
- `/resources/ffc-media-ministry` → known UUID
- Requires maintaining mapping in app code

### Option C: Server-side URL Transformation
Modify `wsp-mobile` plugin to transform internal URLs to `/page/{uuid}` format in HTML before sending to mobile app (similar to how it already transforms some links).

## Related Files
- `rn-mip-app/components/HTMLContentRenderer.tsx` - Link renderer implementation
- `rn-mip-app/lib/api.ts` - API client
- `wsp-mobile/lib/pages.php` - Mobile API that could transform URLs

## Notes
- The `transformInternalLinks()` function in `wsp-mobile/lib/pages.php` already transforms some internal links
- May need to extend this to handle more URL patterns
- Consider performance implications of URL lookups
