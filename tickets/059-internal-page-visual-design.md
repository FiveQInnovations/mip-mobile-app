---
status: done
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

---

## Implementation Plan (v1)

Focus on chrome and HTML rendering improvements (no collection enhancements in v1):

### 1. Back button styling
- Add chevron icon instead of text arrow
- Use primaryColor accent
- Match HomeScreen row styling

### 2. Page header/title area
- Subtle colored bar or gradient using primaryColor
- Better title typography with brand accent

### 3. HTMLContentRenderer enhancements
Content pages like Resources get their visual richness from HTML. Enhance the tag styles:

**Current state** (hardcoded colors):
- Headings use `color: '#333'`
- Blockquote has `borderLeftColor: '#ddd'`
- Links use `config.primaryColor` ✓

**Proposed changes**:
- **Headings (h1-h4)** - Use `config.textColor` or `config.secondaryColor` for brand consistency
- **Blockquotes** - Use `config.primaryColor` for left border, subtle background tint
- **Spacing** - Slightly more generous margins between sections
- **HR/dividers** - If present, use primaryColor accent

### 4. Loading state
- Replace spinner with skeleton placeholder
- Show content shape while loading

---

## Design Ideas to Explore

### Headers & Branding
- [ ] Add a subtle header bar with the page title and brand color accent
- [ ] Use site's primary color for section dividers or accents
- [ ] Consider a gradient or colored banner at the top of collection pages

### Collection Items (deferred to v2)
- Collection item thumbnails and descriptions require API enhancements
- Not in scope for v1

### Typography & Spacing
- [ ] Improve typography hierarchy (title, subtitle, body)
- [ ] Add more generous padding and margins
- [ ] Use consistent spacing rhythm throughout

### Visual Polish
- [ ] Add subtle animations on tap (press feedback)
- [ ] Consider skeleton loading states instead of spinner
- [ ] Add dividers or section separators for long lists

## Tasks

- [x] Research architecture and available data (scouting complete)
- [x] Improve back button styling (chevron icon, primaryColor accent)
- [x] Add header/banner with primaryColor
- [x] Enhance HTMLContentRenderer tag styles (headings, blockquotes, spacing)
- [x] Implement skeleton loading states
- [x] Test visual changes on iOS (Maestro tests pass)

## Notes

- Keep changes lightweight—avoid overcomplicating the component structure
- Ensure accessibility is maintained (contrast ratios, touch targets)
- Most visual richness for content pages comes from HTML, not app styling
- Collection enhancements (thumbnails, descriptions) deferred to v2 (requires API changes)
- All colors must use config values for multi-ministry reusability
