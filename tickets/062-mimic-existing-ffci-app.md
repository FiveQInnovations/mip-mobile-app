---
status: done
area: general
phase: nice-to-have
created: 2026-01-08
---

# Research and Mimic Existing FFCI App Design

## Context
Mike (Account Exec) mentioned he likes the design of the existing Firefighters for Christ mobile app. We should download it and use it as a reference to improve our current design. Since we don't have a real device, we need to find a way to run it on an Android emulator or use BrowserStack.

## Goals
1.  **Run the existing app:** Find a way to install/run the current "Firefighters for Christ" app (likely from Play Store/App Store) in a simulated environment.
    *   Option A: Android Emulator (Google Play Store support needed).
    *   Option B: BrowserStack App Live (if we can upload the APK or access the store).
2.  **Analyze the Design:** Take screenshots and notes on:
    *   Navigation structure.
    *   Color usage and branding.
    *   Typography and spacing.
    *   Component styling (lists, cards, headers).
3.  **Create Tasks:** Generate follow-up tickets to implement specific design elements that improve our app.

## Updates (2026-01-08)
User specifically requested to implement the **Card-based Content Layout** observed in the existing app screenshots (e.g., `screenshot-09.png`).
- Focus on large, image-forward cards.
- Replace current grid/list text-heavy layouts with visual cards.
- Update `HomeScreen` to utilize this new layout.

## Implementation Plan
- [ ] Check if current Android emulator has Google Play Store.
- [ ] If not, try to create a new AVD with Play Store support.
- [ ] Alternatively, search for the APK online to sideload.
- [ ] Check BrowserStack capabilities for installing store apps.
- [ ] Document findings and screenshots in this ticket or a new doc.
- [x] Implement `ContentCard` component (Image + Title + Description).
- [ ] Update `HomeScreen` to use `ContentCard` layout.
