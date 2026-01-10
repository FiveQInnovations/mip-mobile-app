---
status: in-progress
area: wsp-mobile
phase: core
created: 2026-01-20
---

# Fix Search Result Descriptions - Display User-Friendly Text

## Context

After optimizing search API performance (ticket 065), the API is now fast and responsive. However, search results are displaying raw JSON/structured data in the description field instead of user-friendly text. This makes search results confusing and unprofessional.

**Current state:**
- Search API responds quickly (< 1 second) ✅
- Search results show JSON/structured data like `[{"attrs": {"collapse":"false","section_text_style":"false","se...` ❌
- Descriptions should show readable text previews, not code/JSON
- Issue is in description extraction logic in `wsp-mobile/index.php`

**Example of problematic output:**
- Description: `[{"attrs": {"collapse":"false","section_text_style":"false","se...`
- Should be: `Firefighters for Christ International is a ministry...` (readable text)

**Root cause:**
- Description extraction logic (`wsp-mobile/index.php` lines 247-289) checks if `$rawValue` is a string
- When content is stored as Kirby blocks JSON, it's technically a string but contains structured data
- `strip_tags()` removes HTML tags but doesn't parse JSON blocks to extract text content
- The fallback block processing logic may not be executing properly for JSON string content

**Target:**
- Search result descriptions should display readable, user-friendly text previews
- Descriptions should extract text from Kirby blocks properly
- Descriptions should never show raw JSON or structured data
- Maintain performance optimizations from ticket 065

## Goals

1. **Fix Description Extraction**: Properly extract readable text from Kirby blocks/content
2. **Handle JSON Blocks**: Detect and parse Kirby blocks JSON to extract text content
3. **Fallback Strategy**: Ensure robust fallback when content structure is unknown
4. **Maintain Performance**: Keep description extraction fast (avoid expensive operations)
5. **Test Coverage**: Verify descriptions are readable for all content types

## Tasks

- [x] Investigate description extraction logic
  - [x] Test API endpoint with various queries to see actual description output
  - [x] Identify which content types produce JSON/structured data
  - [x] Review Kirby blocks structure and how to extract text properly
- [x] Fix description extraction for Kirby blocks
  - [x] Use existing `page_description` field (SEO meta description) instead of parsing blocks
  - [x] If no description exists, leave empty (clean fallback)
- [X] Test and verify fixes
  - [X] Test with queries that previously showed JSON (e.g., "bible", "firefighters")
  - [X] Verify descriptions are readable and user-friendly
  - [X] Test mobile app search UI displays descriptions correctly

## Solution (2026-01-10)

**Approach:** Use the existing `page_description` field instead of parsing Kirby blocks JSON.

**Why this works:**
- Pages already have a `Page-description` field containing human-written SEO meta descriptions
- This field is a simple string, no JSON parsing needed
- Zero performance impact (just reading a field value)
- Text is already curated by content authors

**Change made in `wsp-mobile/index.php`:**
```php
// Before: 40+ lines of complex block parsing that produced JSON gibberish
// After: Simple field read
$description = $page->content()->page_description()->value() ?? '';
```

**Commit:** `2b09b77` - Use page_description field for search results instead of parsing blocks

## Findings (2026-01-20)

### API Response Analysis

**Investigation Results:**
- Tested API endpoint with query "test" to examine description field content
- Example response for "Every Man a Warrior" saved to `/tmp/every-man-warrior-api-response.json`

**Key Finding:**
- The `description` field contains **raw JSON blocks data**, not readable text
- Description format: `[{"attrs":{"collapse":"false","section_text_style":"false","section_text_color":"#222222",...`
- Description is truncated at 150 characters (153 with "...")
- **There is no useful readable text in the description field** - it's entirely JSON structure/metadata
- The JSON appears to be Kirby blocks structure with attributes, but no actual content text is extracted
- **There is nothing useful in the description field** - it's pure JSON metadata with no extractable text content

**Example API Response:**
```json
{
  "uuid": "IpPXDuZKr3iawIQw",
  "title": "Every Man a Warrior",
  "description": "[{\"attrs\":{\"collapse\":\"false\",\"section_text_style\":\"false\",\"section_text_color\":\"#222222\",\"section_bg_style\":\"false\",\"section_bg_color\":\"#ffffff\",\"sec...",
  "url": "https://ffci.fiveq.dev/chapters/chapter-resources/every-man-a-warrior"
}
```

**Conclusion:**
- The description extraction logic in `wsp-mobile/index.php` is not properly parsing Kirby blocks to extract text content
- The API is returning raw JSON structure instead of readable text
- **There is nothing useful in the description field** - it's pure JSON metadata with no extractable text content
- **Next step: API change required** - Fix description extraction in `wsp-mobile/index.php` to properly extract text from Kirby blocks
- This must be fixed server-side - mobile app cannot fix this client-side as there's no readable text to extract from the JSON structure
- **Note:** API changes will be handled by a different agent

## Related

- **Ticket 065**: Optimize Search API Endpoint Performance (performance optimization completed)
- `wsp-mobile/index.php` (lines 247-289) - Description extraction logic (needs fixing)
- `wsp-mobile/index.php` (lines 166-235) - Search API endpoint implementation
- `rn-mip-app/app/search.tsx` - Mobile app search UI (displays descriptions)
- `rn-mip-app/lib/api.ts` - API client (receives search results)
- `/tmp/every-man-warrior-api-response.json` - Example API response with problematic description