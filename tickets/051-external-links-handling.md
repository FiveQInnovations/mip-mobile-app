---
status: backlog
area: rn-mip-app
phase: core
created: 2026-01-03
researched: 2026-01-03
---

# External Links Handling

## Context
Currently, external links in HTML content (like "Find Out How" on the Resources page) don't open properly. These links should open in the device's default browser.

## Problem
On the Resources page, external links are NOT opening:
- ❌ "Find Out How" link should open: https://harvest.org/know-god/how-to-know-god/ but does NOTHING
- ❌ BibleGateway link does NOT open

Currently, external links are not being handled correctly in `HTMLContentRenderer.tsx`. Despite code that appears correct (`Linking.openURL()` for external links), the links fail to open when tapped.

---

## Research Findings (2026-01-03)

### Current Implementation Analysis

The `HTMLContentRenderer.tsx` link handler (lines 120-189) has **three code paths**:

1. **UUID links** (lines 128-144): `/page/{uuid}` format → navigates in-app
2. **Internal links** (lines 146-179): Same domain or relative URLs → logs but doesn't navigate  
3. **External links** (lines 181-189): Different domains → `Linking.openURL(href)` ✓

**The external link code appears correct:**
```tsx
// Lines 181-189: External link - open in browser
return (
  <TouchableOpacity
    onPress={() => Linking.openURL(href)}
    activeOpacity={0.7}
  >
    <TDefaultRenderer {...restProps} />
  </TouchableOpacity>
);
```

### How `isInternalLink()` Works (lines 26-35)

```tsx
const isInternalLink = (href: string): boolean => {
  try {
    const url = new URL(href, apiBaseUrl);
    const currentDomain = new URL(apiBaseUrl).hostname;
    return url.hostname === currentDomain || href.startsWith('/');
  } catch {
    return href.startsWith('/') || href.startsWith('./') || href.startsWith('../');
  }
};
```

For `https://harvest.org/know-god/how-to-know-god/`:
- `url.hostname` = `harvest.org`
- `currentDomain` = `ffci.fiveq.dev` 
- Returns **false** → correctly identified as external

### Kirby Button Block Rendering

From `wsp-button/snippet.php`:
```php
case "url":
    $href = $block->url()->or('no url set');
    break;
// ...
$target = ($block->target() == 'true') ? 'target="_blank"' : '';
// Renders: <a class="..." href="https://harvest.org/..." target="_blank"><span>Find Out How</span></a>
```

The button block correctly renders as `<a href="...">` with external URL.

### Resources Page Content

The "Find Out How" button in `ws-ffci/content/3_resources/default.txt`:
```json
{
  "text": "Find Out How",
  "link_to": "url",
  "target": "true",
  "url": "https://harvest.org/know-god/how-to-know-god/"
}
```

### HomeScreen Donate Button (Different Mechanism)

The Donate button in `HomeScreen.tsx` works via `handleNavigate()` which:
1. Looks for menu item by label
2. If `target.page.url` exists → `Linking.openURL(target.page.url)`
3. Falls back to hardcoded URL

This is **separate** from `HTMLContentRenderer` and works independently.

### Testing Results (2026-01-03)

**CONFIRMED ISSUE**: Testing revealed that external links are NOT working:
- ❌ "Find Out How" link does NOT open anything
- ❌ BibleGateway link does NOT open anything

### Possible Root Causes

1. **Silent failure** - `Linking.openURL()` might fail silently without error handling
2. **TouchableOpacity overlap** - Parent container might be absorbing touch events
3. **HTML rendering** - Button blocks might not render to plain `<a>` tags as expected
4. **Event handler not firing** - The `onPress` handler might not be triggered
5. **Linking module issue** - React Native Linking might not be properly configured

### Recommended Verification Steps

1. **Add console.log to confirm code path:**
```tsx
// In HTMLContentRenderer.tsx line 183, add:
console.log('[HTMLContentRenderer] Opening external URL:', href);
```

2. **Check for Linking errors:**
```tsx
Linking.openURL(href).catch(err => console.error('Linking error:', err));
```

3. **Test manually in simulator** - tap "Find Out How" on Resources page

4. **Check if button renders as clickable** - the rendered HTML structure affects touch handling

---

## Tasks
- [x] Verify if external links actually work (may be a false positive issue) - **CONFIRMED: Links do NOT work**
- [ ] Add error handling/logging to `Linking.openURL()` calls to diagnose the issue
- [ ] Debug why "Find Out How" link does NOT open https://harvest.org/know-god/how-to-know-god/
- [ ] Debug why BibleGateway link does NOT open
- [ ] Fix the root cause preventing external links from opening
- [ ] Verify other external links throughout the app work correctly after fix
- [ ] Test on both iOS and Android

## Related Files
- `rn-mip-app/components/HTMLContentRenderer.tsx` - Link renderer (lines 120-189)
- `rn-mip-app/components/HomeScreen.tsx` - Donate button uses different mechanism (lines 29-51)
- `wsp-button/snippet.php` - Button block rendering
- `wsp-button-group/snippet.php` - Button group rendering
- `ws-ffci/content/3_resources/default.txt` - Resources page with test links

## Notes
- External links should use `Linking.openURL()` from React Native
- The code appears correct - verify issue before making changes
- Consider adding error handling wrapper around `Linking.openURL()`
- Consider adding visual indicator (icon) for external links
