---
status: cancelled
area: ios-mip-app
phase: core
created: 2026-03-14
---

# Prioritize Upcoming Events and Featured Chapter Above the Fold

## Context

Client feedback requested that the app launch emphasize the most important ministry
sections immediately on first load. The current Home screen lead sequence does not
surface `Upcoming Events` and `Featured Chapter` as the first highly visible blocks.

## Goals

1. Make `Upcoming Events` the first prominent featured block on Home.
2. Make `Featured Chapter` the second prominent featured block on Home.
3. Keep the remaining featured/home content available without breaking existing behavior.

## Acceptance Criteria

- On app launch, Home shows `Upcoming Events` first and `Featured Chapter` second in
  the top visible featured sequence.
- These two sections are visible without initial scrolling on the standard iOS
  simulator used for ticket verification.
- Tapping each block still routes to the expected destination content.
- Other Home sections still render and remain navigable after reordering.

## Notes

- Source request: Mike Bell (Firefighters for Christ International), 2026-03-14.
- If either section has no content, the UI should fail gracefully and preserve layout.
- Cancelled by product direction: featured order should be controlled in Kirby panel
  content configuration, not hardcoded in iOS app logic.

## References

- Existing home layout work: `tickets/069-homepage-layout-redesign.md`
- Existing featured section content work: `tickets/056-homepage-featured-section-content.md`
