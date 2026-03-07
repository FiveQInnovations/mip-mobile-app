---
status: in-progress
area: general
phase: core
created: 2026-01-29
---

# Update Media Tab to Show Categories

## Context

From FFCI App Build Review meeting (Jan 29, 2026). Media tab should display categories (e.g., Encouragement, Marriage) and include a 'Files of the Month' category.

## Goals

1. Update Media tab to show categories from website collection
2. Add 'Files of the Month' category
3. Ensure category navigation works smoothly

## Acceptance Criteria

- Media tab displays categories from website Media Resources collection
- 'Files of the Month' category is available
- Users can navigate between categories
- Category structure matches website organization

## Progress

### Kirby CMS (ws-ffci) — Complete
Categories defined in `audio-collection.txt` (custom, not global):

| Category | Slug |
|----------|------|
| Files of the Month | `files-of-the-month` |
| Marriage & Family | `marriage-family` |
| Evangelism & Faith | `evangelism-faith` |
| Firefighters | `firefighters` |
| Christian Living | `christian-living` |
| Missions | `missions` |

All 23 media entries have been assigned a category in their `audio-item.txt` files and pushed to `ws-ffci` master.

Category-to-entry mapping documented in `temp/media-category-mapping.md`.

### App (ios-mip-app / android-mip-app) — Pending
- Media tab needs to read and display categories from the API
- Category navigation UI needs to be implemented

## Notes

- Categories come from website's Media Resources collection (custom per-collection, not global)
- `Custom-categories: true` is set on the Media Resources collection
- Category field in audio-item.txt is a plain slug string (e.g., `Categories: evangelism-faith`)
- Featured section can highlight collections or specific items
- Part of media organization improvements

## References

- Meeting: `meetings/ffci-app-build-review-jan-29.md` (00:16:41)
- Category mapping: `temp/media-category-mapping.md`
