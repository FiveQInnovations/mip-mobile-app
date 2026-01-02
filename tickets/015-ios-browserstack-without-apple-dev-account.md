---
status: backlog
area: rn-mip-app
created: 2026-01-21
---

# Build and Upload iOS to BrowserStack Without Apple Developer Account

## Context
Need to build and upload iOS apps to BrowserStack for testing without requiring an official Apple Developer Account. Currently blocked on iOS builds due to Apple Developer Account access (see ticket 003). Need to explore alternative approaches or workarounds that BrowserStack might support.

## Tasks
- [ ] Research BrowserStack iOS upload requirements and limitations
- [ ] Investigate if BrowserStack supports unsigned or ad-hoc signed iOS builds
- [ ] Check if EAS can build iOS without Apple Developer Account (development builds)
- [ ] Explore Expo development builds for iOS (may not require paid Apple Developer Account)
- [ ] Research if BrowserStack accepts TestFlight builds or other distribution methods
- [ ] Test building iOS development build via EAS without Apple Developer credentials
- [ ] Verify if BrowserStack App Live API accepts unsigned iOS builds
- [ ] Document findings and any workarounds discovered
- [ ] Compare with Android workflow to identify differences

## Notes

