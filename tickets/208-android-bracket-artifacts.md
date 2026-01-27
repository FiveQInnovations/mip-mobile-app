---
status: done
area: android-mip-app
phase: core
created: 2026-01-24
---

# Red Bracket Artifacts in Content

## Context

Red bracket characters (`{` or `}`) are appearing in rendered content on the Resources page and potentially other pages. These artifacts appear where content blocks should be, suggesting template syntax or JSON structure is leaking into the rendered HTML.

## Symptoms

- Small red bracket characters visible in content
- Brackets appear at positions where other content (buttons, cards) should render
- Creates visual clutter and indicates rendering failures

## Goals

1. Identify the source of bracket artifacts
2. Prevent brackets from appearing in rendered content
3. Ensure underlying content renders correctly

## Acceptance Criteria

- No bracket artifacts visible in any page content
- All content blocks render correctly
- Clean visual presentation without template syntax leakage

## Technical Investigation Needed

1. **Check API response** - Are brackets present in the JSON/HTML from the API?
2. **Check Kirby block conversion** - Is `toBlocks()->toHTML()` outputting brackets?
3. **Check wsp-mobile transformation** - Is content transformation adding brackets?
4. **Check WebView CSS** - Are brackets styled elements that should be hidden?

## Possible Causes

1. **JSON syntax leakage** - Block structure `{}` not fully converted to HTML
2. **Template syntax** - Kirby/PHP template markers not processed
3. **HTML entities** - Curly bracket entities rendering as text
4. **CSS pseudo-elements** - Styled elements using bracket content

## References

- Screenshot: Resources page showing bracket artifacts
- Related: ticket 207 (missing buttons - brackets appear where buttons should be)
- API plugin: `/Users/anthony/mip/fiveq-plugins/wsp-mobile/lib/pages.php`

---

## Research Findings (Scouted)

### Root Cause Identified

The red bracket artifacts are caused by **incomplete HTML rendering in the Kirby buttongroup block snippet**. 

**File:** `/Users/anthony/mip/sites/ws-ffci/site/plugins/wsp-button-group/snippet.php`  
**Line:** 11  
**Current code:**
```php
<?= $block->buttons()->toBlocks() ?>
```

**Problem:** The code calls `toBlocks()` but NOT `toHTML()`, which means Kirby tries to echo the Blocks collection object directly. When a Blocks object is echoed without being converted to HTML, it likely outputs a string representation or debug info that includes curly brackets from the underlying JSON structure.

### Evidence Trail

1. **Content structure** (`/Users/anthony/mip/sites/ws-ffci/content/3_resources/default.txt`):
   - Resources page contains multiple `buttongroup` blocks
   - Each buttongroup has a `buttons` field containing JSON-encoded button arrays
   - Example: `"buttons":"[{\"content\":{\"text\":\"Find Out How\"...}]"`

2. **API conversion** (`/Users/anthony/mip/fiveq-plugins/wsp-mobile/lib/pages.php`):
   - Line 235 & 258: `$pageContentHtml = $page->content()->page_content()->toBlocks()->toHTML();`
   - API correctly calls `toBlocks()->toHTML()` on the page content
   - This processes all blocks including buttongroups

3. **Buttongroup rendering** (`/Users/anthony/mip/sites/ws-ffci/site/plugins/wsp-button-group/snippet.php`):
   - Line 11 is missing `->toHTML()` call
   - The Blocks object gets stringified instead of rendered
   - Curly brackets from JSON structure leak through

4. **Button rendering** (`/Users/anthony/mip/sites/ws-ffci/site/plugins/wsp-button/snippet.php`):
   - Individual button snippet correctly renders `<a>` tags (lines 48-50)
   - But buttons never get processed because buttongroup doesn't call toHTML()

5. **Android WebView styling** (`/Users/anthony/mip-mobile-app/android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt`):
   - Lines 183-220: CSS expects proper HTML structure with `._button-group` div and button `<a>` tags
   - Lines 115-123: Links are styled red with background, which explains why brackets appear red
   - Brackets might be appearing inside partial `<a>` tags or as text content

### React Native Reference

The React Native app expects the same HTML structure:
- File: `rn-mip-app/components/HTMLContentRenderer.tsx`
- Lines 314-318: Has `._button-group` styling with flexbox layout
- Both apps expect proper HTML output from the API

### Implementation Plan

**Backend Fix (Required):**

1. **Edit Kirby buttongroup snippet:**
   - File: `/Users/anthony/mip/sites/ws-ffci/site/plugins/wsp-button-group/snippet.php`
   - Line: 11
   - Change: `<?= $block->buttons()->toBlocks() ?>`
   - To: `<?= $block->buttons()->toBlocks()->toHTML() ?>`

2. **Verify fix:**
   - Test with curl: `curl -u fiveq:demo https://ffci.fiveq.dev/mobile-api/page/uezb3178BtP3oGuU`
   - Check that buttons render as proper `<a>` tags inside `<div class="_button-group">`
   - Verify no bracket artifacts in HTML response

**No Frontend Changes Needed:**
- Android already has correct CSS styling for buttons (lines 182-220 in HtmlContent.kt)
- React Native already has correct styling
- Both apps will work once backend outputs proper HTML

### Code Locations

| File | Line | Purpose | Needs Change |
|------|------|---------|--------------|
| `/Users/anthony/mip/sites/ws-ffci/site/plugins/wsp-button-group/snippet.php` | 11 | Buttongroup block rendering | ✅ YES - Add `->toHTML()` |
| `/Users/anthony/mip/fiveq-plugins/wsp-mobile/lib/pages.php` | 235, 258 | API page content conversion | ❌ No - Already correct |
| `/Users/anthony/mip/sites/ws-ffci/site/plugins/wsp-button/snippet.php` | 48-50 | Individual button rendering | ❌ No - Already correct |
| `/Users/anthony/mip-mobile-app/android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/HtmlContent.kt` | 183-220 | Android button CSS | ❌ No - Already correct |

### Variables/Data Reference

- `$block->buttons()`: Returns the buttons field from buttongroup block
- `->toBlocks()`: Parses JSON string into Kirby Blocks collection
- `->toHTML()`: Converts Blocks collection to HTML string (MISSING in buttongroup snippet)
- Resources page UUID: `uezb3178BtP3oGuU`
- API endpoint: `https://ffci.fiveq.dev/mobile-api/page/{uuid}`

### Estimated Complexity

**Low** - Single line fix in backend Kirby plugin snippet.

**Impact:** This fix will also resolve ticket 207 (missing buttons) since the buttons aren't rendering at all - just showing bracket artifacts instead.

**Testing:** Need to verify on both Android and React Native apps after backend fix is deployed.

### Important Note

**React Native worked fine WITHOUT this code change**, which suggests the issue may be Android WebView-specific. After deploying `->toHTML()` fix, if Android still shows bracket artifacts, investigate:
- Android WebView's handling of Blocks objects vs React Native's renderer
- Possible caching issues requiring app restart
- Different HTML processing between platforms

### Resolution ✅

**Status:** RESOLVED - Bracket artifacts were fixed as part of ticket 207.

**Resolution Details:**
- The root cause was the same as ticket 207 - the buttongroup snippet wasn't calling `->toHTML()`
- When the backend fix was applied (adding `->toHTML()` to the buttongroup snippet), bracket artifacts disappeared
- Additional CSS fixes in `HtmlContent.kt` ensured no red artifacts from base link styles
- All bracket artifacts eliminated once buttons rendered correctly as HTML

**Related:** This ticket was resolved alongside ticket 207 (Android Resources Missing Buttons), as they shared the same root cause.
