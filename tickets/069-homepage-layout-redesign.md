---
status: qa
area: rn-mip-app
phase: core
created: 2026-01-16
---

# Homepage Layout Redesign - Flip Featured/Evergreen Sections

## Context

From the Jan 13, 2026 meeting with Mike Bell, the homepage layout needs to be redesigned. Currently, the layout has Evergreen content (core resources) at the top and Featured content below. This should be flipped so Featured content is at the top (for fresh/promotional content) and Evergreen content is below (for static core resources).

## Goals

1. Flip the homepage layout to put Featured content at the top
2. Keep Evergreen content below for familiar navigation
3. Maintain responsive design on mobile devices

## Acceptance Criteria

- Featured hero section displays at the top with fresh/promotional content
- Evergreen section with core resources displays below
- Layout maintains responsive design on mobile devices

## Notes

- This mirrors the supermarket "end cap" analogy Mike mentioned - new stuff at top, familiar navigation below
- Aligns with user expectations from existing FFCI app experience
- This was a key feedback item from the Jan 13 meeting

## References

- Meeting transcript: meetings/ffci-app-build-review-jan-13.md

---

## Research Findings (Scouted)

### Current Layout Analysis

The homepage is implemented in `rn-mip-app/components/HomeScreen.tsx`. Current order:

1. **Logo Section** (Hero) - lines 176-194
2. **Horizontal Scroll** with `quickTasks` (Evergreen content) - lines 196-214
3. **"Featured" Section Header** + vertical list with `featuredItems` - lines 216-233
4. Dev Tools section (temporary)

### Implementation Plan

**This is a frontend-only change** - no backend/API modifications needed.

The API (`wsp-mobile/lib/site.php`) already provides both data sets:
- `homepage_quick_tasks` → Evergreen content (core resources)
- `homepage_featured` → Featured content (fresh/promotional)

**Required changes in `HomeScreen.tsx`:**

1. Move the Featured section (lines 216-233) above the horizontal scroll section (lines 196-214)
2. Rename "Featured" header to something clearer (or keep as-is per stakeholder preference)
3. Consider renaming/relabeling the Evergreen section with a header (currently has no header)

### Proposed New Layout Order

```
1. Logo Section (Hero) - keep as-is
2. Featured Section (vertical cards) - MOVED UP
   - Title: "Featured" (or "What's New")
   - Full-width cards with badges
3. Evergreen Section (horizontal scroll) - MOVED DOWN
   - Consider adding section header like "Resources" or "Quick Access"
   - Horizontal scrolling cards
4. Dev Tools (temporary)
```

### Code Locations

| File | Purpose |
|------|---------|
| `rn-mip-app/components/HomeScreen.tsx` | Main homepage layout - **EDIT HERE** |
| `rn-mip-app/lib/api.ts` | API types (no changes needed) |
| `wsp-mobile/lib/site.php` | Backend API (no changes needed) |
| `wsp-mobile/blueprints/tabs/mobile.yml` | Kirby Panel config (no changes needed) |

### Variables Reference

- `featuredItems` - Array of Featured content items (from `homepage_featured` API)
- `quickTasks` - Array of Evergreen content items (from `homepage_quick_tasks` API)

### Estimated Complexity

**Low** - Simple JSX reordering, ~10-15 lines of code movement