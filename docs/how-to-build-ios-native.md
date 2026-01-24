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
logger.notice("Notice - more prominent than info")
logger.error("Error message - problems")
logger.fault("Fault - serious failures")
```

### Log Levels

| Level | Use Case | Persisted |
|-------|----------|-----------|
| `debug` | Verbose debugging, filtered by default | No |
| `info` | General information | No |
| `notice` | Important milestones (default level) | Yes |
| `error` | Errors that don't stop execution | Yes |
| `fault` | Critical failures | Yes |

### Using print() (Simple but Limited)

`print()` statements go to stdout and are visible in Xcode console but **NOT** in system logs.

```swift
print("📱 [FFCI] Something happened")
```

### Viewing Logs

#### In Xcode
- Build and run with Cmd+R
- Logs appear in the Debug Console (Cmd+Shift+C)

#### From Command Line (System Logs)
```bash
# Stream logs for the app (notice level and above)
xcrun simctl spawn D9DE6784-CB62-4AC3-A686-4D445A0E7B57 log stream \
  --predicate 'subsystem == "com.fiveq.ffci"' \
  --level info

# Show recent logs
xcrun simctl spawn D9DE6784-CB62-4AC3-A686-4D445A0E7B57 log show \
  --predicate 'subsystem == "com.fiveq.ffci"' \
  --last 5m

# Filter by category
xcrun simctl spawn D9DE6784-CB62-4AC3-A686-4D445A0E7B57 log stream \
  --predicate 'subsystem == "com.fiveq.ffci" AND category == "Network"'
```

#### Using Console.app
1. Open Console.app
2. Select the simulator from the sidebar
3. Filter by `com.fiveq.ffci` in the search bar

### Logging Best Practices

```swift
// Create category-specific loggers
private let networkLogger = Logger(subsystem: "com.fiveq.ffci", category: "Network")
private let uiLogger = Logger(subsystem: "com.fiveq.ffci", category: "UI")
private let dataLogger = Logger(subsystem: "com.fiveq.ffci", category: "Data")

// Include context in messages
logger.info("Loading page: \(pageId)")
logger.error("API request failed: \(error.localizedDescription)")

// Use privacy for sensitive data
logger.info("User email: \(email, privacy: .private)")
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
2. **Logger messages**: Use `log stream` command or Console.app
3. Ensure log level is `info` or higher for command-line visibility

---

## Comparison with Android (Kotlin/Compose)

| Concept | iOS (SwiftUI) | Android (Compose) |
|---------|---------------|-------------------|
| UI Framework | SwiftUI | Jetpack Compose |
| Entry Point | `@main struct App` | `MainActivity` |
| State | `@State`, `@StateObject` | `remember`, `mutableStateOf` |
| Navigation | `NavigationStack` | `NavHost` |
| Logging | `Logger` (os.log) | `Log.d()`, `Log.e()` |
| Networking | `URLSession` | `OkHttp` |
| JSON | `Codable` | `Moshi`, `Gson` |
| Async | `async/await` | Coroutines |
| Images | Native / SDWebImage | Coil |
