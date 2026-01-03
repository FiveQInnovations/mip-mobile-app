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
- [ ] Create design mockups or sketches for proposed changes
- [ ] Implement header/banner improvements
- [ ] Enhance collection item cards
- [ ] Test visual changes on iOS and Android

## Notes

- Keep changes lightweight—avoid overcomplicating the component structure
- Ensure accessibility is maintained (contrast ratios, touch targets)
- Consider what data is available from the API (cover images, descriptions, etc.)
