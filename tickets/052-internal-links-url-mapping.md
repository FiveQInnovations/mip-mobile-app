---
status: done
area: rn-mip-app
phase: core
created: 2026-01-03
resolved: 2026-01-03
---

# Internal Links URL-to-UUID Mapping

## Context
Internal links in HTML content (like "FFC Media Ministry" on the Resources page) should navigate within the app, but they currently use website URLs that need to be mapped to page UUIDs.

## Problem
On the Resources page, the "FFC Media Ministry" link points to: https://ffci.fiveq.dev/resources/ffc-media-ministry

This should navigate to the corresponding page within the app using its UUID, not open in a browser.

---

## Resolution (2026-01-03)

### Investigation Findings

**The server-side transformation is already working correctly!**

When we fetched the API response from both local and production:
```bash
curl -H "X-API-Key: ..." "https://ffci.fiveq.dev/mobile-api/page/uezb3178BtP3oGuU" \
  | jq -r '.page_content' | grep -o 'href="[^"]*"' | sort | uniq
```

**Result - all internal links are already transformed to `/page/{uuid}` format:**
```
href="/page/i0dejBvPtZELv9j6"   # FFC Media Ministry
href="/page/lLzSDKBGJdNxpeGU"   # Store
href="/page/PCLlwORLKbMnLPtN"   # Chaplain Resources
href="/page/Po6XqRpOh6DwJeqF"   # Mobile App
href="https://firefighters.org"
href="https://harvest.org/know-god/how-to-know-god/"
href="https://subsplash.com/firefightersforchristint/app"
href="https://www.biblegateway.com"
```

The `transformInternalLinks()` function in `wsp-mobile/lib/pages.php` is working correctly - it transforms all internal links (including button blocks) to `/page/{uuid}` format.

### Behavior Verification

Tested tapping "FFC Media Ministry" link on Resources page:
- ✅ **Navigates in-app** to the FFC Media Ministry page
- ✅ Shows native "← Back" button
- ✅ Tab bar remains visible
- ✅ Page content renders correctly with images and text
- ❌ Does NOT open external browser/webview

### Minor Fix Applied

Added `event?.preventDefault?.()` to the `renderersProps.a.onPress` handler in `HTMLContentRenderer.tsx` as a defensive measure to ensure the library doesn't also trigger its default `Linking.openURL` behavior.

---

## Tasks

### Completed
- [x] Set up local ws-ffci with local wsp-mobile plugin
- [x] Verify local API responds correctly
- [x] Fetch API response, inspect actual link format
- [x] **Found: links already transformed to `/page/{uuid}`**
- [x] Test "FFC Media Ministry" link navigates correctly in-app
- [x] Add `preventDefault()` as defensive fix

### Not Needed
- [x] ~~Fix transformation gap in `transformInternalLinks()`~~ - Already working
- [x] ~~Write PHPUnit test for transformation~~ - Existing code works

---

## Original Research Findings (2026-01-03)

These findings were made before investigation revealed the system was already working:

- Current client handling: `HTMLContentRenderer` only auto-navigates `/page/{uuid}`; other "internal" links are logged and not navigated. A URL-to-UUID step is still needed for slugs like `/resources/ffc-media-ministry`.
- Server transformer: `wsp-mobile/lib/pages.php` `transformInternalLinks()` already rewrites anchors to `/page/{uuid}` when the host matches. It skips different-domain links and also skips `page://{uuid}` scheme used in button blocks; that likely leaves links untransformed.

**Post-Investigation Update:** The above research was partially incorrect. The server transformer DOES handle button blocks correctly - all internal links (text and button) are being transformed to `/page/{uuid}` format.

## Related Files
- `wsp-mobile/lib/pages.php` - `transformInternalLinks()` function (working correctly)
- `rn-mip-app/components/HTMLContentRenderer.tsx` - Link handler (added preventDefault)
