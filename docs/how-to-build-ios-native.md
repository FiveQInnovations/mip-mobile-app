# How to Build iOS Native App

This guide covers building and running the native iOS FFCI app.

## Prerequisites

- Xcode 15+ installed
- iOS Simulator available
- Command Line Tools (`xcode-select --install`)

## Project Location

The iOS native app is located at `ios-mip-app/`

## Standard Simulator

**Always use iPhone 16:** `D9DE6784-CB62-4AC3-A686-4D445A0E7B57`

Using a consistent simulator prevents issues with stale builds on wrong devices.

---

## Quick Start

### Build and Run (One Command)

```bash
cd ios-mip-app
xcodebuild -project FFCI.xcodeproj \
  -scheme FFCI \
  -destination 'id=D9DE6784-CB62-4AC3-A686-4D445A0E7B57' \
  -configuration Debug \
  build

# Find and install the built app
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "FFCI.app" -path "*/Debug-iphonesimulator/*" -type d | head -1)
xcrun simctl install D9DE6784-CB62-4AC3-A686-4D445A0E7B57 "$APP_PATH"
xcrun simctl launch D9DE6784-CB62-4AC3-A686-4D445A0E7B57 com.fiveq.ffci
```

---

## Build Commands

### Debug Build

```bash
cd ios-mip-app
xcodebuild -project FFCI.xcodeproj \
  -scheme FFCI \
  -destination 'id=D9DE6784-CB62-4AC3-A686-4D445A0E7B57' \
  -configuration Debug \
  build
```

### Release Build

```bash
cd ios-mip-app
xcodebuild -project FFCI.xcodeproj \
  -scheme FFCI \
  -destination 'id=D9DE6784-CB62-4AC3-A686-4D445A0E7B57' \
  -configuration Release \
  build
```

### Clean Build

```bash
cd ios-mip-app
xcodebuild -project FFCI.xcodeproj \
  -scheme FFCI \
  clean build
```

---

## Simulator Management

### Check Booted Simulators

```bash
xcrun simctl list devices | grep -i "booted"
```

### Boot iPhone 16

```bash
xcrun simctl boot D9DE6784-CB62-4AC3-A686-4D445A0E7B57
open -a Simulator
```

### Shutdown Simulator

```bash
xcrun simctl shutdown D9DE6784-CB62-4AC3-A686-4D445A0E7B57
```

---

## App Management

### Find Built App

```bash
find ~/Library/Developer/Xcode/DerivedData -name "FFCI.app" -path "*/Debug-iphonesimulator/*" -type d | head -1
```

### Install App

```bash
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "FFCI.app" -path "*/Debug-iphonesimulator/*" -type d | head -1)
xcrun simctl install D9DE6784-CB62-4AC3-A686-4D445A0E7B57 "$APP_PATH"
```

### Launch App

```bash
xcrun simctl launch D9DE6784-CB62-4AC3-A686-4D445A0E7B57 com.fiveq.ffci
```

### Terminate App

```bash
xcrun simctl terminate D9DE6784-CB62-4AC3-A686-4D445A0E7B57 com.fiveq.ffci
```

### Uninstall App

```bash
xcrun simctl uninstall D9DE6784-CB62-4AC3-A686-4D445A0E7B57 com.fiveq.ffci
```

### Restart App (terminate + launch)

```bash
xcrun simctl terminate D9DE6784-CB62-4AC3-A686-4D445A0E7B57 com.fiveq.ffci 2>/dev/null
sleep 1
xcrun simctl launch D9DE6784-CB62-4AC3-A686-4D445A0E7B57 com.fiveq.ffci
```

---

## Screenshots

### Take Screenshot

```bash
xcrun simctl io D9DE6784-CB62-4AC3-A686-4D445A0E7B57 screenshot /tmp/screenshot.png
```

### Take Screenshot with Timestamp

```bash
xcrun simctl io D9DE6784-CB62-4AC3-A686-4D445A0E7B57 screenshot "/tmp/screenshot-$(date +%Y%m%d-%H%M%S).png"
```

### Take Screenshot and Open

```bash
xcrun simctl io D9DE6784-CB62-4AC3-A686-4D445A0E7B57 screenshot /tmp/screenshot.png && open /tmp/screenshot.png
```

---

## Opening in Xcode

### Open Project in Xcode

```bash
open ios-mip-app/FFCI.xcodeproj
```

From within Xcode:
- Select the FFCI scheme
- Choose iPhone 16 as the destination
- Press Cmd+R to build and run

---

## Project Configuration

| Setting | Value |
|---------|-------|
| Bundle ID | `com.fiveq.ffci` |
| Display Name | FFCI |
| Minimum iOS | 17.0 |
| Swift Version | 5.0 |

### Brand Colors

| Color | Hex | RGB |
|-------|-----|-----|
| Primary (Red) | `#D9232A` | 217, 35, 42 |
| Secondary (Blue) | `#024D91` | 2, 77, 145 |

---

## Troubleshooting

### Build Fails

```bash
# Clean DerivedData
rm -rf ~/Library/Developer/Xcode/DerivedData/FFCI-*

# Rebuild
cd ios-mip-app
xcodebuild -project FFCI.xcodeproj -scheme FFCI clean build
```

### App Won't Launch

```bash
# Uninstall and reinstall
xcrun simctl uninstall D9DE6784-CB62-4AC3-A686-4D445A0E7B57 com.fiveq.ffci
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "FFCI.app" -path "*/Debug-iphonesimulator/*" -type d | head -1)
xcrun simctl install D9DE6784-CB62-4AC3-A686-4D445A0E7B57 "$APP_PATH"
xcrun simctl launch D9DE6784-CB62-4AC3-A686-4D445A0E7B57 com.fiveq.ffci
```

### Simulator Frozen

```bash
# Shutdown and reboot
xcrun simctl shutdown D9DE6784-CB62-4AC3-A686-4D445A0E7B57
xcrun simctl boot D9DE6784-CB62-4AC3-A686-4D445A0E7B57
open -a Simulator
```

---

## Notes

- The app uses SwiftUI and requires iOS 17.0+
- Colors are defined in `FFCI/Assets.xcassets/` as color sets
- The main entry point is `FFCIApp.swift`
- UI is defined in `ContentView.swift`
