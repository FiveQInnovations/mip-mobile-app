---
status: done
area: rn-mip-app
phase: core
created: 2026-01-23
---

# Tab Screen Headers Don't Respect Safe Area Insets

## Context

The main tab screens (Resources, Chapters, Connect) have their header titles overlapping with the iOS status bar. The title text renders directly under the device notch/time display instead of below the safe area.

This is a follow-up from ticket 057 which fixed safe area issues for internal page navigation, but the fix did not cover the top-level tab screen headers.

## Problem

On iOS devices with notches/dynamic island:
- **Chapters tab**: "Chapters" title overlaps with status bar
- **Resources tab**: Header content overlaps with status bar  
- **Connect tab**: Same issue

However, child pages (like "Chaplain Resources") correctly respect the safe area because they use the `PageScreen` component with proper insets.

## Goals

1. Apply safe area insets to all tab screen headers
2. Ensure consistent header positioning across all tabs

## Acceptance Criteria

- [ ] Chapters tab title is positioned below the safe area
- [ ] Resources tab header is positioned below the safe area
- [ ] Connect tab header is positioned below the safe area
- [ ] Home tab header (if any) is positioned correctly
- [ ] No regression on child page screens (should remain correct)

## Technical Notes

- Ticket 057 added `paddingTop: insets.top` to `TabNavigator.tsx` but this may not be applying to the right container
- Child pages work correctly, so the fix pattern exists - need to apply it to tab screen containers

## Related Tickets

- Ticket 057: Header Should Respect Safe Area Insets (predecessor)
