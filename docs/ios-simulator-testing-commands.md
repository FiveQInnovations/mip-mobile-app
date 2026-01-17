# iOS Simulator Testing Commands

When Maestro tests fail or are unreliable, these commands provide alternative ways to interact with the iOS Simulator for testing and verification.

---

## Prerequisites

- Xcode Command Line Tools installed
- iOS Simulator available
- App bundle built (`.app` file)

---

## Simulator Management

### Check Booted Simulators
```bash
xcrun simctl list devices | grep -i "booted"
```

### List Available Simulators
```bash
xcrun simctl list devices available | grep -i "iphone"
```

### Boot a Simulator
```bash
# By device name (gets first match)
xcrun simctl boot "iPhone 16"

# By UUID (more reliable)
xcrun simctl boot D9DE6784-CB62-4AC3-A686-4D445A0E7B57
```

### Shutdown Simulator
```bash
xcrun simctl shutdown booted
```

### Open Simulator App
```bash
open -a Simulator
```

---

## App Management

### Install App
```bash
xcrun simctl install booted /path/to/YourApp.app

# Example for this project:
xcrun simctl install booted ios/build/Build/Products/Release-iphonesimulator/FFCIMobile.app
```

### Uninstall App
```bash
xcrun simctl uninstall booted com.fiveq.ffci
```

### Launch App
```bash
xcrun simctl launch booted com.fiveq.ffci
```

### Terminate App
```bash
xcrun simctl terminate booted com.fiveq.ffci
```

### Full Restart (terminate + launch)
```bash
xcrun simctl terminate booted com.fiveq.ffci 2>/dev/null; sleep 1; xcrun simctl launch booted com.fiveq.ffci
```

---

## Screenshots

### Take Screenshot
```bash
xcrun simctl io booted screenshot /tmp/screenshot.png
```

### Take Screenshot with Timestamp
```bash
xcrun simctl io booted screenshot "/tmp/screenshot-$(date +%Y%m%d-%H%M%S).png"
```

### Take Screenshot and Open
```bash
xcrun simctl io booted screenshot /tmp/screenshot.png && open /tmp/screenshot.png
```

---

## Process Management

### Check Running Expo/Metro Processes
```bash
ps aux | grep -E "expo|metro" | grep -v grep
```

### Kill Stale Expo Processes
```bash
pkill -f "expo start"
pkill -f "expo run:ios"
pkill -9 -f "metro"
```

### Kill Process on Port 8081 (Metro)
```bash
lsof -ti :8081 | xargs kill -9 2>/dev/null
```

### Kill Stale Maestro Process
```bash
lsof -ti :7001 | xargs kill -9 2>/dev/null
```

### Full Cleanup
```bash
pkill -f "expo start" 2>/dev/null
pkill -f "metro" 2>/dev/null
lsof -ti :8081 | xargs kill -9 2>/dev/null
lsof -ti :7001 | xargs kill -9 2>/dev/null
```

---

## Ad-Hoc Maestro Flows

When the full test suite fails, create minimal Maestro flows for specific verification tasks.

### Basic Flow Template
```yaml
# Save to /tmp/test-flow.yaml
appId: com.fiveq.ffci
---
- launchApp:
    appId: com.fiveq.ffci
    clearState: false
- waitForAnimationToEnd:
    timeout: 5000
- takeScreenshot: /tmp/test-screenshot
```

### Scroll and Screenshot
```yaml
appId: com.fiveq.ffci
---
- launchApp:
    appId: com.fiveq.ffci
    clearState: false
- waitForAnimationToEnd
- scroll
- scroll
- waitForAnimationToEnd:
    timeout: 2000
- takeScreenshot: /tmp/scrolled-screenshot
```

### Navigate to Tab and Screenshot
```yaml
appId: com.fiveq.ffci
---
- launchApp:
    appId: com.fiveq.ffci
    clearState: false
- waitForAnimationToEnd:
    timeout: 5000
- tapOn: "About tab"
- waitForAnimationToEnd:
    timeout: 3000
- takeScreenshot: /tmp/about-tab
```

### Tap by Test ID
```yaml
appId: com.fiveq.ffci
---
- launchApp:
    appId: com.fiveq.ffci
    clearState: false
- waitForAnimationToEnd
- tapOn:
    id: "scroll-arrow-right"
- waitForAnimationToEnd
- takeScreenshot: /tmp/after-tap
```

### Run Ad-Hoc Flow
```bash
maestro test -e PLATFORM=ios /tmp/test-flow.yaml
```

---

## Common Workflows

### Fresh App Install and Screenshot
```bash
# Build, install, launch, wait, screenshot
npm run build:ios:release
sleep 5
xcrun simctl io booted screenshot /tmp/fresh-install.png
```

### Quick Iteration (Dev Mode)
```bash
# Start dev server in background
cd rn-mip-app && npx expo start --ios &

# Wait for app to load, then screenshot
sleep 30
xcrun simctl io booted screenshot /tmp/dev-check.png
```

### Verify Feature After Build
```bash
# Terminate old instance, launch fresh
xcrun simctl terminate booted com.fiveq.ffci 2>/dev/null
sleep 1
xcrun simctl launch booted com.fiveq.ffci
sleep 5

# Scroll to section and screenshot
cat > /tmp/verify.yaml << 'EOF'
appId: com.fiveq.ffci
---
- launchApp:
    appId: com.fiveq.ffci
    clearState: false
- waitForAnimationToEnd
- scroll
- scroll
- takeScreenshot: /tmp/verify-screenshot
EOF

maestro test -e PLATFORM=ios /tmp/verify.yaml
```

---

## Troubleshooting

### App Won't Launch
```bash
# Uninstall and reinstall
xcrun simctl uninstall booted com.fiveq.ffci
xcrun simctl install booted ios/build/Build/Products/Release-iphonesimulator/FFCIMobile.app
xcrun simctl launch booted com.fiveq.ffci
```

### Simulator Frozen
```bash
# Shutdown and reboot
xcrun simctl shutdown booted
xcrun simctl boot "iPhone 16"
open -a Simulator
```

### Maestro Connection Failed
```bash
# Kill stale maestro process and retry
lsof -ti :7001 | xargs kill -9 2>/dev/null
sleep 2
maestro test -e PLATFORM=ios your-flow.yaml
```

### Dev Client Picker Appears
When the Expo dev client picker appears instead of the app:
```yaml
# Add to your Maestro flow
- tapOn: "http://localhost:8081"
- waitForAnimationToEnd:
    timeout: 5000
- tapOn: "Continue"  # If dev menu appears
```

---

## Notes

- `booted` is a shorthand for the currently booted simulator
- Screenshots are saved as PNG by default
- Maestro flows require the `appId` header for iOS
- `clearState: true` will reset app data (shows dev client picker for Expo apps)
- `clearState: false` preserves app state between launches
