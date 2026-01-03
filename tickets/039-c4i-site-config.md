---
status: backlog
area: rn-mip-app
phase: c4i
created: 2026-01-02
---

# Create C4I Site Configuration

## Context
The spec mentions two initial clients: FFCI and C4I. C4I is a video-focused ministry with the TV show "Israel: The Prophetic Connection" with seasons/episodes. The homepage is likely "collection" type showing latest videos.

## Tasks
- [ ] Create `configs/c4i.json` configuration file
- [ ] Get C4I API URL and token from Five Q
- [ ] Configure C4I branding (colors, logo)
- [ ] Set bundle IDs and package names for C4I
- [ ] Configure homepage type (likely "collection")
- [ ] Test app loads C4I content correctly

## Notes
- Per spec: "C4I (ws-c4i) - Video-focused ministry content"
- Homepage likely "collection" type showing latest videos
- Season filtering in collections (already implemented in web)
- Requires C4I site to have mobile API enabled
