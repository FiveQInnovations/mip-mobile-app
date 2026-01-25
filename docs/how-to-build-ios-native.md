# How to Build iOS Native App

This guide covers building, running, and developing the native iOS FFCI app.

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

## Logging

### Using the Logger API (Recommended)

iOS uses the unified logging system (`os.log`). Import and create a logger:

```swift
import os.log

// Create a logger for your subsystem and category
private let logger = Logger(subsystem: "com.fiveq.ffci", category: "UI")

// Usage in your code
logger.debug("Debug message - verbose, filtered by default")
logger.info("Info message - standard logging")
logger.notice("Notice - more prominent than info")  // ✅ Visible in log show
logger.error("Error message - problems")
logger.fault("Fault - serious failures")
```

**Important:** Use `logger.notice()` or higher for logs that need to be visible from command line tools. `info` and `debug` levels are often filtered.

### Log Levels

| Level | Use Case | Persisted | Visible in log show? |
|-------|----------|-----------|---------------------|
| `debug` | Verbose debugging, filtered by default | No | No |
| `info` | General information | No | Sometimes |
| `notice` | Important milestones (default level) | Yes | ✅ Yes |
| `error` | Errors that don't stop execution | Yes | ✅ Yes |
| `fault` | Critical failures | Yes | ✅ Yes |

### Using NSLog() (Legacy but Reliable)

`NSLog()` is the older logging API that reliably appears in system logs:

```swift
import Foundation

NSLog("📱 [FFCI] Something happened")
```

NSLog messages appear in `log show` with the process name filter.

### Using print() (Xcode Console Only)

`print()` statements go to stdout and are visible in Xcode console but **NOT** in system logs.

```swift
print("📱 [FFCI] Something happened")
```

### Viewing Logs

#### In Xcode (Easiest)
- Build and run with Cmd+R
- Logs appear in the Debug Console (Cmd+Shift+C)
- Shows all `print()`, `NSLog()`, and `Logger` output

#### From Command Line (System Logs)

**Show recent logs:**
```bash
# Filter by subsystem (Logger API)
xcrun simctl spawn D9DE6784-CB62-4AC3-A686-4D445A0E7B57 log show \
  --predicate 'subsystem == "com.fiveq.ffci"' \
  --last 5m

# Filter by process name (catches Logger, NSLog, print)
xcrun simctl spawn D9DE6784-CB62-4AC3-A686-4D445A0E7B57 log show \
  --predicate 'processImagePath CONTAINS "FFCI"' \
  --last 5m

# Search for specific text
xcrun simctl spawn D9DE6784-CB62-4AC3-A686-4D445A0E7B57 log show \
  --predicate 'processImagePath CONTAINS "FFCI"' \
  --last 5m | grep "PROOF TEST"
```

**Stream logs in real-time:**
```bash
# Stream with subsystem filter
xcrun simctl spawn D9DE6784-CB62-4AC3-A686-4D445A0E7B57 log stream \
  --predicate 'subsystem == "com.fiveq.ffci"' \
  --level debug

# Stream with process filter (catches everything)
xcrun simctl spawn D9DE6784-CB62-4AC3-A686-4D445A0E7B57 log stream \
  --predicate 'processImagePath CONTAINS "FFCI"' \
  --level debug
```

#### Using Console.app
1. Open Console.app
2. Select the simulator from the sidebar (or "All Simulators")
3. Filter by `com.fiveq.ffci` or `FFCI` in the search bar
4. Shows all log levels including debug/info

### Logging Best Practices

```swift
// Create category-specific loggers
private let networkLogger = Logger(subsystem: "com.fiveq.ffci", category: "Network")
private let uiLogger = Logger(subsystem: "com.fiveq.ffci", category: "UI")
private let dataLogger = Logger(subsystem: "com.fiveq.ffci", category: "Data")

// Use notice level for important events (visible in log show)
uiLogger.notice("Button tapped: \(buttonName)")
networkLogger.notice("API request: \(url)")

// Include context in messages
logger.notice("Loading page: \(pageId)")
logger.error("API request failed: \(error.localizedDescription)")

// Use privacy for sensitive data
logger.notice("User email: \(email, privacy: .private)")
```

