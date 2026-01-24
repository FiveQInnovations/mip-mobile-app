# FFCI Android App

Native Android app for Firefighters for Christ International (FFCI), built with Jetpack Compose and ExoPlayer.

## Features

- 4-tab navigation (Home, Resources, Chapters, Connect)
- Content display (HTML pages, collections/lists)
- Audio player with play/pause/seek
- Navigation within tabs (drill into collections)

## Tech Stack

- **UI**: Jetpack Compose + Material 3
- **Audio**: ExoPlayer (Media3)
- **HTTP**: OkHttp with Basic Auth
- **JSON**: Moshi
- **Images**: Coil
- **Navigation**: Navigation Compose

## Setup

### Prerequisites

- Android Studio Hedgehog (2023.1.1) or newer
- JDK 17
- Android SDK 35

### Building

1. Open the project in Android Studio
2. Let Gradle sync complete
3. Run on emulator or device (min SDK 26)

Or from command line:

```bash
# Generate gradle wrapper (if needed)
gradle wrapper

# Build debug APK
./gradlew assembleDebug

# Install on connected device
./gradlew installDebug
```

### API Configuration

The app connects to:
- Base URL: `https://ffci.fiveq.dev`
- Auth: Basic Auth (`fiveq:demo`)

## Project Structure

```
app/src/main/java/com/fiveq/ffci/
├── MainActivity.kt           # Entry point
├── MipApp.kt                 # Main app composable with bottom nav
├── data/api/
│   ├── ApiModels.kt         # Data classes for API responses
│   └── MipApiClient.kt      # OkHttp API client
└── ui/
    ├── theme/Theme.kt       # Material 3 theme
    ├── navigation/NavGraph.kt
    ├── components/
    │   ├── AudioPlayer.kt   # ExoPlayer wrapper
    │   ├── HtmlContent.kt   # WebView wrapper
    │   ├── CollectionList.kt
    │   ├── LoadingScreen.kt
    │   └── ErrorScreen.kt
    └── screens/
        ├── HomeScreen.kt
        └── TabScreen.kt
```

## Testing Audio

Navigate to: Connect > "God's Power Tools"
- Audio should load from CDN
- Duration should show ~39:36
- Play/pause and seek should work
