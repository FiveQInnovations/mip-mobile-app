---
status: backlog
area: rn-mip-app
phase: c4i
created: 2026-01-02
---

# Native Video Player Component

## Context
The spec requires native video playback using react-native-video or Expo AV for direct video URLs. This provides an "app-like" experience that helps with App Store approval (Apple Guideline 4.2) and better performance than web embeds.

C4I is video-focused with the TV show "Israel: The Prophetic Connection" with seasons/episodes.

## Tasks
- [ ] Choose video library (react-native-video vs Expo AV)
- [ ] Install and configure video player library
- [ ] Create VideoPlayer component with standard controls
- [ ] Handle direct video URLs from collection items
- [ ] Add loading states and error handling
- [ ] Test on iOS and Android devices
- [ ] Support fullscreen playback

## Notes
- Per spec: "Video: Native video player (react-native-video or Expo AV)"
- YouTube/Vimeo URLs handled separately in ticket 022
- Related to Firebase analytics events (video_play, video_complete) in ticket 029
