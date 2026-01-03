---
status: backlog
area: rn-mip-app
phase: core
created: 2026-01-03
---

# Internal Page Visual Design Improvements

## Context

Internal pages like Resources currently have minimal styling—plain white backgrounds, basic text, and simple list items. While functional, they lack visual distinction and feel less polished compared to the HomeScreen. Users should feel engaged when browsing content.

## Current State

- `TabScreen.tsx` renders pages with:
  - Plain white background
  - Simple title text
  - Basic collection items (gray boxes with text)
  - No visual hierarchy beyond font sizes
- No use of brand colors beyond loading indicator
- Collection items are visually identical regardless of content type

---

## Scouting Findings (2026-01-03)

### Architecture Insight: Content vs. Collection Pages

**Most pages are content pages, not collections.** The Resources page, for example, is a `content` page where the visual layout is defined by HTML from Kirby CMS and rendered via `HTMLContentRenderer`. The "cards" with images, buttons, and descriptions are all part of the HTML content.

This means:
- **HTMLContentRenderer is already doing heavy lifting** for content pages
- **TabScreen collection rendering** only applies to actual collection-type pages (like Events, Chapters)
- The visual polish gap is primarily in **collection item cards** and **general chrome** (headers, back button)

### What TabScreen Controls

1. **Loading state** - ActivityIndicator with primaryColor
2. **Back navigation button** - Simple text "← Back" on gray background  
3. **Cover image display** - Already supported if API provides `cover`
4. **Page title** - 24pt bold
5. **Collection item cards** - Gray boxes with title text only

### API Data Gap for Collections

The `wsp-mobile` plugin's `collection_data()` function returns minimal child data:

```php
// Current: Only uuid, type, url
"children" => $page->children()->map(function ($item) {
    return [
        "uuid" => $item->uuid()->id(),
        "type" => $item->intendedTemplate()->name(),
        "url" => $item->url()
    ];
})->data()
```

**Missing from children:**
- `title` - The child page's title
- `cover` - Cover image URL (available via `cover_image()`)
- `description` - Page description or excerpt

**Recommendation:** Enhance API to include title and cover for children items before implementing thumbnails in the app.

### Established Design Patterns (from HomeScreen/ErrorScreen)

Already implemented patterns that should be reused:

| Pattern | Values |
|---------|--------|
| Card border | `borderRadius: 12`, `borderWidth: 1`, `borderColor: '#e5e7eb'` |
| Card shadow | `shadowColor: '#000'`, `shadowOpacity: 0.04`, `shadowRadius: 4` |
| Section header | `fontSize: 20`, `fontWeight: '700'`, `color: '#0f172a'` |
| Body text | `fontSize: 16`, `color: '#475569'` |
| Primary action | Uses `config.primaryColor` for buttons |

### Config Colors Available

From `configs/ffci.json`:
- `primaryColor: "#D9232A"` (red)
- `secondaryColor: "#024D91"` (blue)
- `textColor: "#0f172a"` (dark slate)
- `backgroundColor: "#f8fafc"` (light gray)

### Reusability Considerations

Since this app is a **template for multiple ministries**:
1. All colors must come from config, not hardcoded FFCI values
2. Design patterns should work with any color scheme
3. Consider extracting shared card component
4. Content type icons could map template types (video-item → 🎬, etc.)

---

## Prioritized Implementation Plan

### Phase 1: Low-Effort, High-Impact (App Only)

These require no API changes:

1. **Back button styling**
   - Add chevron icon instead of text arrow
   - Use primaryColor accent
   - Match HomeScreen row styling

2. **Collection item cards**
   - Apply HomeScreen card styling (shadows, borders, radius)
   - Add content type emoji based on `type` field
   - Better padding and touch feedback

3. **Page header banner**
   - Subtle colored bar or gradient using primaryColor
   - Better title typography

4. **Loading state**
   - Replace spinner with skeleton placeholder
   - Show content shape while loading

### Phase 2: Requires API Enhancement

1. **Collection item thumbnails**
   - Need API to return `cover` in children array
   - Display thumbnail on left side of card
   - Fallback to content type icon when no image

2. **Collection item descriptions**
   - Need API to return `title` and optionally `description`
   - Show 1-2 line preview text

### API Changes Required (wsp-mobile)

Update `collection_data()` in `lib/pages.php`:

```php
"children" => $page->children()->map(function ($item) {
    return [
        "uuid" => $item->uuid()->id(),
        "type" => $item->intendedTemplate()->name(),
        "title" => $item->title()->value(),
        "cover" => $this->cover_image($item),
        "url" => $item->url()
    ];
})->data()
```

---

## Design Ideas to Explore

### Headers & Branding
- [ ] Add a subtle header bar with the page title and brand color accent
- [ ] Use site's primary color for section dividers or accents
- [ ] Consider a gradient or colored banner at the top of collection pages

### Collection Items
- [ ] Add thumbnail images for collection items (if available from API)
- [ ] Use cards with shadows for better visual separation
- [ ] Add icons or visual indicators for content types (PDF, video, article)
- [ ] Implement alternating backgrounds or subtle borders

### Typography & Spacing
- [ ] Improve typography hierarchy (title, subtitle, body)
- [ ] Add more generous padding and margins
- [ ] Use consistent spacing rhythm throughout

### Visual Polish
- [ ] Add subtle animations on tap (press feedback)
- [ ] Consider skeleton loading states instead of spinner
- [ ] Add dividers or section separators for long lists

## Tasks

- [ ] Review current screens and identify highest-impact improvements
- [x] Research architecture and available data (scouting complete)
- [ ] Enhance API: Add title/cover to collection children (wsp-mobile)
- [ ] Apply HomeScreen card styles to collection items
- [ ] Add content type icons based on template type
- [ ] Improve back button styling
- [ ] Add header/banner with primaryColor
- [ ] Implement skeleton loading states
- [ ] Test visual changes on iOS and Android

## Notes

- Keep changes lightweight—avoid overcomplicating the component structure
- Ensure accessibility is maintained (contrast ratios, touch targets)
- Most visual richness for content pages comes from HTML, not app styling
- Collection pages are the main focus for app-side visual improvements
- All colors must use config values for multi-ministry reusability
