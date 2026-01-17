---
name: ios-simulator
description: Boot and manage iOS simulators. Use when needing to start a simulator, check simulator status, or prepare for iOS testing/debugging.
---

# iOS Simulator Management

## Standard Simulator

**Always use iPhone 16:** `D9DE6784-CB62-4AC3-A686-4D445A0E7B57`

This is the designated simulator for all builds and testing. Using a consistent simulator prevents issues with stale builds on wrong devices.

## When to Use
- Before building or testing iOS apps
- When user mentions "boot simulator" or "start simulator"
- When checking if a simulator is running

## Boot the Standard Simulator

```bash
# Boot iPhone 16
xcrun simctl boot D9DE6784-CB62-4AC3-A686-4D445A0E7B57

# Wait for boot to complete
sleep 5

# Open Simulator.app to see it
open -a Simulator
```

## Check Simulator Status

```bash
# Check if iPhone 16 is booted
xcrun simctl list devices | grep D9DE6784-CB62-4AC3-A686-4D445A0E7B57
```

## Take Screenshot

```bash
xcrun simctl io D9DE6784-CB62-4AC3-A686-4D445A0E7B57 screenshot /tmp/screenshot.png
```

## Shutdown Simulator

```bash
xcrun simctl shutdown D9DE6784-CB62-4AC3-A686-4D445A0E7B57
```

## DO NOT

- Do NOT use other simulators unless explicitly requested
- Do NOT use `booted` as the device target - always use the explicit UDID
- Do NOT auto-detect simulators - use the standard iPhone 16
