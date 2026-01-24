# Android Development Notes

Lessons learned while building the FFCI Android app with Jetpack Compose.

---

## Project Setup

### Gradle Configuration
- Use `libs.versions.toml` for centralized dependency management
- **Critical**: Must add `gradle.properties` with `android.useAndroidX=true` or build fails with cryptic AAR metadata errors
- Gradle wrapper jar can be downloaded from: `https://raw.githubusercontent.com/gradle/gradle/v8.9.0/gradle/wrapper/gradle-wrapper.jar`

### Key Dependencies
```toml
composeBom = "2024.11.00"      # Compose Bill of Materials
media3 = "1.5.0"               # ExoPlayer
okhttp = "4.12.0"              # HTTP client
moshi = "1.15.1"               # JSON parsing
coil = "2.7.0"                 # Image loading
navigationCompose = "2.8.4"    # Navigation
```

---

## Moshi JSON Parsing Pitfalls

### Nullable Fields Are Critical
Moshi with `KotlinJsonAdapterFactory` is **strict about nullability**. If the API returns `null` for a field declared as non-null, parsing fails with:
```
JsonDataException: Non-null value 'description' was null at $.site_data.homepage_quick_tasks[3].description
```

**Fix**: Make fields nullable that might be null in the API response:
```kotlin
// BAD - will crash if API returns null
data class HomepageQuickTask(
    val description: String,  // Crashes!
)

// GOOD - handles null gracefully
data class HomepageQuickTask(
    val description: String?,  // Safe
)
```

Then handle nulls in UI code:
```kotlin
// Check for null before using
if (!task.description.isNullOrEmpty()) {
    Text(text = task.description!!)
}
```

---

## Navigation Compose

### Route with Parameters
```kotlin
// Define route with parameter placeholder
data object Page : Screen("page/{uuid}") {
    fun createRoute(uuid: String) = "page/$uuid"
}

// Register composable with argument
composable(
    route = Screen.Page.route,
    arguments = listOf(navArgument("uuid") { type = NavType.StringType })
) { backStackEntry ->
    val uuid = backStackEntry.arguments?.getString("uuid") ?: return@composable
    TabScreen(uuid = uuid)
}

// Navigate to route
navController.navigate(Screen.Page.createRoute(someUuid))
```

### Material Icons Deprecation
Some icons moved to `AutoMirrored` variants:
```kotlin
// OLD (deprecated)
Icons.Default.LibraryBooks

// NEW
Icons.AutoMirrored.Filled.LibraryBooks
```

---

## ADB Commands for Emulator

### Device Management
```bash
# List connected devices/emulators
adb devices

# Check if app is installed
adb shell pm list packages | grep ffci
```

### App Lifecycle
```bash
# Launch app
adb shell am start -n com.fiveq.ffci/.MainActivity

# Force stop app
adb shell am force-stop com.fiveq.ffci

# Install APK
adb install app/build/outputs/apk/debug/app-debug.apk

# Or use gradle
./gradlew installDebug
```

### Logs (Logcat)
```bash
# Get recent logs for specific app
adb logcat -d -t 100 --pid=$(adb shell pidof -s com.fiveq.ffci)

# Filter by tag or pattern
adb logcat -d -t 100 | grep -E "(MipApp|Error|Exception)"

# Clear and follow logs
adb logcat -c && adb logcat | grep MipApp
```

### Screenshots
```bash
# Capture screenshot to local file
adb exec-out screencap -p > /tmp/screenshot.png

# Verify image
file /tmp/screenshot.png
```

### UI Interaction
```bash
# Tap at coordinates (x, y)
adb shell input tap 226 820

# Press back button
adb shell input keyevent KEYCODE_BACK

# Swipe (x1, y1, x2, y2, duration_ms)
adb shell input swipe 500 1500 500 500 300
```

### UI Hierarchy Dump (Finding Coordinates)
```bash
# Dump view hierarchy to XML
adb shell uiautomator dump
adb shell cat /sdcard/window_dump.xml

# Search for specific element
adb shell cat /sdcard/window_dump.xml | grep "About Us"
```

The dump shows `bounds="[x1,y1][x2,y2]"` for each element. Calculate center:
- center_x = (x1 + x2) / 2
- center_y = (y1 + y2) / 2

Example: `bounds="[42,610][410,1030]"` → center is (226, 820)

---

## Build Commands

```bash
# Compile Kotlin only (fast check for syntax errors)
./gradlew compileDebugKotlin

# Build debug APK
./gradlew assembleDebug

# Build and install
./gradlew installDebug

# Clean build
./gradlew clean assembleDebug
```

### Build Output Location
```
app/build/outputs/apk/debug/app-debug.apk
```

---

## ExoPlayer (Media3) Audio

### Basic Setup
```kotlin
val player = remember {
    ExoPlayer.Builder(context).build().apply {
        setMediaItem(MediaItem.fromUri(url))
        prepare()
    }
}

// Clean up on dispose
DisposableEffect(player) {
    onDispose { player.release() }
}
```

### Player State Listener
```kotlin
val listener = object : Player.Listener {
    override fun onPlaybackStateChanged(state: Int) {
        when (state) {
            Player.STATE_READY -> { /* Ready to play */ }
            Player.STATE_BUFFERING -> { /* Loading */ }
            Player.STATE_ENDED -> { /* Finished */ }
        }
    }
    override fun onIsPlayingChanged(playing: Boolean) {
        isPlaying = playing
    }
}
player.addListener(listener)
```

---

## WebView in Compose

```kotlin
AndroidView(
    factory = { context ->
        WebView(context).apply {
            settings.javaScriptEnabled = false
            webViewClient = object : WebViewClient() {
                override fun shouldOverrideUrlLoading(view: WebView?, request: WebResourceRequest?): Boolean {
                    // Intercept links here
                    return true  // true = handled, don't load in WebView
                }
            }
            loadDataWithBaseURL(baseUrl, html, "text/html", "UTF-8", null)
        }
    }
)
```

---

## Common Errors & Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| `android.useAndroidX` not enabled | Missing gradle.properties | Add `android.useAndroidX=true` to gradle.properties |
| `Non-null value was null` | Moshi strict null checking | Make field nullable (`String?`) |
| `Icons.Default.X is deprecated` | Icon moved to AutoMirrored | Use `Icons.AutoMirrored.Filled.X` |
| App shows loading forever | API parsing failed silently | Check logcat for JsonDataException |
| Tap does nothing | Wrong coordinates | Use `uiautomator dump` to find exact bounds |

---

## Debugging Workflow

1. **Build fails?** → Check `./gradlew compileDebugKotlin` output
2. **App crashes on launch?** → `adb logcat -d -t 100 | grep -E "(Error|Exception|FATAL)"`
3. **App shows error screen?** → Check API response parsing in logs
4. **UI not responding to taps?** → Use `uiautomator dump` to verify element bounds
5. **Navigation not working?** → Add Log.d() calls to click handlers, check logcat
