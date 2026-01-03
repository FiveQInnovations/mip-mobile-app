---
status: in-progress
area: rn-mip-app
phase: core
created: 2026-01-03
---

# Internal Page Back Navigation Not Working

## Problem

When navigating to an internal page via an HTML content link (e.g., tapping "FFC Media Ministry" on the Resources page), the "← Back" button on iOS does not work. Tapping it does nothing.

**Expected behavior:** Tapping "← Back" should return to the Resources page.

**Actual behavior:** Nothing happens when tapping "← Back".

## Reproduction Steps

1. Open the app on iOS
2. Navigate to Resources tab
3. Scroll to "FFC Media Ministry" link
4. Tap the link - navigates to FFC Media Ministry page
5. Tap "← Back" button in top left
6. **Bug:** Nothing happens, stays on the same page

## Technical Context

The internal link navigation uses `router.push(`/page/${uuid}`)` in `HTMLContentRenderer.tsx`:

```typescript
const uuid = extractUuidFromUrl(href);
if (uuid) {
  if (onNavigate) {
    onNavigate(uuid);
  } else {
    router.push(`/page/${uuid}`);
  }
  return;
}
```

The page route is defined in `app/page/[uuid].tsx` which uses Expo Router.

## Investigation Areas

- [ ] Check if the Back button is using `router.back()` or another method
- [ ] Verify the navigation stack is being properly built
- [ ] Check if there's a gesture handler issue
- [ ] Test if `router.replace()` is being used instead of `router.push()`
- [ ] Review Expo Router navigation configuration

## Related Files

- `rn-mip-app/components/HTMLContentRenderer.tsx` - Link handler using `router.push()`
- `rn-mip-app/app/page/[uuid].tsx` - Dynamic page route
- `rn-mip-app/app/_layout.tsx` - Root layout with navigation config

## Related Tickets

- Ticket 052: Internal Links URL Mapping (just resolved - links now navigate correctly)
