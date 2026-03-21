---
status: in-progress
area: ios-mip-app
phase: production
created: 2026-03-21
---

# Switch iOS App to Existing Subsplash Bundle ID

## Context

The iOS app target previously used `com.fiveq.ffci` while the bundled Firebase `GoogleService-Info.plist` is registered for the existing production bundle ID `com.subsplashconsulting.F52C3B`. This task aligns the Xcode target (and Maestro automation) with that bundle ID so installs, signing, and Firebase match.

## Goals

1. Update the iOS app to use the existing bundle ID `com.subsplashconsulting.F52C3B`
2. Confirm Firebase iOS config (`GoogleService-Info.plist`) matches that bundle ID (already the case in-repo)

## Acceptance Criteria

- The iOS app target uses bundle ID `com.subsplashconsulting.F52C3B`
- Any Firebase iOS app registration and `GoogleService-Info.plist` used by the app match that bundle ID
- The app builds successfully after the bundle ID change
- Firebase Analytics initialization still works with the updated configuration

## Notes

- The bundled `GoogleService-Info.plist` already targets `com.subsplashconsulting.F52C3B`; no plist swap was required for this alignment
- Coordinate with App Store / signing (provisioning profiles, App ID capabilities, push if any) before shipping

## References

- Ticket [028](028-firebase-setup.md)
- `ios-mip-app/FFCI.xcodeproj/project.pbxproj`
- `ios-mip-app/FFCI/FFCIApp.swift`
