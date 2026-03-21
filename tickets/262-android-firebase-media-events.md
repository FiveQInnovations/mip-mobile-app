---
status: backlog
area: android-mip-app
phase: c4i
created: 2026-03-21
---

# Firebase Media Events (Android): video_play, video_complete, audio_play

## Context

The spec requires media playback analytics. This ticket covers **android-mip-app**, parallel to ticket 030 (RN / legacy scope) and timed similarly after native video/audio work.

## Tasks

- [ ] Track `video_play` when in-app video playback starts (when a native or embedded video path exists)
- [ ] Track `video_complete` when playback reaches natural end
- [ ] Track `audio_play` when audio playback starts (`AudioPlayer` / ExoPlayer)
- [ ] Include useful metadata (content id, title, duration when available)
- [ ] Verify events in the Firebase console

## Notes

- Depends on ticket **259** (Android Firebase setup)
- Depends on native Android audio/video UI (e.g. [023](023-audio-player-component.md)) when applicable
- Per spec: `video_play`, `video_complete`, `audio_play`
- **C4I phase** matches ticket 030; ship after FFCI launch if product confirms priority

## References

- `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/AudioPlayer.kt`
- Ticket [030](030-firebase-media-events.md) (original spec reference)
