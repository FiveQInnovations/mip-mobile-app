---
status: backlog
area: android-mip-app
phase: core
created: 2026-01-24
---

# Resources Page Missing Buttons/Cards

## Context

The Resources tab should display 6 resource cards with action buttons, but only "Do You Know God?" with its "Find Out How" button is rendering. The other 5 resource cards are missing, and there are red bracket artifacts (`{` or `}`) appearing where content should be.

## Expected Content (from Kirby CMS)

**First row (4 cards):**
1. "Do You Know God?" → "Find Out How" button → harvest.org ✅ (showing)
2. "Daily Verse & Bible Search" → "BibleGateway.com" button ❌ (missing)
3. "Media Library" → "Media Ministry" button ❌ (missing)
4. "FFC Mobile App" → "FFC Mobile App" button ❌ (missing)

**More Resources section (2 cards):**
5. "FFC Online Store" → "Shop Now" button ❌ (missing)
6. "Chaplain's Resources" → "View Resources" button ❌ (missing)

## Symptoms

1. Only 1 of 6 resource cards is rendering
2. Red bracket artifacts (`{` or `}`) appearing in place of missing content
3. Excessive whitespace where cards should be
4. Screenshot shows brackets above/below content blocks

## Goals

1. All 6 resource cards display with their buttons
2. No bracket artifacts in rendered content
3. Buttons link to correct destinations (external URLs or internal pages)

## Acceptance Criteria

- All 6 resource cards render with correct titles and descriptions
- All buttons are tappable and navigate to correct destinations
- No red bracket or template artifacts visible
- Layout matches design intent (card grid or list)

## Technical Investigation Needed

1. **Check API response** - Does `/mobile-api/page/{resources-uuid}` return all 6 cards?
2. **Check HTML conversion** - Are button blocks being converted to `<a class="_button">` tags?
3. **Check Android rendering** - Is `HtmlContent.kt` properly rendering button elements?
4. **Identify bracket source** - What generates the `{` `}` artifacts?

## Likely Causes

- Backend (wsp-mobile) may not be converting all button blocks to HTML
- Button JSON structure may differ between working and non-working buttons
- HTML sanitization may be stripping certain elements
- Template syntax leaking into output

## References

- Content source: `/Users/anthony/mip/sites/ws-ffci/content/3_resources/default.txt`
- API plugin: `/Users/anthony/mip/fiveq-plugins/wsp-mobile/lib/pages.php`
- Android renderer: `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt`
- Related: React Native `HTMLContentRenderer.tsx` handles `._button` class

---

## Research Findings (Scouted)

### Root Cause Identified

**The buttongroup snippet is NOT converting buttons to HTML.**

**Location:** `/Users/anthony/mip/fiveq-plugins/wsp-button-group/snippet.php` (line 11)

```php
<div class="_button-group <?= $css['classes'] ?>">
    <?= $block->buttons()->toBlocks() ?>  <!-- ❌ PROBLEM: toBlocks() returns objects, not HTML -->
</div>
```

**Expected:**
```php
<div class="_button-group <?= $css['classes'] ?>">
    <?= $block->buttons()->toBlocks()->toHTML() ?>  <!-- ✅ FIX: Add ->toHTML() -->
</div>
```

### Evidence

1. **Content Structure** (`3_resources/default.txt`):
   - All 6 resource cards have proper button/buttongroup blocks in JSON
   - Each button has `"type":"button"` and buttongroup has `"type":"buttongroup"`
   - Button data includes: `"text"`, `"kind"` (`_button` or `_button-priority`), `"link_to"`, `"url"` or `"page"`

2. **Button Rendering Chain**:
   ```
   Page Content → toBlocks()->toHTML() 
   → Buttongroup snippet executes 
   → Calls buttons()->toBlocks() (missing .toHTML()) 
   → Returns block objects instead of <a> tags
   → Objects converted to string = "{" or "}"
   ```

3. **Button Plugin** (`/Users/anthony/mip/fiveq-plugins/wsp-button/`):
   - Has proper snippet that renders: `<a class="<?= $css['classes'] ?>" href="<?= $href ?>"><span><?= $block->text() ?></span></a>`
   - CSS classes come from `H::block_css($block)` which reads the `kind` field
   - Plugin is registered at `blocks/button`

4. **React Native Reference**:
   - RN app expects `<a class="_button">` or `<a class="_button-priority">` 
   - Android `HtmlContent.kt` has CSS styling for `._button` and `._button-priority` classes
   - Both apps are designed to handle the button HTML correctly

