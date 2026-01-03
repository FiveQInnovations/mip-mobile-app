---
status: in-progress
area: rn-mip-app
phase: core
created: 2026-01-03
researched: 2026-01-03
tested: 2026-01-03
---

# External Links Handling

## Problem Summary
External links in HTML content on the Resources page do NOT open when tapped:
- ❌ "Find Out How" link (https://harvest.org/know-god/how-to-know-god/) - **CONFIRMED: Does nothing**
- ❌ "BibleGateway.com" link - **CONFIRMED: Does nothing**

## Manual Testing Results (2026-01-03)

### Control Test: Donate Button ✅
**Result:** WORKS - Opens browser successfully
- Tested Donate button on HomeScreen (uses `Linking.openURL()` via different code path)
- Browser opened with URL `firefightersforchrist.org` (404 error, but mechanism works)
- **Conclusion:** `Linking.openURL()` works correctly - issue is specific to `HTMLContentRenderer`

### External Links Test ❌
**Result:** FAILS - Links do nothing when tapped
- Tested "Find Out How" link on Resources page - tapped but browser did NOT open
- Tested "BibleGateway.com" link on Resources page - tapped but browser did NOT open
- Links are visible and tappable (found in view hierarchy as `<a>` elements)
- **Conclusion:** `onPress` handler in `HTMLContentRenderer` is NOT being invoked

## Root Cause Analysis

### Fixes Applied
1. **✅ Fixed href extraction** - Changed from `props.href` to `tnode?.attributes?.href` (per react-native-render-html docs)
2. **✅ Added comprehensive logging** - Logs at every decision point to trace code path
3. **✅ Added error handling** - Promise-based error handling for `Linking.openURL()`

### Most Likely Issue
**TouchableOpacity `onPress` handler not firing** - The `react-native-render-html` library may wrap `<a>` tags in its own pressable component, or `TDefaultRenderer` may contain nested touchables that capture the event before our handler receives it.

### Next Steps
1. **Check console logs** when tapping links to see:
   - Is `renderers.a` function being called?
   - What href value is extracted?
   - Is `onPress` handler invoked?
   - Does `Linking.openURL()` succeed or fail?
2. **Try alternative approach** - Use `renderersProps.a.onPress` instead of wrapping in TouchableOpacity (see code below)

### How to Check Console Logs

**Method 1: Metro Bundler Terminal (Easiest)**
- Run `npm start` or `expo start --dev-client` in terminal
- Console logs appear directly in the terminal output
- Look for logs prefixed with `[HTMLContentRenderer]`

**Method 2: Expo Dev Tools**
- Press `j` in Metro bundler terminal to open Expo Dev Tools in browser
- Or open `http://localhost:19002` in browser
- View logs in the "Logs" tab

**Method 3: iOS Simulator Logs**
- In iOS Simulator: Device → Console (or Cmd+Shift+C)
- Filter by searching for "HTMLContentRenderer"
- Shows all system logs including React Native console.log

**Method 4: React Native Debugger (Advanced)**
- Install React Native Debugger: `brew install --cask react-native-debugger`
- Enable remote debugging in app (shake device → "Debug")
- View logs in React Native Debugger console

**Quick Test:**
1. Start app: `cd rn-mip-app && npm start`
2. Navigate to Resources page
3. Tap "Find Out How" link
4. Check terminal/Metro output for `[HTMLContentRenderer]` logs
5. If NO logs appear → renderer function not being called
6. If logs appear but no "External link tapped" → onPress not firing

## Code Changes Made

### HTMLContentRenderer.tsx Updates
- Fixed href extraction: `const href = tnode?.attributes?.href || props.href;`
- Added logging throughout link renderer
- Added error handling to `Linking.openURL()` calls

### Alternative Approach (If Current Fix Doesn't Work)
Use `renderersProps` for global link handling instead of TouchableOpacity wrapping:

```tsx
<RenderHTML
  renderersProps={{
    a: {
      onPress: (event, href) => {
        console.log('[HTMLContentRenderer] Link pressed via renderersProps:', href);
        if (href && !isInternalLink(href)) {
          Linking.openURL(href)
            .then(() => console.log('Link opened successfully'))
            .catch(err => console.error('Failed to open link:', err));
        }
      }
    }
  }}
/>
```

## Technical Details

### Current Implementation
The `HTMLContentRenderer.tsx` link handler has three code paths:
1. **UUID links**: `/page/{uuid}` format → navigates in-app
2. **Internal links**: Same domain or relative URLs → logs but doesn't navigate
3. **External links**: Different domains → `Linking.openURL(href)` (currently not working)

### How `isInternalLink()` Works
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

### Library Version
- `react-native-render-html@^6.3.4`

## Tasks
- [x] Verify if external links actually work - **CONFIRMED: Links do NOT work**
- [x] Add error handling/logging to `Linking.openURL()` calls
- [x] Test Donate button (control test) - **WORKS**
- [x] Test "Find Out How" link - **FAILS**
- [x] Test BibleGateway link - **FAILS**
- [ ] Check console logs to diagnose why `onPress` isn't firing
- [ ] Fix the root cause preventing external links from opening
- [ ] Verify other external links throughout the app work correctly after fix
- [ ] Test on both iOS and Android

## Related Files
- `rn-mip-app/components/HTMLContentRenderer.tsx` - Link renderer (lines 120-213)
- `rn-mip-app/components/HomeScreen.tsx` - Donate button uses different mechanism (lines 29-51)
- `wsp-button/snippet.php` - Button block rendering
- `ws-ffci/content/3_resources/default.txt` - Resources page with test links
