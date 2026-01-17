---
status: in-progress
area: rn-mip-app
phase: nice-to-have
created: 2026-01-17
---

# Content Page Visual Design Improvements

## Context

Current content pages (e.g., "About Us", "Core Policies") render HTML content but the visual presentation feels basic and needs "sprucing up". Specifically, headings within the HTML content do not have a distinct enough look from the body text.

## Goals

1. Improve the overall visual design and "feel" of content-heavy pages.
2. Define distinct, attractive styles for HTML headings (H1, H2, H3, etc.).
3. Consult with a designer to develop a more polished UI for long-form content.

## Acceptance Criteria

- HTML headings have clear typographic hierarchy and distinct styling.
- Content pages feel modern, readable, and visually aligned with the rest of the app.
- Layout and spacing (padding, line height) are optimized for mobile reading.
- Design improvements are implemented based on consultation with a designer.

## Notes

- This ticket requires design input before implementation begins.
- Check how `react-native-render-html` (or equivalent) is currently configured and how styles are being applied to tags.

## References

- [Ticket #059](059-internal-page-visual-design.md) - Related internal page improvements
- `rn-mip-app/src/components/ContentPage.tsx` (or similar component)
