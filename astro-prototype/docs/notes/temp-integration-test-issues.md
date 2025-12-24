# Integration Test Issues - Test Names vs Actual Behavior

## Video Playback Integration Tests

### 1. `can access the real API`
**Test Name**: ✅ Accurate
- **What it says**: Can access the real API
- **What it does**: Makes a GET request to the API and verifies response structure
- **Status**: Fully matches description

### 2. `displays page content from real API`
**Test Name**: ⚠️ Partially Accurate
- **What it says**: Displays page content from real API
- **What it does**: 
  - Visits a page with a hardcoded UUID
  - Only checks that `h1` and `main` elements are visible
  - Does NOT verify that actual content from the API is displayed
  - Does NOT check if the content matches what the API returned
- **Issue**: Test name suggests it verifies content display, but it only checks for element visibility
- **Should verify**: That the page title/content matches the API response

### 3. `handles pages with video content if available`
**Test Name**: ⚠️ Misleading
- **What it says**: Handles pages with video content if available
- **What it does**: 
  - Gets menu items from API
  - Visits the first menu item page
  - Only checks that `h1` is visible
  - Does NOT check for video content at all
  - Does NOT verify video player rendering
- **Issue**: Test name suggests it tests video content handling, but it doesn't check for video at all
- **Should verify**: That pages with video content render video players correctly

### 4. `verifies video player component renders when video data exists`
**Test Name**: ✅ Accurate
- **What it says**: Verifies video player component renders when video data exists
- **What it does**: 
  - Checks API for pages with video data
  - If video data exists, visits page and verifies `[data-testid="video-player"]` is visible
  - Skips gracefully if no video content found
- **Status**: Fully matches description

---

## Audio Playback Integration Tests

### 1. `can access the real API`
**Test Name**: ✅ Accurate
- **What it says**: Can access the real API
- **What it does**: Makes a GET request to the API and verifies response structure
- **Status**: Fully matches description

### 2. `displays page content from real API`
**Test Name**: ⚠️ Partially Accurate
- **What it says**: Displays page content from real API
- **What it does**: 
  - Visits a page with a hardcoded UUID
  - Only checks that `h1` and `main` elements are visible
  - Does NOT verify that actual content from the API is displayed
  - Does NOT check if the content matches what the API returned
- **Issue**: Test name suggests it verifies content display, but it only checks for element visibility
- **Should verify**: That the page title/content matches the API response

### 3. `verifies audio player component renders when audio data exists`
**Test Name**: ✅ Accurate
- **What it says**: Verifies audio player component renders when audio data exists
- **What it does**: 
  - Checks API for pages with audio data
  - If audio data exists, visits page and verifies:
    - `[data-testid="audio-player"]` is visible
    - `[data-testid="audio-element"]` is visible
    - Audio element has `controls` attribute
  - Skips gracefully if no audio content found
- **Status**: Fully matches description

### 4. `verifies audio metadata displays correctly when available`
**Test Name**: ✅ Accurate
- **What it says**: Verifies audio metadata displays correctly when available
- **What it does**: 
  - Checks API for pages with audio data
  - If audio data exists, verifies:
    - Audio title is displayed (if present in API)
    - Audio artwork is displayed (if present in API)
    - Audio duration is displayed (if present in API)
  - Skips gracefully if no audio content found
- **Status**: Fully matches description

---

## Summary

### Tests with Accurate Names ✅
- `can access the real API` (both suites)
- `verifies video player component renders when video data exists`
- `verifies audio player component renders when audio data exists`
- `verifies audio metadata displays correctly when available`

### Tests with Issues ⚠️

1. **`displays page content from real API`** (both video and audio suites)
   - **Problem**: Only checks element visibility, not actual content
   - **Fix**: Should verify that page title/content matches API response data

2. **`handles pages with video content if available`** (video suite only)
   - **Problem**: Doesn't check for video content at all
   - **Fix**: Should check if page has video data and verify video player renders, or rename to something like "can navigate to pages from menu"

---

## Recommendations

1. **Rename or fix `displays page content from real API`**:
   - Option A: Rename to `can navigate to pages from API` (if just checking navigation)
   - Option B: Enhance to actually verify content matches API response

2. **Rename or fix `handles pages with video content if available`**:
   - Option A: Rename to `can navigate to menu pages` (if just checking navigation)
   - Option B: Enhance to actually check for video content and verify player renders

3. **Consider adding more specific tests**:
   - Test for YouTube video embeds (when real YouTube content exists)
   - Test for Vimeo video embeds (when real Vimeo content exists)
   - Test for direct video URLs (when real direct video content exists)
   - Test for audio without artwork/duration (when such content exists)
