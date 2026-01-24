---
status: done
area: ios-mip-app
phase: core
created: 2026-01-24
---

# iOS Audio Player

## Context

The iOS app needs to support audio playback for audio content pages. This was deferred during initial implementation but is needed for full feature parity with Android.

## Problem

Audio content pages cannot play audio files. Users need a way to play, pause, and control audio playback within the app.

## Goals

1. Implement audio player component using AVPlayer
2. Display play/pause controls
3. Show playback progress with seekable slider
4. Display current position and duration
5. Handle loading and error states

## Acceptance Criteria

- Audio player displays on pages with audio content
- Play/pause button works correctly
- Progress slider allows seeking through audio
- Current time and duration display correctly
- Player handles loading states appropriately
- Audio continues playing when navigating away (background playback)
- Player cleans up resources when dismissed

## Android Reference Implementation

File: `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/AudioPlayer.kt`

**Key features:**
- Uses ExoPlayer (Android equivalent of AVPlayer)
- Play/pause button with loading state
- Progress slider with position tracking
- Duration and current time display
- State management for ready/buffering/error states
- Automatic cleanup with DisposableEffect

**UI Components:**
- Rounded card container
- Play/pause icon button
- Title and artist text (optional)
- Progress slider
- Time indicators (current / total)

## iOS Implementation Notes

### Technology Stack
- **AVPlayer** - iOS native audio playback framework
- **AVPlayerItem** - Represents audio media item
- **Combine** or **@Published** for state management
- **Timer** or **AVPlayer.addPeriodicTimeObserver** for progress updates

### Files to Create/Modify

1. **ios-mip-app/FFCI/Views/AudioPlayerView.swift** - New component
   - AVPlayer setup and management
   - Play/pause controls
   - Progress slider (UISlider wrapped in SwiftUI)
   - Time display labels

2. **ios-mip-app/FFCI/Views/TabPageView.swift** - Modify
   - Detect audio content type
   - Display AudioPlayerView when audio URL present

3. **ios-mip-app/FFCI/API/ApiModels.swift** - Verify
   - Ensure PageData includes audio URL field

### State Management

```swift
@StateObject private var playerState = AudioPlayerState()
// Track: isPlaying, duration, currentTime, isLoading, error
```

### Background Playback

- Configure AVAudioSession category for background playback
- Handle interruptions (phone calls, etc.)

## Related Files

- `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/AudioPlayer.kt`
- `ios-mip-app/FFCI/Views/TabPageView.swift`
- `ios-mip-app/FFCI/API/ApiModels.swift`

---

## Research Findings (Scouted)

### React Native Reference

**File:** `rn-mip-app/components/AudioPlayer.tsx` (Lines 1-264)

The React Native implementation uses a **WebView with HTML5 `<audio>` element** approach rather than native audio APIs. This is a simpler implementation than Android's native ExoPlayer approach.

**Key Implementation Details:**

1. **WebView-based Player** (Lines 103-117)
   - Renders HTML5 `<audio>` element with native controls
   - Uses `allowsInlineMediaPlayback={true}` for inline playback
   - `mediaPlaybackRequiresUserAction={false}` allows auto-preparation

2. **Error Handling** (Lines 108-116, 128-145)
   - Comprehensive error detection via WebView message passing
   - Detects decode errors, network errors, HTTP errors
   - Provides fallback "Open in Safari" button for incompatible formats
   - Error codes: 1=Aborted, 2=Network, 3=Decode, 4=Not supported

3. **UI Structure** (Lines 199-262)
   - Rounded container with border and padding
   - Title and artist metadata above player
   - Error state with red background and help text
   - Height: 54px for WebView audio controls

4. **No Custom Controls**
   - Relies entirely on browser's native audio controls
   - No custom play/pause button, slider, or time display
   - Much simpler than Android's custom UI

**Integration Pattern** (from `rn-mip-app/components/PageScreen.tsx`, Lines 68-98):
```typescript
const isAudioItem = pageType === 'collection-item' && pageData.type === 'audio';
const audioUrl = pageData.data?.audio?.audio_url || pageData.data?.content?.audio_url;
const audioTitle = pageData.data?.audio?.audio_name || pageData.data?.content?.audio_name || pageData.title;
const audioArtist = pageData.data?.audio?.audio_credit || pageData.data?.content?.audio_credit;

{isAudioItem && audioUrl && (
  <AudioPlayer url={audioUrl} title={audioTitle} artist={audioArtist} />
)}
```

### Android Native Reference

