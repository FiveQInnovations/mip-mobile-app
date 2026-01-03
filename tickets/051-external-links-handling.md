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
On the Resources page, the "Find Out How" link should open: https://harvest.org/know-god/how-to-know-god/

Currently, external links may not be handled correctly in `HTMLContentRenderer.tsx`. The link renderer checks for internal links but may not properly handle external links that should open in Safari/Chrome.

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

### Possible Issues to Verify

1. **The code looks correct** - external links SHOULD work. Need to verify if the issue is real.
2. **Possible silent failure** - `Linking.openURL()` might fail silently without error handling
3. **TouchableOpacity overlap** - Parent container might be absorbing touch events
4. **HTML rendering** - Button blocks might not render to plain `<a>` tags as expected

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
- [ ] Verify if external links actually work (may be a false positive issue)
- [ ] Add error handling/logging to `Linking.openURL()` calls
- [ ] Test "Find Out How" link on Resources page opens https://harvest.org/know-god/how-to-know-god/
- [ ] Test BibleGateway.com link on Resources page
- [ ] Verify other external links throughout the app work correctly
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
