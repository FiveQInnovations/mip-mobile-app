---
name: android-build
description: Build, install, and verify the native Android app on emulator. Use when building the Android app, testing changes, debugging on emulator, or taking screenshots for verification.
---

# Android Build & Verification

Build and verify the native FFCI Android app (Jetpack Compose).

## Project Info

- **Location**: `android-mip-app/`
- **Package**: `com.fiveq.ffci`
- **Stack**: Jetpack Compose, ExoPlayer (Media3), OkHttp, Moshi, Coil

## Build Commands

```bash
cd /Users/anthony/mip-mobile-app/android-mip-app

# Quick syntax check (fast)
./gradlew compileDebugKotlin

# Build and install to emulator
./gradlew installDebug

# Build APK only
./gradlew assembleDebug
```

## App Control (ADB)

```bash
# Launch app
adb shell am start -n com.fiveq.ffci/.MainActivity

# Force stop
adb shell am force-stop com.fiveq.ffci

# Full restart (use after install)
adb shell am force-stop com.fiveq.ffci && adb shell am start -n com.fiveq.ffci/.MainActivity
```

## Screenshot & Verification

```bash
# Capture screenshot
adb exec-out screencap -p > /tmp/android_screenshot.png

# Then use Read tool to view the screenshot
```

## UI Interaction

```bash
# Dump UI hierarchy (find element coordinates)
adb shell uiautomator dump && adb shell cat /sdcard/window_dump.xml

# Search for specific element
adb shell cat /sdcard/window_dump.xml | grep "Button Text"

# Tap at coordinates (center of bounds [x1,y1][x2,y2] = ((x1+x2)/2, (y1+y2)/2))
adb shell input tap 226 820

# Press back
adb shell input keyevent KEYCODE_BACK

# Scroll down
adb shell input swipe 540 1500 540 500 300
```

## Reading Logs

```bash
# Recent app logs
adb logcat -d -t 100 --pid=$(adb shell pidof -s com.fiveq.ffci)

# Filter for errors
adb logcat -d -t 100 | grep -E "(Error|Exception|FATAL)"

# JSON parsing issues (common)
adb logcat -d -t 100 | grep -E "(JsonDataException|MipApiClient)"
```

## Verification Workflow

**ALWAYS follow after making changes:**

1. **Build & Install**
   ```bash
   cd /Users/anthony/mip-mobile-app/android-mip-app && ./gradlew installDebug
   ```

2. **Restart App**
   ```bash
   adb shell am force-stop com.fiveq.ffci && adb shell am start -n com.fiveq.ffci/.MainActivity
   ```

3. **Wait for API load**
   ```bash
   sleep 3
   ```

4. **Check for Errors**
   ```bash
   adb logcat -d -t 50 | grep -E "(Error|Exception|FATAL)"
   ```

5. **Screenshot & Verify**
   ```bash
   adb exec-out screencap -p > /tmp/verify.png
   ```
   Then use the Read tool to view.

6. **Test Interaction** (if needed)
   - Find bounds: `adb shell uiautomator dump && adb shell cat /sdcard/window_dump.xml | grep "element"`
   - Tap: `adb shell input tap X Y`
   - Screenshot again

## Critical Knowledge

### Moshi JSON Parsing

API fields that might be null **MUST** be declared nullable or the app crashes:

```kotlin
// WRONG - crashes if API returns null
data class Item(val description: String)

// CORRECT
data class Item(val description: String?)
```

Handle in UI: `if (!item.description.isNullOrEmpty()) { ... }`

### gradle.properties

Must contain `android.useAndroidX=true` or builds fail.

## Completion Checklist

Before marking any task complete:

- [ ] `./gradlew compileDebugKotlin` succeeds
- [ ] `./gradlew installDebug` succeeds  
- [ ] App launches without crash (check logcat)
- [ ] Screenshot shows expected UI
- [ ] If interactive: tapped and verified behavior
- [ ] No errors in logcat
