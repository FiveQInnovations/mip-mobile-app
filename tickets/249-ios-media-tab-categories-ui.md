---
status: qa
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

---

## Research Findings (Scouted)

### Cross-Platform Reference (Android parity)
- Android category UI behavior is implemented in `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/screens/TabScreen.kt` (state + rendering around ~L58-L89, ~L131-L150, ~L240-L323):
  - `CATEGORY_PREVIEW_COUNT = 3`
  - Per-category section rendering with header + message count
  - Per-category `Show all (N more)` / `Show less`
  - Expanded state tracked by `expandedCategorySlugs`
- Android category data parsing is implemented in `android-mip-app/app/src/main/java/com/fiveq/ffci/data/api/ApiModels.kt` (~L68-L73, ~L92-L93, ~L103-L104, ~L162-L200):
  - `CollectionChild.categorySlug` from `category_slug`
  - `PageData.categoryDefinitions` from structured `categories` and fallback parsing
  - `PageData.categorySlug` for child-page fallback

### Current Implementation Analysis
- iOS media collection rendering is currently a flat list in `ios-mip-app/FFCI/Views/TabPageView.swift` (collection block at ~L73-L81), using:
  - `CollectionListView(items: children, onItemClick: ...)`
  - no category grouping, no preview limit, no expand/collapse state.
- iOS data models in `ios-mip-app/FFCI/API/ApiModels.swift` currently do not expose the category fields used by Android parity logic:
  - `CollectionChild` (~L170-L175) has no `categorySlug`
  - `PageData` (~L177-L196) has no decoded `categories` field
  - `PageDataContent` (~L154-L167) has no `categories` raw field / nested content fallback.
- Navigation behavior for message taps is already correct in `TabPageView.navigateToPage(uuid:)` (~L197-L201); grouped rows should continue to call this same path.

### Implementation Plan
1. **Add category-capable decoding in iOS API models**
   - In `ios-mip-app/FFCI/API/ApiModels.swift`, add:
     - `CategoryDefinition` model
     - `CollectionChild.categorySlug` (`category_slug`)
     - `PageData.categories` and helpers for `categoryDefinitions`
     - `PageDataContent.categories` (+ nested content fallback if needed for item-level slug recovery).
2. **Port Android grouping state to iOS TabPageView**
   - In `ios-mip-app/FFCI/Views/TabPageView.swift`, add state for:
     - `mediaSections`
     - `isLoadingMediaSections`
     - `expandedCategorySlugs`
   - Build category sections when the loaded page is Media Resources collection (`collection` + `audio` + categories present).
3. **Render category-first UI with 3-item preview**
   - Replace the flat collection block with per-category sections:
     - category header visually distinct from rows
     - default visible rows = first 3 items
     - per-category `Show all` / `Show less` toggle
     - keep row taps wired to existing `navigateToPage`.
4. **Maintain parity fallback behavior**
   - If category grouping data is unavailable, preserve current flat `CollectionListView` rendering to avoid regressions.

### Code Locations

| File | Purpose |
|------|---------|
| `ios-mip-app/FFCI/Views/TabPageView.swift` | **Primary change target** for grouped category UI, 3-item preview, and per-category expand/collapse state/interaction. |
| `ios-mip-app/FFCI/API/ApiModels.swift` | **Primary change target** for category field decoding and helper accessors needed by grouping logic. |
| `ios-mip-app/FFCI/Views/CollectionListView.swift` | Reused row renderer for message items; likely no functional changes required. |
| `ios-mip-app/FFCI/Data/PageCache.swift` | Reused if child-page fetch fallback is needed for missing category slugs; no schema/UI changes expected. |
| `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/screens/TabScreen.kt` | Android parity reference for UI behavior and state model. |
| `android-mip-app/app/src/main/java/com/fiveq/ffci/data/api/ApiModels.kt` | Android parity reference for category parsing strategy and fallbacks. |

### Variables/Data Reference
- `CollectionChild.categorySlug` (`category_slug`) - preferred per-item category mapping.
- `PageData.categories` / `PageData.categoryDefinitions` - category ordering + labels for section headers.
- `PageData.categorySlug` (child-page fallback) - used when a child entry lacks `category_slug`.
- `mediaSections` - grouped `[category -> items]` view model in iOS.
- `expandedCategorySlugs` - per-category expand/collapse state.
- `CATEGORY_PREVIEW_COUNT` (target parity value: `3`).

### Estimated Complexity
**Medium.** UI changes are straightforward, but parity depends on adding/normalizing category decoding in iOS models and handling fallback mapping for missing child category slugs without regressing existing collection navigation.
