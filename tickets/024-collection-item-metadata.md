---
status: backlog
area: rn-mip-app
phase: c4i
created: 2026-01-02
---

# Display Video/Audio Metadata on Collection Items

## Context
Collection items should display more than just titles. The spec indicates collection items should show cover image, title, and date/episode number. This is especially important for C4I's TV show with seasons and episodes.

## Tasks
- [ ] Update collection item rendering to show cover image thumbnails
- [ ] Display episode number and series information
- [ ] Show date or publication info where available
- [ ] Style collection items with proper layout (image + text)
- [ ] Handle missing metadata gracefully

## Notes
- Per spec: "Display: cover image, title, date/episode number"
- API already returns `episode`, `series`, and `cover` fields per spec example
- Related to ticket 025 (Collection cover images)
