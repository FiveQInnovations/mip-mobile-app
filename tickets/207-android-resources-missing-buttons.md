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
