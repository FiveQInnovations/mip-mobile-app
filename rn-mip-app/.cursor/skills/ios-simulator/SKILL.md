---
name: ios-simulator
description: Boot and manage iOS simulators. Use when needing to start a simulator, check simulator status, or prepare for iOS testing/debugging.
---

# iOS Simulator Management

## When to Use
- Before building or testing iOS apps
- When user mentions "boot simulator" or "start simulator"
- When checking if a simulator is running

## Instructions

### List available simulators
```bash
xcrun simctl list devices available | grep -i "iphone"
```

### Check for booted simulator
```bash
xcrun simctl list devices | grep -i "booted"
```

### Boot a simulator
```bash
# Boot by device UUID
xcrun simctl boot <DEVICE_UUID>

# Wait for boot to complete
sleep 5
```

### Common device selection
- Prefer iPhone 16 Pro or similar modern device
- Extract UUID from `xcrun simctl list` output

### Verify boot succeeded
```bash
xcrun simctl list devices | grep -i "booted"
```

If no simulator is booted after boot command, wait longer or check for errors.