**File:** `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/AudioPlayer.kt` (Lines 1-213)

Android uses **ExoPlayer (Media3)** for native audio playback with fully custom controls.

**Key Implementation Details:**

1. **ExoPlayer Setup** (Lines 59-66)
   - Creates ExoPlayer instance with context
   - Loads MediaItem from URL
   - Calls `prepare()` to buffer audio

2. **State Management** (Lines 54-57)
   - `isPlaying` - Play/pause state
   - `duration` - Total audio length in milliseconds
   - `position` - Current playback position
   - `isLoading` - Buffering/loading state

3. **Player Lifecycle** (Lines 69-103)
   - Uses `DisposableEffect` for cleanup
   - Listens to player state changes (READY, BUFFERING, ENDED)
   - Automatically seeks to start on completion
   - Releases player resources on dispose

4. **Position Updates** (Lines 106-111)
   - LaunchedEffect coroutine updates position every 500ms while playing
   - Prevents UI jank by coercing negative values

5. **Custom UI Components** (Lines 113-204)
   - Surface container with rounded corners
   - Title/artist text (optional)
   - **Slider** for seek control (Lines 143-156)
   - Time display showing position/duration (Lines 159-173)
   - Large circular play/pause button (Lines 178-202)

6. **Dependencies** (`android-mip-app/gradle/libs.versions.toml`, Lines 10, 30-31):
   - `androidx.media3:media3-exoplayer:1.5.0`
   - `androidx.media3:media3-ui:1.5.0`

**Integration Pattern** (`android-mip-app/app/src/main/java/com/fiveq/ffci/ui/screens/TabScreen.kt`, Lines 200-207, 282-289):
```kotlin
if (pageData!!.isAudioItem && pageData!!.audioUrl != null) {
    AudioPlayer(
        url = pageData!!.audioUrl!!,
        title = pageData!!.audioTitle,
        artist = pageData!!.audioArtist,
        modifier = Modifier.padding(horizontal = 16.dp)
    )
}
```

### API Data Structure

**Files:**
- `android-mip-app/app/src/main/java/com/fiveq/ffci/data/api/ApiModels.kt` (Lines 61-122)
- `ios-mip-app/FFCI/API/ApiModels.swift` (Lines 93-185)

Both Android and iOS share identical data models. **The iOS ApiModels.swift already has all audio-related fields and helper properties** - no changes needed!

**Audio Data Model** (Lines 61-65 in ApiModels.kt, Lines 93-103 in ApiModels.swift):
```kotlin
data class AudioData(
    @Json(name = "audio_url") val audioUrl: String?,
    @Json(name = "audio_name") val audioName: String?,
    @Json(name = "audio_credit") val audioCredit: String?
)
```

**Page Data Structure** (Lines 85-122 in ApiModels.kt, Lines 128-185 in ApiModels.swift):
- `PageData` contains optional `data: PageDataContent?`
- `PageDataContent` contains `audio: AudioData?` (structured) or flat fields (legacy)

**Helper Properties Already Exist in iOS** (Lines 155-172 in ApiModels.swift):
```swift
var isAudioItem: Bool {
    return effectivePageType == "collection-item" && type == "audio"
}

var audioUrl: String? {
    return data?.audio?.audioUrl ?? data?.audioUrl
}

var audioTitle: String? {
    return data?.audio?.audioName ?? data?.audioName ?? title
}

var audioArtist: String? {
    return data?.audio?.audioCredit ?? data?.audioCredit
}
```

**API Response Format:**
```json
{
  "page_type": "collection-item",
  "type": "audio",
  "title": "God's Power Tools",
  "data": {
    "audio": {
      "audio_url": "https://example.com/audio.mp3",
      "audio_name": "God's Power Tools",
      "audio_credit": "Speaker Name"
    },
    "page_content": "<p>Description HTML...</p>"
  }
}
```

### iOS Current State

**File:** `ios-mip-app/FFCI/Views/TabPageView.swift` (Lines 1-139)

The TabPageView currently renders:
- Title (Lines 41-45)
- HTML content via `HtmlContentView` (Lines 48-58)
- Collection children via `CollectionListView` (Lines 61-69)

**Where Audio Player Needs Integration** (After Line 58, before Line 60):
```swift
// Audio player for audio items
if pageData.isAudioItem, let audioUrl = pageData.audioUrl {
    AudioPlayerView(
        url: audioUrl,
        title: pageData.audioTitle,
        artist: pageData.audioArtist
    )
    .padding(.horizontal, 16)
}
```

