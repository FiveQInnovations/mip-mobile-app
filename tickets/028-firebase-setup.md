---
status: backlog
area: rn-mip-app
created: 2026-01-02
---

# Firebase Analytics Setup

## Context
The spec requires Firebase Analytics for tracking user behavior. Each site needs its own Firebase configuration. This is required for production and helps understand how users interact with the app.

## Tasks
- [ ] Create Firebase project for FFCI (or add apps to existing project)
- [ ] Add iOS app with bundle ID to Firebase
- [ ] Add Android app with package name to Firebase
- [ ] Download config files (GoogleService-Info.plist, google-services.json)
- [ ] Install @react-native-firebase/app and @react-native-firebase/analytics
- [ ] Configure Expo to include Firebase config files
- [ ] Initialize Firebase in app entry point
- [ ] Test analytics events appear in Firebase console

## Notes
- Per spec: Firebase Analytics is required
- Config should be per-site (FFCI, C4I have separate Firebase configs)
- Five Q will own Firebase projects long-term
- See Appendix B in spec for Firebase setup checklist