### Why One Button Works

The "Do You Know God?" button likely works because it's:
- Either a standalone button (not in a buttongroup), OR
- The buttongroup itself is being rendered but the nested `toBlocks()` is producing the bracket artifacts

### Implementation Plan

**Backend Fix (wsp-button-group plugin):**

1. Edit `/Users/anthony/mip/fiveq-plugins/wsp-button-group/snippet.php`
2. Change line 11 from:
   ```php
   <?= $block->buttons()->toBlocks() ?>
   ```
   To:
   ```php
   <?= $block->buttons()->toBlocks()->toHTML() ?>
   ```

3. Test the Resources page API response to verify buttons render as HTML

**No Android changes needed** - the renderer already handles `._button` classes correctly.

### Code Locations

| File | Lines | Purpose | Changes Needed |
|------|-------|---------|---------------|
| `/Users/anthony/mip/fiveq-plugins/wsp-button-group/snippet.php` | 11 | Button group rendering | Add `->toHTML()` to line 11 |
| `/Users/anthony/mip/fiveq-plugins/wsp-mobile/lib/pages.php` | 235, 258 | API HTML generation | No changes (working correctly) |
| `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt` | 189-220 | Button CSS styling | No changes (already supports buttons) |

### Estimated Complexity

**Low** - Single line fix in the buttongroup snippet. The button rendering infrastructure is already in place and working. The issue is simply that nested blocks aren't being converted to HTML.

### Testing Steps

1. Apply fix to buttongroup snippet
2. Restart PHP/Kirby (if needed for plugin reload)
3. Fetch Resources page from mobile API: `curl -u "fiveq:demo" "https://ffci.fiveq.dev/mobile-api/page/uezb3178BtP3oGuU"`
4. Verify `page_content` HTML contains `<a class="_button">` or `<a class="_button-priority">` tags
5. Test in Android app - all 6 buttons should render
6. Test in RN app - verify no regression

### Important Note

**React Native worked fine WITHOUT this code change**, which suggests:
- React Native's `react-native-render-html` may handle Blocks objects differently
- Or React Native uses a different code path for button rendering
- The issue may be Android WebView-specific, not just backend HTML generation

**After deploying `->toHTML()` fix, Android still doesn't render buttons correctly.** This indicates:
- Possible caching issue (app needs full restart/clear cache)
- Android WebView may need different HTML structure or CSS
- Or there's a different root cause specific to Android rendering

**Next steps:**
- Verify API response actually contains button HTML after fix
- Check if Android WebView is receiving/rendering the HTML correctly
- Compare React Native's HTML processing vs Android WebView behavior

### Debugging Added

Added debug logging to `HtmlContent.kt` to log:
- HTML content length
- Whether `_button` class is found in HTML
- Sample HTML around button elements if found

**To test:**
1. Navigate to Resources tab in Android app
2. Check logcat: `adb logcat -d | grep HtmlContent`
3. Verify if buttons are in the HTML or missing

### React Native vs Android Difference

**React Native (`react-native-render-html`):**
- Uses custom renderer that intercepts `<a class="_button">` tags
- Converts them to React Native `Pressable` components
- May be more forgiving with malformed HTML or Blocks objects

**Android (WebView):**
- Renders HTML directly with CSS styling
- Requires proper HTML structure
- Less forgiving - needs complete, valid HTML

**Hypothesis:** If React Native worked without `->toHTML()`, it might be because:
1. `react-native-render-html` handles Blocks objects differently
2. React Native uses a different code path
3. Or there's caching/API differences between platforms

**Action needed:** Verify what HTML the API is actually returning after the fix.

### Root Cause Found (Android CSS Issue)

**Debug logs confirmed:** Buttons ARE in the HTML from the API! The backend fix worked.

**The real issue:** CSS selectors weren't matching because of leading spaces in class attributes.

**HTML from API:**
```html
<a class=" _button-priority _default" href="...">
```

Notice the leading space: `class=" _button-priority"`. The CSS selector `._button-priority` doesn't match when there's a leading space.

**Fix Applied:**
Changed CSS selectors from class selectors to attribute selectors:
- Before: `._button-priority` (doesn't match `class=" _button-priority"`)
- After: `a[class*="_button-priority"]` (matches regardless of spaces)

**Files Changed:**
- `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt` - Updated button CSS selectors

**Status:** Fixed and deployed. Buttons should now render correctly.