### Verified Working Example

The app includes logging that has been verified to work:

```swift
logger.notice("🎯 Hello World button tapped - PROOF TEST! Logging works!")
NSLog("📱 [FFCI] Hello World button tapped - navigating to detail screen")
```

Both appear in logs when using:
```bash
xcrun simctl spawn D9DE6784-CB62-4AC3-A686-4D445A0E7B57 log show \
  --predicate 'processImagePath CONTAINS "FFCI"' \
  --last 1m
```

---

## SwiftUI Core Patterns

### App Entry Point

```swift
// FFCIApp.swift
import SwiftUI

@main
struct FFCIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### Basic View Structure

```swift
struct ContentView: View {
    @State private var count = 0  // Local state
    
    var body: some View {
        VStack {
            Text("Count: \(count)")
            Button("Increment") {
                count += 1
            }
        }
    }
}
```

### Navigation

```swift
struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Go to Detail") {
                    DetailView()
                }
            }
            .navigationTitle("Home")
        }
    }
}
```

### State Management

| Property Wrapper | Use Case |
|-----------------|----------|
| `@State` | Simple local state |
| `@Binding` | Two-way connection to parent state |
| `@StateObject` | Create observable object |
| `@ObservedObject` | Reference observable object |
| `@EnvironmentObject` | Shared app-wide state |
| `@Environment` | System values (colorScheme, dismiss, etc.) |

---

## Networking (URLSession)

### Basic API Call

```swift
func fetchData() async throws -> [Item] {
    let url = URL(string: "https://api.example.com/items")!
    var request = URLRequest(url: url)
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    
    // Add Basic Auth if needed
    let credentials = "username:password".data(using: .utf8)!.base64EncodedString()
    request.setValue("Basic \(credentials)", forHTTPHeaderField: "Authorization")
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw URLError(.badServerResponse)
    }
    
    return try JSONDecoder().decode([Item].self, from: data)
}
```

### Using in SwiftUI

```swift
struct ItemListView: View {
    @State private var items: [Item] = []
    @State private var isLoading = false
    @State private var error: Error?
    
    var body: some View {
        List(items) { item in
            Text(item.name)
        }
        .task {
            await loadItems()
        }
    }
    
    func loadItems() async {
        isLoading = true
        do {
            items = try await fetchData()
        } catch {
            self.error = error
        }
        isLoading = false
    }
}
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

## Maestro UI Testing

The native iOS app includes Maestro UI tests for automated verification of app functionality.

### Prerequisites

