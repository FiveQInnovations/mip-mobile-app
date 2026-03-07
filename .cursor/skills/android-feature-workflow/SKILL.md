---
name: android-feature-workflow
description: Executes end-to-end workflow for Android feature and bug tickets in android-mip-app, including scope decisions, implementation order, emulator verification, regression checks, and ticket evidence. Use when working on any Android app change or debugging Android behavior.
---

# Android Feature Workflow

General workflow for implementing and verifying Android changes in
`android-mip-app` (features or bug fixes).

## When To Use

Use this skill when:

- A ticket affects Android behavior, UI, navigation, rendering, or API mapping
- You need a consistent implementation + verification loop
- You need to decide Android-only vs Android+API scope

## Core Workflow

1. **Reproduce first**
   - Launch app in emulator and confirm current behavior before editing.
   - Capture one screenshot of baseline state when useful.

2. **Diagnose the layer**
   - Classify issue as: UI, navigation/state, data model parsing, or API contract.
   - Start fixes at the lowest failing layer (data correctness before polish).

3. **Choose scope**
   - **Android-only** if existing API payload already supports required behavior.
   - **Android+API** if app must over-fetch, guess fields, or do fan-out requests.
   - Run a scale check: if this grows 10x, does approach still hold?

4. **Implement small slices**
   - Make the smallest safe change.
   - Rebuild/reinstall after each meaningful iteration.
   - Keep parsing explicit for critical fields and nullable where needed.

5. **Verify behavior + regressions**
   - Verify requested behavior in target screen.
   - Verify navigation (forward/back/re-entry).
   - Verify at least one adjacent screen sharing models/components.
   - Capture screenshot evidence.

6. **Document outcomes**
   - Update ticket with what changed and exactly how verified.
   - Record remaining risks/follow-ups.

## Android Build and Emulator Commands

Run from `android-mip-app`:

```bash
./gradlew :app:assembleDebug
adb devices
adb install -r "app/build/outputs/apk/debug/app-debug.apk"
adb shell monkey -p com.fiveq.ffci -c android.intent.category.LAUNCHER 1
```

Useful diagnostics:

```bash
adb logcat | rg "ffci|Exception|Error|Compose|ApiModels"
adb exec-out screencap -p > /tmp/android-verification.png
adb shell uiautomator dump /sdcard/window_dump.xml
adb pull /sdcard/window_dump.xml /tmp/window_dump.xml
```

## Verification Standard

Before considering work complete:

- Requested behavior works in emulator
- No obvious regression in related screens
- No crash/error patterns in logcat for tested path
- Screenshot evidence captured
- Ticket updated with verification steps and outcomes

## Delegate Strategically

Use available agents/tools to improve quality and speed:

- `visual-tester` for visual hierarchy/readability verification
- `shell` subagent for command-heavy build/test loops
- `explore` subagent for broad code discovery when location is unclear

## Skills and References

- `.cursor/skills/android-build/SKILL.md` for build/install details
- `docs/android-media-feature-handoff-guide.md` for expanded reasoning patterns

## Do Not

- Do not skip emulator verification for Android changes
- Do not treat model/parser changes as isolated; always run regression checks
- Do not mark tickets done without documented verification evidence

