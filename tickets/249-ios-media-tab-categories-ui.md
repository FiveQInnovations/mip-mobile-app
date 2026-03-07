---
status: backlog
area: ios-mip-app
phase: core
created: 2026-03-07
---

# Implement Media Categories UI on iOS

## Context

Ticket `235-media-tab-categories` is complete for Kirby category definitions and
Android category rendering, including 3-item category previews and
expand/collapse behavior.

The iOS app still shows a flatter Media Resources experience and needs the same
category-first structure so users can browse by category before drilling into
messages.

## Goals

1. Render Media Resources in iOS grouped by category (not a single flat list)
2. Match Android behavior with a 3-item preview per category and per-category
   expand/collapse
3. Improve visual hierarchy so category headers are clearly distinct from
   message rows

## Acceptance Criteria

- [ ] Media tab in `ios-mip-app` shows Media Resources grouped by category
- [ ] Each category displays up to 3 messages by default
- [ ] Each category supports `Show all` and `Show less`
- [ ] Message taps still navigate to the correct message detail page
- [ ] Category headers are visually distinct from message rows
- [ ] No regression in message detail content rendering

## Notes

- Reuse API category fields already introduced for mobile category support
- Keep behavior aligned with Android implementation to reduce cross-platform UX
  drift
- If API gaps are discovered during iOS implementation, document them before
  changing backend behavior

## References

- Parent ticket: `tickets/235-media-tab-categories.md`
- Android implementation reference:
  `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/screens/TabScreen.kt`
- iOS app codebase: `ios-mip-app/`
