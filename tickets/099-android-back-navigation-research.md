---
status: backlog
area: android-mip-app
phase: core
created: 2026-01-24
---

# Android Back Navigation Research

## Context

Need to determine the best practice for back navigation in the Android app. Should there be an on-screen back button, or rely solely on the system back gesture/button? Different Android versions and devices handle this differently.

## Goals

1. Research Android back navigation best practices
2. Determine if on-screen back button is needed
3. Implement appropriate back navigation pattern

## Research Questions

- Do modern Android apps use on-screen back buttons?
- How does the system back gesture work with Jetpack Compose Navigation?
- What about devices with hardware/software navigation buttons?
- What does Material Design 3 recommend?

## Acceptance Criteria

- Back navigation works intuitively on all Android devices
- Users can always return to previous screen
- Navigation behavior matches user expectations
- Works with both gesture navigation and 3-button navigation

## Notes

- Jetpack Compose Navigation has built-in back stack management
- System back gesture became standard in Android 10+
- Some apps still show back arrow in toolbar for clarity

## References

- Material Design navigation guidelines
- Android gesture navigation documentation
- Previous ticket: 054-internal-page-back-navigation.md
