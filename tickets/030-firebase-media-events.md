---
status: backlog
area: rn-mip-app
created: 2026-01-02
---

# Firebase Media Events (video_play, video_complete, audio_play)

## Context
The spec requires tracking media playback analytics events. These help understand which videos and audio content users engage with most.

## Tasks
- [ ] Track `video_play` event when video playback starts
- [ ] Track `video_complete` event when video watched to end
- [ ] Track `audio_play` event when audio playback starts
- [ ] Include relevant metadata (content ID, title, duration)
- [ ] Integrate events into video and audio player components
- [ ] Test events appear in Firebase console

## Notes
- Depends on ticket 028 (Firebase setup)
- Depends on ticket 021 (Native video player) and ticket 023 (Audio player)
- Per spec required events: `video_play`, `video_complete`, `audio_play`
