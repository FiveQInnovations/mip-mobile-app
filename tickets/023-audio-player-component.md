---
status: qa
area: rn-mip-app
phase: c4i
created: 2026-01-02
---

# Audio Player Component

## ✅ RESOLVED (2026-01-24)

**Switched to WebView-based HTML5 audio player.** After extensive troubleshooting with native audio libraries, the component now uses a WebView with HTML5 `<audio>` element.

**What's working:**
- Audio loads and displays duration correctly (e.g., 39:36)
- Native browser controls (play, pause, seek, volume)
- Consistent behavior across audio items
- Maestro tests pass

**Trade-offs accepted:**
- No lock screen controls or background playback
- Uses browser-native audio controls (slight visual difference)

**Native audio attempts preserved on branch:** `feature/native-audio-attempts`

---

## Previous Problem (Resolved)

**Audio did not play with native libraries.** The AudioPlayer component rendered correctly but:
- Play button showed spinner indefinitely
- Duration showed `0:00 / 0:00` (audio never loaded)
- Behavior was inconsistent across items

**The audio URL was valid** - verified with curl (200 OK, audio/mpeg, 9.5MB file).

## How to Test

### Navigation Path
1. Launch app on iOS simulator
2. Tap **"Connect"** tab (bottom navigation)
3. Tap **"God's Power Tools"** (or any audio item)
4. Observe: Play button should show spinner, duration should eventually show actual time

### Maestro Test
```bash
cd rn-mip-app
maestro test maestro/flows/ticket-023-connect-to-media-resources.yaml
```

**Note:** Audio items are in the "Connect" tab due to a Kirby tab sync bug (see ticket 092). The tab is labeled "Connect" but loads the Media Resources collection.

---

## Technical Details

### Component Location
`rn-mip-app/components/AudioPlayer.tsx`

### Current Implementation (WebView)
Uses a WebView with inline HTML5 audio element:
```typescript
import { WebView } from 'react-native-webview';

const html = `
  <audio controls preload="metadata" src="${url}"></audio>
`;

<WebView
  source={{ html }}
  allowsInlineMediaPlayback={true}
  mediaPlaybackRequiresUserAction={false}
/>
```

Key WebView props:
- `allowsInlineMediaPlayback={true}` - plays without fullscreen on iOS
- `mediaPlaybackRequiresUserAction={false}` - allows playback without tap

### Previous Implementation (Native - Preserved on feature branch)
Used `expo-audio` library with hooks:
```typescript
import { useAudioPlayer, useAudioPlayerStatus, setAudioModeAsync } from 'expo-audio';

const player = useAudioPlayer(url ? { uri: url } : null, {
  updateInterval: 250,
});
const status = useAudioPlayerStatus(player);
```

### Audio URL Extraction
In `TabScreen.tsx` line 156:
```typescript
const audioUrl = currentPageData.data?.audio?.audio_url || currentPageData.data?.content?.audio_url;
```

### API Response (Verified Working)
```json
{
  "data": {
    "audio": {
      "audio_url": "https://ffci-5q.b-cdn.net/audio/gods-power-tools.mp3"
    }
  }
}
```

### CDN URL Verified
```bash
curl -sI "https://ffci-5q.b-cdn.net/audio/gods-power-tools.mp3"
# HTTP/2 200
# content-type: audio/mpeg
# content-length: 9508658
# access-control-allow-origin: *
```

---

## Working Notes (Troubleshooting Log)

### What Has Been Tried

| Attempt | Result |
|---------|--------|
| Migrated from `expo-av` to `expo-audio` | ❌ Still not playing |
| Added `downloadFirst: true` option | ❌ Inconsistent - sometimes loads 1 item |
| Removed `downloadFirst: true` | ❌ Same inconsistent behavior |
| Added `setAudioModeAsync({ playsInSilentMode: true })` | ❌ No improvement |
| Added `player.replace()` for URL changes | ❌ Still not loading |
| Increased `updateInterval` to 250ms | ❌ No improvement |
| Added extensive console logging | ✅ Confirms URL is received |
| Verified CDN URL accessibility | ✅ 200 OK, CORS enabled |
| Clean build with pod reinstall | ❌ Still not working |
| Compared with working MLJ app implementation | ❌ Same pattern, still fails |
| Created isolated audio-example screen | ❌ Also fails to play |
| **Switched to WebView with HTML5 audio** | ✅ **Working!** Duration loads, playback works |

### Known expo-audio Issues (GitHub)

1. **GitHub #40448**: `useAudioPlayer` works in dev but fails silently in Release builds
2. **GitHub #36034**: expo-audio cannot play MP3 files on physical iOS devices  
3. **GitHub #34555**: Inconsistent audio loading behavior

---

## Official Documentation Notes

### From Expo Audio Docs (https://docs.expo.dev/versions/latest/sdk/audio/)

**Basic usage:**
```typescript
import { useAudioPlayer } from 'expo-audio';
const audioSource = require('./assets/Hello.mp3');

export default function App() {
  const player = useAudioPlayer(audioSource);
  return <Button title="Play" onPress={() => player.play()} />;
}
```

**Audio mode configuration:**
```typescript
import { setAudioModeAsync } from 'expo-audio';

await setAudioModeAsync({
  playsInSilentMode: true,  // Required for iOS
  shouldPlayInBackground: false,
});
```

**Key properties from `useAudioPlayerStatus`:**
- `isLoaded` - Whether audio has finished loading
- `isBuffering` - Whether player is buffering
- `duration` - Total duration in seconds
- `currentTime` - Current position in seconds
- `playing` - Whether audio is playing

**Note from docs:** "expo-audio is a cross-platform audio library... Note that audio automatically stops if headphones/bluetooth audio devices are disconnected."

### From expo-av Docs (Deprecated)

**Status:** `expo-av` is deprecated and will be removed in SDK 55. However, it may be more stable for audio playback on iOS.

```typescript
import { Audio } from 'expo-av';

const { sound } = await Audio.Sound.createAsync(
  { uri: 'https://example.com/audio.mp3' }
);
await sound.playAsync();
```

### React Native Audio Options

1. **expo-audio** - Current recommended (but has issues)
2. **expo-av** - Deprecated but more battle-tested
3. **react-native-track-player** - Production-grade, supports background playback
4. **WebView with HTML5 audio** - Fallback option

---

## Recommended Next Steps

1. **Try expo-av fallback** - Despite deprecation, it's more stable
2. **Try react-native-track-player** - Production-grade solution
3. **Debug with Metro logs** - Check console for errors during load
4. **Test on Android** - Determine if iOS-specific issue
5. **WebView fallback** - Last resort (less preferred)

---

## Original Tasks

- [x] Create AudioPlayer component
- [x] Implement playback controls (play, pause, seek)
- [x] Display audio metadata (title, duration, progress)
- [x] Handle audio URLs from collection items
- [x] Add loading states and error handling
- [x] Add testIDs for Maestro testing
- [x] **Verify audio actually plays** ← RESOLVED via WebView

## Related
- Ticket 092: Tab bar sync bug (why audio is on "Connect" tab)
- Preference: Native solution over WebView if possible

## Maestro Tests
- `maestro/flows/ticket-023-audio-player-testids.yaml` - Original test
- `maestro/flows/ticket-023-connect-to-media-resources.yaml` - **Use this one** (navigates via Connect tab)
