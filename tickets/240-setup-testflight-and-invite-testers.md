---
status: backlog
area: general
phase: production
created: 2026-01-29
---

# Setup TestFlight, Submit Build, and Invite Testers

## Context

From FFCI App Build Review meeting (Jan 29, 2026). Need to set up TestFlight for iOS testing, submit a build, and invite testers before App Store submission. Testers will use TestFlight to install and test the FFCI app on their devices.

## Goals

1. Set up TestFlight for FFCI app
2. Submit iOS build to TestFlight
3. Collect tester Apple IDs/emails
4. Invite testers to TestFlight
5. Ensure testers can successfully install and test the app

## Acceptance Criteria

- TestFlight is configured for FFCI app
- iOS build is submitted to TestFlight
- Testers receive TestFlight invites
- Testers can install the app via TestFlight
- App behaves like a normal app for QA testing

## Tester Information Needed

- **Apple IDs from Hannah/Elon** (Mike K. collecting)
- **Apple IDs from Steve/Robert** (Mike K. collecting)
- **Android tester email** (Mike K. collecting - for Google Play internal testing)

## Process

1. Add tester Apple IDs/emails to TestFlight
2. Testers install TestFlight app (if not already installed)
3. Testers accept the invite
4. Testers install the FFCI test build from TestFlight
5. App behaves like a normal app for QA

## Notes

- TestFlight is for iOS testing
- Google Play internal testing will be used for Android (separate process)
- TestFlight allows testing before App Store submission
- Testers need Apple IDs (email addresses associated with Apple accounts)
- This is part of the pre-launch QA process

## References

- Meeting: `meetings/ffci-app-build-review-jan-29.md` (00:40:52, 00:41:07)
- Related to ticket 237 (Send app transfer process info to Mike K.)
