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

---

## Next Steps for Investigation

### 1. Control Test: Does Linking.openURL() work at all?
- **Test the Donate button** on HomeScreen - it uses `Linking.openURL()` via a different code path
- If Donate works → issue is specific to HTMLContentRenderer
- If Donate fails → issue is with Linking module or simulator configuration

### 2. Inspect the API Response
- Fetch `https://ffci.fiveq.dev/api/pages/resources` and examine the raw HTML for the button blocks
- Confirm the `<a href="https://harvest.org/...">` tag is present and correct
- Check if the button is wrapped in unexpected parent elements

### 3. Trace the Code Path with Logging
Add console.log statements to answer:
```tsx
// At line ~120 in the renderers.a function:
console.log('[HTMLContentRenderer] Link tapped, href:', href);

// Before Linking.openURL:
console.log('[HTMLContentRenderer] Calling Linking.openURL for:', href);
```

Key questions:
- Is the `renderers.a` function being called at all?
- Is the `href` value what we expect?
- Which code path (UUID/internal/external) is being taken?

### 4. Check for Silent Errors
```tsx
Linking.openURL(href)
  .then(() => console.log('[HTMLContentRenderer] Linking.openURL succeeded'))
  .catch(err => console.error('[HTMLContentRenderer] Linking.openURL failed:', err));
```

### 5. Investigate TouchableOpacity Nesting
- Does `react-native-render-html` wrap `<a>` tags in its own touchable component?
- Could there be competing touch handlers that prevent `onPress` from firing?
- Check if `TDefaultRenderer` introduces nested touchables

### 6. Check react-native-render-html Configuration
- Review `customHTMLElementModels` and `renderers` configuration
- Look for known issues with custom `a` tag renderers in the library's GitHub issues
- Verify the library version in `package.json` and check for breaking changes

### 7. Test on Physical Device vs Simulator
- Some simulators have issues opening URLs
- Test on a real iOS device to rule out simulator limitations

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
- The code appears correct but doesn't work - need diagnostic logging to find root cause
- **Priority debug question**: Is the `onPress` handler even being invoked?
- Consider adding error handling wrapper around `Linking.openURL()`
- Consider adding visual indicator (icon) for external links

## Hypotheses (ranked by likelihood)

1. **TouchableOpacity never receives tap** - Most likely. The `react-native-render-html` library may wrap `<a>` tags in its own pressable, or `TDefaultRenderer` may contain nested touchables that capture the event.

2. **Custom renderer not being used** - The `renderers.a` configuration might not be applied correctly, so the default link behavior (which may do nothing in RN) is used instead.

3. **Linking.openURL fails silently** - Less likely since the code looks correct, but possible if there's an issue with the URL format or simulator.

4. **href value is wrong/empty** - The href extracted from `tnode.attributes.href` might be undefined or malformed.