- [Maestro CLI](https://maestro.mobile.dev/getting-started/installing-maestro) installed
- App built and simulator booted (see [Build Commands](#build-commands) and [Simulator Management](#simulator-management))

### Running Tests

#### Run Single Test

```bash
cd ios-mip-app
./scripts/run-maestro-ios.sh maestro/flows/homepage-loads-ios.yaml
```

The script will:
1. Find the built app in Xcode DerivedData
2. Install it on the booted simulator
3. Launch the app
4. Run the Maestro test

#### Run Directly (Explicit iOS Targeting)

```bash
cd ios-mip-app
maestro -p ios --udid D9DE6784-CB62-4AC3-A686-4D445A0E7B57 test maestro/flows/homepage-loads-ios.yaml
```

#### Available Tests

- **`maestro/flows/homepage-loads-ios.yaml`** - Homepage sanity check
  - Verifies Featured, Audio Sermons, and Resources sections render correctly
  - Takes screenshot for manual verification

### Test Structure

```
ios-mip-app/
├── maestro/
│   ├── flows/
│   │   └── homepage-loads-ios.yaml    # Test flows
│   └── screenshots/                    # Screenshot output
└── scripts/
    └── run-maestro-ios.sh              # Test runner script
```

### Test Script Details

The `run-maestro-ios.sh` script:
- Automatically finds the app bundle in `~/Library/Developer/Xcode/DerivedData`
- Uses the standard iPhone 16 simulator (`D9DE6784-CB62-4AC3-A686-4D445A0E7B57`)
- Handles app installation and launching
- Kills stale Maestro processes on port 7001
- Forces Maestro to run on iOS with `-p ios --udid` to avoid Android emulators

### Troubleshooting Tests

**Test fails with "App bundle not found":**
```bash
# Build the app first
cd ios-mip-app
xcodebuild -project FFCI.xcodeproj -scheme FFCI -destination 'id=D9DE6784-CB62-4AC3-A686-4D445A0E7B57' -configuration Debug build
```

**Test fails with "No booted iOS simulator found":**
```bash
# Boot the simulator
xcrun simctl boot D9DE6784-CB62-4AC3-A686-4D445A0E7B57
open -a Simulator
```

**Port 7001 already in use:**
The script automatically kills stale Maestro processes, but if issues persist:
```bash
lsof -ti :7001 | xargs kill -9
```

**Assertions fail for HTML content that is visible:**
- WebView text often includes extra quotes or whitespace
- Prefer partial/regex matches like `.*brokenhearted.*` over exact strings

---

## Opening in Xcode

### Open Project in Xcode

```bash
open ios-mip-app/FFCI.xcodeproj
```

From within Xcode:
- Select the FFCI scheme
- Choose iPhone 16 as the destination
- Press Cmd+R to build and run (shows print() and Logger output in console)

---

## Project Configuration

| Setting | Value |
|---------|-------|
| Bundle ID | `com.fiveq.ffci` |
| Display Name | FFCI |
| Minimum iOS | 17.0 |
| Swift Version | 5.0 |

### Brand Colors

| Color | Hex | RGB | Use |
|-------|-----|-----|-----|
| Primary | `#D9232A` | 217, 35, 42 | Main brand red |
| Secondary | `#024D91` | 2, 77, 145 | Accent blue |
| Background | `#F8FAFC` | 248, 250, 252 | Light backgrounds |
| Surface | `#FFFFFF` | 255, 255, 255 | Cards, surfaces |
| Text | `#0F172A` | 15, 23, 42 | Primary text |

Colors are defined in `FFCI/Assets.xcassets/` as color sets and accessed with:
```swift
Color("PrimaryColor")
Color("SecondaryColor")
```

---

## Project Structure

```
ios-mip-app/
├── FFCI.xcodeproj/          # Xcode project file
├── FFCI/
│   ├── FFCIApp.swift        # App entry point (@main)
│   ├── ContentView.swift    # Main view
│   ├── Assets.xcassets/     # Images, colors, app icon
│   │   ├── AccentColor.colorset/
│   │   ├── PrimaryColor.colorset/
│   │   ├── SecondaryColor.colorset/
│   │   └── AppIcon.appiconset/
│   └── Preview Content/     # SwiftUI preview assets
└── .gitignore
```

---

## Adding New Swift Files

**IMPORTANT:** When creating a new Swift file, you must manually add it to the Xcode project file (`FFCI.xcodeproj/project.pbxproj`) or it won't be compiled.

### Symptoms of Missing File Registration

- Build succeeds but new code doesn't appear in the app
- Features don't work even though code looks correct
- No compilation errors, but views/components don't render

### How to Add a New File

#### Option 1: Use Xcode (Recommended)

1. Open the project in Xcode:
   ```bash
   open ios-mip-app/FFCI.xcodeproj
   ```

2. Right-click the `FFCI` folder in the Project Navigator
3. Select "New File..." → "Swift File"
4. Name your file (e.g., `AudioPlayerView.swift`)
5. Make sure "Add to targets: FFCI" is checked
6. Save the file

#### Option 2: Manual Edit (If Xcode Not Available)

If you create a file manually (e.g., via editor), you must edit `FFCI.xcodeproj/project.pbxproj`:

1. **Generate unique IDs** (24 hex characters):
   - File reference ID: `A1B2C3D4E5F6A7B8C9D0E1F2`
   - Build file ID: `A8B9C0D1E2F3A4B5C6D7E8F9`

2. **Add PBXFileReference** (around line 37):
   ```pbxproj
   A1B2C3D4E5F6A7B8C9D0E1F2 /* AudioPlayerView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = Views/AudioPlayerView.swift; sourceTree = "<group>"; };
   ```

3. **Add PBXBuildFile** (around line 19):
   ```pbxproj
   A8B9C0D1E2F3A4B5C6D7E8F9 /* AudioPlayerView.swift in Sources */ = {isa = PBXBuildFile; fileRef = A1B2C3D4E5F6A7B8C9D0E1F2 /* AudioPlayerView.swift */; };
   ```

4. **Add to Views group** (around line 83):
   ```pbxproj
   A1B2C3D4E5F6A7B8C9D0E1F2 /* AudioPlayerView.swift */,
   ```

5. **Add to Sources build phase** (around line 179):
   ```pbxproj
   A8B9C0D1E2F3A4B5C6D7E8F9 /* AudioPlayerView.swift in Sources */,
   ```

### Verify File is Registered

After adding a file, verify it's included:

```bash
# Check if file appears in project
grep -i "AudioPlayerView" ios-mip-app/FFCI.xcodeproj/project.pbxproj

# Should see at least 3 matches:
# 1. PBXFileReference
# 2. PBXBuildFile  
# 3. In group/Sources list
```

### Clean Build After Adding Files

After manually editing `project.pbxproj`, always clean and rebuild:

```bash
cd ios-mip-app
rm -rf ~/Library/Developer/Xcode/DerivedData/FFCI-*
xcodebuild -project FFCI.xcodeproj -scheme FFCI clean build
```

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

### Logs Not Appearing

1. **print() statements**: Only visible in Xcode console (Cmd+R to run)
2. **Logger messages**: Use `logger.notice()` or higher for command-line visibility
3. **Use correct predicate**: `processImagePath CONTAINS "FFCI"` catches all log types
4. **Check time window**: Use `--last 1m` or appropriate time range

### New Code Not Appearing / Features Not Working

**Symptom:** Build succeeds, but new views/components don't appear or features don't work.

**Cause:** New Swift file wasn't added to Xcode project.

**Solution:**

1. **Check if file is in project:**
   ```bash
   grep -i "YourFileName" ios-mip-app/FFCI.xcodeproj/project.pbxproj
   ```

2. **If missing, add it:**
   - Open project in Xcode: `open ios-mip-app/FFCI.xcodeproj`
   - Right-click `FFCI` folder → "Add Files to FFCI..."
   - Select your Swift file
   - Ensure "Add to targets: FFCI" is checked

3. **Clean and rebuild:**
   ```bash
   cd ios-mip-app
   rm -rf ~/Library/Developer/Xcode/DerivedData/FFCI-*
   xcodebuild -project FFCI.xcodeproj -scheme FFCI clean build
   ```

See [Adding New Swift Files](#adding-new-swift-files) section for detailed instructions.

---

## Comparison with Android (Kotlin/Compose)

| Concept | iOS (SwiftUI) | Android (Compose) |
|---------|---------------|-------------------|
| UI Framework | SwiftUI | Jetpack Compose |
| Entry Point | `@main struct App` | `MainActivity` |
| State | `@State`, `@StateObject` | `remember`, `mutableStateOf` |
| Navigation | `NavigationStack` | `NavHost` |
| Logging | `Logger.notice()`, `NSLog()` | `Log.d()`, `Log.e()` |
| Networking | `URLSession` | `OkHttp` |
| JSON | `Codable` | `Moshi`, `Gson` |
| Async | `async/await` | Coroutines |
| Images | Native / SDWebImage | Coil |