**No Changes Needed:**
- `ApiModels.swift` - Already has all audio fields and helpers
- `MipApiClient.swift` - Already decodes audio data correctly
- Navigation logic - Works as-is

### iOS Implementation Strategy

**Files to Create:**

1. **`ios-mip-app/FFCI/Views/AudioPlayerView.swift`** - New file
   - SwiftUI view wrapping AVPlayer
   - Use `AVPlayer` for native audio playback
   - State management with `@StateObject` or `@State`
   - Timer/observer for position updates
   
**Files to Modify:**

2. **`ios-mip-app/FFCI/Views/TabPageView.swift`** - Lines ~58-60
   - Add conditional AudioPlayerView between HTML content and collection list
   - Use `pageData.isAudioItem` and `pageData.audioUrl` helpers

**Recommended Approach: Native AVPlayer**

Unlike React Native's WebView approach, iOS should use native **AVPlayer** to match Android's quality:

1. **AVPlayer Setup:**
   - Create `AVPlayer(url: URL)` with audio URL
   - Use `AVPlayerItem` for media item representation
   - Observe playback with `addPeriodicTimeObserver`

2. **State Management:**
   - `isPlaying: Bool` - Track play/pause state
   - `duration: TimeInterval` - Total audio duration
   - `currentTime: TimeInterval` - Current position
   - `isLoading: Bool` - Buffer state
   - `error: String?` - Error messages

3. **UI Components (match Android design):**
   - Rounded rectangle container
   - Title/artist text labels
   - Play/pause button (SF Symbol: "play.fill" / "pause.fill")
   - Slider for seeking
   - Time labels (current / duration)

4. **Background Playback:**
   - Configure `AVAudioSession.Category.playback`
   - Handle interruptions (calls, etc.)
   - Optional: Add lock screen controls

5. **Lifecycle Management:**
   - Clean up AVPlayer in `.onDisappear`
   - Remove observers properly
   - Handle navigation away from page

### Complexity Assessment

**Estimated Complexity: Medium**

**Reasoning:**
- **Easy:** Data models already complete, detection logic exists
- **Easy:** Integration point is clear (one line in TabPageView)
- **Medium:** AVPlayer setup requires observer pattern and state management
- **Medium:** Custom UI requires SwiftUI slider + button coordination
- **Medium:** Proper lifecycle cleanup and memory management
- **Optional:** Background playback adds complexity if implemented

**Estimated Lines of Code:** 200-300 lines for AudioPlayerView.swift

**Time Estimate:** 3-4 hours for basic implementation, +2 hours for background playback

### Maestro Test Requirements

**Reference:** `rn-mip-app/maestro/flows/ticket-023-audio-player-testids.yaml`

**Required Test Coverage:**
1. Navigate to "Audio Sermons" collection
2. Tap on audio item (e.g., "God's Power Tools")
3. Verify audio player visible
4. Test play/pause interaction
5. Verify playback controls respond

**Test IDs Needed (if using accessibility identifiers):**
- `audio-player-container` - Main player view
- `audio-play-button` - Play/pause button
- `audio-time-current` - Current time label (optional)
- `audio-time-duration` - Duration label (optional)

**iOS Maestro Test Location:** Create `ios-mip-app/maestro/flows/ticket-201-ios-audio-player.yaml`

### Code Locations Reference

| File | Lines | Purpose | Needs Changes? |
|------|-------|---------|----------------|
| `ios-mip-app/FFCI/API/ApiModels.swift` | 93-185 | Audio data models | ✅ No - Already complete |
| `ios-mip-app/FFCI/Views/TabPageView.swift` | ~58-60 | Add audio player rendering | ✏️ Yes - Add conditional view |
| `ios-mip-app/FFCI/Views/AudioPlayerView.swift` | N/A | New audio player component | ✨ Create new file |
| `rn-mip-app/components/AudioPlayer.tsx` | 1-264 | RN reference (WebView approach) | 📖 Reference only |
| `android-mip-app/.../AudioPlayer.kt` | 1-213 | Android reference (ExoPlayer) | 📖 Reference only |

### Implementation Checklist

1. ✨ Create `AudioPlayerView.swift` with AVPlayer
2. ✏️ Modify `TabPageView.swift` to conditionally render audio player
3. 🧪 Create Maestro test for iOS audio playback
4. 📱 Test on simulator with real audio URL
5. 🔊 Optional: Add background playback support
6. 🧹 Verify proper cleanup and memory management
