---
status: backlog
area: rn-mip-app
created: 2026-01-02
---

# Audio Player Component

## Context
The spec requires an audio player with controls for podcast and audio content. C4I has an audio collection with podcast content. The player should provide platform-appropriate native UI.

## Tasks
- [ ] Create AudioPlayer component using Expo AV or similar
- [ ] Implement playback controls (play, pause, seek, volume)
- [ ] Display audio metadata (title, duration, progress)
- [ ] Handle audio URLs from collection items
- [ ] Add loading states and error handling
- [ ] Test on iOS and Android devices

## Notes
- Per spec: "Audio: Audio player with controls"
- Background playback is nice-to-have for v1, not required
- Related to Firebase analytics events (audio_play) in ticket 029
