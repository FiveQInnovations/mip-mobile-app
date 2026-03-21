---
status: backlog
area: ios-mip-app
phase: production
created: 2026-03-21
---

# Switch iOS App to Existing Subsplash Bundle ID

## Context

Firebase was set up using the intended production bundle ID `com.fiveq.ffci`, but the current iOS app still uses the existing bundle ID `com.subsplashconsulting.F52C3B`. We do not want to change the app over immediately, but we need a follow-up task to align the app target and Firebase configuration before release.

## Goals

1. Update the iOS app to use the existing bundle ID `com.subsplashconsulting.F52C3B`
2. Regenerate or replace the Firebase iOS config so Analytics matches the final bundle ID

## Acceptance Criteria

- The iOS app target uses bundle ID `com.subsplashconsulting.F52C3B`
- Any Firebase iOS app registration and `GoogleService-Info.plist` used by the app match that bundle ID
- The app builds successfully after the bundle ID change
- Firebase Analytics initialization still works with the updated configuration

## Notes

- A Firebase plist was downloaded for `com.fiveq.ffci`, but that should not be wired into the app until the bundle ID decision is finalized
- Coordinate with App Store / signing implications before switching identifiers

## References

- Ticket [028](028-firebase-setup.md)
- `ios-mip-app/FFCI.xcodeproj/project.pbxproj`
- `ios-mip-app/FFCI/FFCIApp.swift`
