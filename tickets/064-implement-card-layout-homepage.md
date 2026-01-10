---
status: in-progress
area: rn-mip-app
phase: nice-to-have
created: 2026-01-20
---

# Implement Card Component Layout on Homepage

## Context

Based on research from ticket 062, the existing Firefighters for Christ app uses a card-based content layout with large, image-forward cards. The `ContentCard` component has been implemented, but the homepage layout needs to be updated to fully utilize this card-based design pattern.

## Goals

1. **Enhance Card Layout**: Update the homepage to use the card-based layout observed in the existing FFCI app screenshots (e.g., `screenshot-09.png`).
2. **Image-Forward Design**: Ensure cards prioritize large, prominent images over text-heavy layouts.
3. **Visual Consistency**: Replace any remaining grid/list text-heavy layouts with visual cards throughout the homepage.

## Tasks

- [ ] Review existing `ContentCard` component implementation
- [ ] Analyze current `HomeScreen` layout and identify areas for improvement
- [ ] Update card styling to match image-forward design (larger images, better visual hierarchy)
- [ ] Ensure Quick Tasks section uses card layout effectively
- [ ] Ensure Featured section uses card layout effectively
- [ ] Test card layout on both iOS and Android
- [ ] Update Maestro tests if needed for new card layout

## Related

- **Ticket 062**: Research and Mimic Existing FFCI App Design (source of design reference)
- `rn-mip-app/components/ContentCard.tsx` - Card component implementation
- `rn-mip-app/components/HomeScreen.tsx` - Homepage implementation
