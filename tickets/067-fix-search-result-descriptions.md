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

- [ ] Investigate description extraction logic
  - [ ] Test API endpoint with various queries to see actual description output
  - [ ] Identify which content types produce JSON/structured data
  - [ ] Review Kirby blocks structure and how to extract text properly
- [ ] Fix description extraction for Kirby blocks
  - [ ] Detect when content is Kirby blocks JSON (even if stored as string)
  - [ ] Parse blocks JSON and extract text from text blocks
  - [ ] Handle different block types (text, heading, list, etc.)
  - [ ] Ensure proper text extraction without showing JSON structure
- [ ] Improve fallback logic
  - [ ] Ensure block processing path executes when needed
  - [ ] Add better detection of structured vs plain text content
  - [ ] Handle edge cases (empty content, malformed blocks, etc.)
- [ ] Optimize text extraction
  - [ ] Extract text efficiently without expensive operations
  - [ ] Consider using Kirby's built-in text extraction methods
  - [ ] Maintain performance targets (< 1s total API response)
- [ ] Test and verify fixes
  - [ ] Test with queries that previously showed JSON (e.g., "bible", "firefighters")
  - [ ] Verify descriptions are readable and user-friendly
  - [ ] Test with various content types (pages, sections, etc.)
  - [ ] Verify API performance is still fast
  - [ ] Test mobile app search UI displays descriptions correctly

## Related

- **Ticket 065**: Optimize Search API Endpoint Performance (performance optimization completed)
- `wsp-mobile/index.php` (lines 247-289) - Description extraction logic (needs fixing)
- `wsp-mobile/index.php` (lines 166-235) - Search API endpoint implementation
- `rn-mip-app/app/search.tsx` - Mobile app search UI (displays descriptions)
- `rn-mip-app/lib/api.ts` - API client (receives search results)
