# Unit Test to Integration Test Mapping

This document lists the failing unit tests that have been replaced or covered by integration tests.

## Video Playback Tests

### Unit Tests (8 tests - Currently Failing)
Located in: `cypress/e2e/video-playback.cy.ts`

1. ❌ **`displays video player for video items`**
   - **Integration Coverage**: ✅ Covered by `verifies video player component renders when video data exists`
   - **Status**: Integration test checks for video player when video data exists in real API

2. ❌ **`handles YouTube URLs with embed`**
   - **Integration Coverage**: ⚠️ Partially covered (checks for video player, but doesn't verify YouTube-specific embed)
   - **Status**: Would need real YouTube video page in API to fully test

3. ❌ **`handles Vimeo URLs with embed`**
   - **Integration Coverage**: ⚠️ Partially covered (checks for video player, but doesn't verify Vimeo-specific embed)
   - **Status**: Would need real Vimeo video page in API to fully test

4. ❌ **`handles direct video URLs with HTML5 player`**
   - **Integration Coverage**: ⚠️ Partially covered (checks for video player, but doesn't verify HTML5-specific attributes)
   - **Status**: Would need real direct video URL page in API to fully test

5. ❌ **`displays poster image for direct video URLs`**
   - **Integration Coverage**: ❌ Not covered
   - **Status**: Requires specific direct video page with poster image

6. ❌ **`displays content below video player`**
   - **Integration Coverage**: ⚠️ Partially covered (verifies page loads, but doesn't check specific content)
   - **Status**: Would need to check for specific content structure

7. ❌ **`displays page title above video player`**
   - **Integration Coverage**: ✅ Covered by `displays page content from real API`
   - **Status**: Integration test verifies page title/heading is visible

8. ❌ **`displays cover image when present`**
   - **Integration Coverage**: ❌ Not covered
   - **Status**: Would need to check for cover image specifically

### Integration Tests (4 tests - Passing ✅)
Located in: `cypress/e2e/integration/video-playback.cy.ts`

1. ✅ `can access the real API` - **New test** (API connectivity check)
2. ✅ `displays page content from real API` - **Covers**: Unit test #7
3. ✅ `handles pages with video content if available` - **New test** (general navigation)
4. ✅ `verifies video player component renders when video data exists` - **Covers**: Unit test #1

---

## Audio Playback Tests

### Unit Tests (8 tests - Currently Failing)
Located in: `cypress/e2e/audio-playback.cy.ts`

1. ❌ **`displays audio player for audio items`**
   - **Integration Coverage**: ✅ Covered by `verifies audio player component renders when audio data exists`
   - **Status**: Integration test checks for audio player when audio data exists in real API

2. ❌ **`audio player has playback controls`**
   - **Integration Coverage**: ✅ Covered by `verifies audio player component renders when audio data exists`
   - **Status**: Integration test verifies audio element has controls attribute

3. ❌ **`displays audio metadata (title, artwork)`**
   - **Integration Coverage**: ✅ Covered by `verifies audio metadata displays correctly when available`
   - **Status**: Integration test checks for title and artwork when available

4. ❌ **`displays audio duration when available`**
   - **Integration Coverage**: ✅ Covered by `verifies audio metadata displays correctly when available`
   - **Status**: Integration test checks for duration when available

5. ❌ **`displays content below audio player`**
   - **Integration Coverage**: ⚠️ Partially covered (verifies page loads, but doesn't check specific content)
   - **Status**: Would need to check for specific content structure

6. ❌ **`displays page title above audio player`**
   - **Integration Coverage**: ✅ Covered by `displays page content from real API`
   - **Status**: Integration test verifies page title/heading is visible

7. ❌ **`handles audio without artwork gracefully`**
   - **Integration Coverage**: ❌ Not covered
   - **Status**: Requires specific test case with audio without artwork

8. ❌ **`handles audio without duration gracefully`**
   - **Integration Coverage**: ❌ Not covered
   - **Status**: Requires specific test case with audio without duration

### Integration Tests (4 tests - Passing ✅)
Located in: `cypress/e2e/integration/audio-playback.cy.ts`

1. ✅ `can access the real API` - **New test** (API connectivity check)
2. ✅ `displays page content from real API` - **Covers**: Unit test #6
3. ✅ `verifies audio player component renders when audio data exists` - **Covers**: Unit tests #1, #2
4. ✅ `verifies audio metadata displays correctly when available` - **Covers**: Unit tests #3, #4

---

## Summary

### Fully Covered Unit Tests ✅
- Video: `displays video player for video items`, `displays page title above video player`
- Audio: `displays audio player for audio items`, `audio player has playback controls`, `displays audio metadata (title, artwork)`, `displays audio duration when available`, `displays page title above audio player`

### Partially Covered Unit Tests ⚠️
- Video: `handles YouTube URLs with embed`, `handles Vimeo URLs with embed`, `handles direct video URLs with HTML5 player`, `displays content below video player`
- Audio: `displays content below audio player`

### Not Covered Unit Tests ❌
- Video: `displays poster image for direct video URLs`, `displays cover image when present`
- Audio: `handles audio without artwork gracefully`, `handles audio without duration gracefully`

### New Integration Tests (Not in Unit Tests) ✅
- `can access the real API` (both video and audio suites)
- `handles pages with video content if available` (video suite)

---

## Recommendations

1. **Keep unit tests** for edge cases and specific scenarios (poster images, cover images, missing artwork/duration)
2. **Use integration tests** for real API compatibility and end-to-end verification
3. **Consider adding** integration tests for specific video/audio types when real content becomes available in the API
4. **Unit tests** can remain as documentation of expected behavior, even if they fail due to SSR interception limitations
