---
status: qa
area: rn-mip-app
phase: c4i
created: 2026-01-02
---

# Audio Player Component

## Context
The spec requires an audio player with controls for podcast and audio content. C4I has an audio collection with podcast content. The player should provide platform-appropriate native UI.

## Tasks
- [x] Create AudioPlayer component using Expo AV or similar
- [x] Implement playback controls (play, pause, seek, volume)
- [x] Display audio metadata (title, duration, progress)
- [x] Handle audio URLs from collection items
- [x] Add loading states and error handling
- [x] Add testIDs for Maestro testing
- [x] Test on iOS and Android devices
- [x] Verify via Maestro test (ticket 087 resolved, test passes)

## Implementation Status

### Completed:
- AudioPlayer component created at `components/AudioPlayer.tsx`
- Uses Expo AV for audio playback
- Includes play/pause, seek slider, time display
- testIDs added: `audio-player-container`, `audio-play-button`, `audio-time-current`, `audio-time-duration`

### Verified:
- **Maestro test passes** - Audio player renders correctly and playback controls work
- API fix deployed to resolve audio file URLs from Kirby CMS
- Test: `maestro/flows/ticket-023-audio-player-testids.yaml`

### Maestro Test:
- Test file: `maestro/flows/ticket-023-audio-player-testids.yaml`
- Test is correct but fails because navigation to audio item pages is broken

## Research Findings (Scouted)

### Root Cause
The wsp-mobile plugin's `audio_data()` method in `lib/pages.php` is not implemented (just a `//TODO` stub). The API returns raw CMS content but doesn't resolve Kirby file references to playable URLs.

**API Response (current):**
```json
{
  "audio_source": "file",
  "audio_file": "- file://xzXoDn8ZyiZFFHgP",
  "audio_url": ""  // Empty! AudioPlayer gets nothing to play
}
```

**Expected:** `audio_url` should contain the resolved URL like `https://ffci.fiveq.dev/media/gods-power-tools/gods-power-tools.mp3`

### Files to Modify

1. **`wsp-mobile/lib/pages.php`** - Line 65-68
   - Implement `audio_data()` method to resolve file references
   - Pattern: `$page->audio_file()->toFile()->url()` (see wsp-collections/snippets/media/audio-player.php lines 5-10)

2. **`wsp-mobile/lib/pages.php`** - Line 203-222 (`collection_item_data()`)
   - Add audio handling similar to video handling on line 211-213
   - Call `audio_data()` for audio-type items and include `audio_url` in response

### Reference Implementation
From `wsp-collections/snippets/media/audio-player.php`:
```php
if ($page->audio_source() == 'file' && $page->audio_file()->isNotEmpty()) {
    $audio_file = $page->audio_file()->toFile();
    $audio_url = $audio_file->url();
} elseif ($page->audio_source() == 'url' && $page->audio_url()->isNotEmpty()) {
    $audio_url = $page->audio_url();
}
```

### React Native Side (Already Correct)
- `TabScreen.tsx` line 155: `const audioUrl = currentPageData.data?.content?.audio_url;`
- `AudioPlayer.tsx`: Correctly uses the URL with Expo AV
- No changes needed in RN code - issue is backend-only

## Notes
- Per spec: "Audio: Audio player with controls"
- Background playback is nice-to-have for v1, not required
- Related to Firebase analytics events (audio_play) in ticket 029
- Ticket 087 now resolved - navigation works
