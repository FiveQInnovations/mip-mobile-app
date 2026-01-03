---
status: backlog
area: rn-mip-app
phase: core
created: 2026-01-03
---

# External Links Handling

## Context
Currently, external links in HTML content (like "Find Out How" on the Resources page) don't open properly. These links should open in the device's default browser.

## Problem
On the Resources page, the "Find Out How" link should open: https://harvest.org/know-god/how-to-know-god/

Currently, external links may not be handled correctly in `HTMLContentRenderer.tsx`. The link renderer checks for internal links but may not properly handle external links that should open in Safari/Chrome.

## Tasks
- [ ] Review current link handling in `HTMLContentRenderer.tsx` (lines 120-175)
- [ ] Ensure external links (non-internal, non-UUID links) open in device browser using `Linking.openURL()`
- [ ] Test "Find Out How" link on Resources page opens https://harvest.org/know-god/how-to-know-god/
- [ ] Verify other external links throughout the app work correctly
- [ ] Test on both iOS and Android

## Related Files
- `rn-mip-app/components/HTMLContentRenderer.tsx` - Link renderer implementation
- `rn-mip-app/lib/api.ts` - API client

## Notes
- External links should use `Linking.openURL()` from React Native
- May need to distinguish between external links that should open in browser vs. internal links that should navigate within app
- Consider adding visual indicator (icon) for external links
