---
status: backlog
area: ios-mip-app
phase: production
created: 2026-01-02
---

# Firebase Analytics Setup (iOS)

## Context

The spec requires Firebase Analytics for tracking user behavior. Each site needs its own Firebase configuration. This ticket covers the **native iOS app** (`ios-mip-app`); Android will be handled separately later.

## Tasks

- [ ] Create Firebase project for FFCI (or add apps to existing project)
- [ ] Add iOS app with bundle ID (`com.fiveq.ffci` or as configured) to Firebase
- [ ] Download `GoogleService-Info.plist` and add it to the Xcode project
- [ ] Add Firebase iOS SDK (Swift Package Manager or CocoaPods per project convention)
- [ ] Initialize Firebase in the app entry point (e.g. `FFCIApp` / `@main`)
- [ ] Test that the app builds and analytics sessions appear in the Firebase console

## Notes

- Per spec: Firebase Analytics is required for production
- Config should be per-site (FFCI, C4I have separate Firebase configs when multi-site ships)
- Five Q will own Firebase projects long-term
- See Appendix B in spec for Firebase setup checklist
- **React Native / Expo** (`rn-mip-app`) is out of scope for this ticket
