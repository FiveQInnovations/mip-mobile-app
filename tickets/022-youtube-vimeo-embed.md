---
status: backlog
area: rn-mip-app
created: 2026-01-02
---

# YouTube/Vimeo Embed Support

## Context
The spec requires support for YouTube and Vimeo video URLs, either via WebView or react-native-youtube-iframe. Many ministry videos are hosted on these platforms rather than as direct video files.

## Tasks
- [ ] Detect YouTube/Vimeo URLs in video content
- [ ] Choose embed approach (WebView vs react-native-youtube-iframe)
- [ ] Install required library if using react-native-youtube-iframe
- [ ] Create embed component for YouTube/Vimeo videos
- [ ] Handle video playback controls and fullscreen
- [ ] Test on iOS and Android devices

## Notes
- Per spec: "Support YouTube/Vimeo URLs (via WebView or react-native-youtube-iframe)"
- Different from native video player for direct URLs (ticket 021)
- Consider whether to use same component with URL detection
