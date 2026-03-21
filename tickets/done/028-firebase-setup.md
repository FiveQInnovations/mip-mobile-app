---
status: done
area: ios-mip-app
phase: production
created: 2026-01-02
---

# Firebase Analytics Setup (iOS)

## Context

The spec requires Firebase Analytics for tracking user behavior. Each site needs its own Firebase configuration. This ticket covers the **native iOS app** (`ios-mip-app`); Android will be handled separately later.

## Tasks

- [x] Create Firebase project for FFCI (or add apps to existing project)
- [x] Add iOS app with bundle ID (`com.fiveq.ffci` or as configured) to Firebase
- [x] Download `GoogleService-Info.plist` and add it to the Xcode project
- [x] Add Firebase iOS SDK (Swift Package Manager or CocoaPods per project convention)
- [x] Initialize Firebase in the app entry point (e.g. `FFCIApp` / `@main`)
- [x] Verify analytics sessions appear in the Firebase console / GA4 during QA

## Project changes (`ios-mip-app`)

Changes required so events reach **Firebase Analytics → DebugView** (and production GA4):

1. **`FFCI.xcodeproj/xcshareddata/xcschemes/FFCI.xcscheme`** (shared scheme)  
   - Run action: launch argument **`-FIRDebugEnabled`** so the SDK streams to DebugView during development.

2. **`FFCI/GoogleService-Info.plist`** and **`FFCI/GoogleService-Info-com-fiveq-ffci.plist`**  
   - **`IS_ANALYTICS_ENABLED`**: was **`false`** (blocked all analytics); set to **`true`**.

3. **`FFCI/FFCIApp.swift`**  
   - **`import FirebaseAnalytics`**  
   - After **`FirebaseApp.configure()`**, call **`Analytics.setAnalyticsCollectionEnabled(true)`** so collection stays on even if a future plist ships with analytics disabled.

**QA tip:** From Terminal, **`simctl launch`** treats **`-F`** as its own flag—use  
`xcrun simctl launch <UDID> com.subsplashconsulting.F52C3B -- -FIRDebugEnabled`.

## Notes

- Per spec: Firebase Analytics is required for production
- Config should be per-site (FFCI, C4I have separate Firebase configs when multi-site ships)
- Five Q will own Firebase projects long-term
- See Appendix B in spec for Firebase setup checklist
- **React Native / Expo** (`rn-mip-app`) is out of scope for this ticket
- **Done:** DebugView shows events (e.g. `user_engagement`) with debug mode + analytics enabled as above
