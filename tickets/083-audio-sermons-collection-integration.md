---
status: qa
area: rn-mip-app
phase: core
created: 2026-01-17
---

# Audio Sermons Collection Integration

## Context

An audio sermons collection has been created on the website at https://ffci.fiveq.dev/sermons with one sermon initially. This collection needs to be integrated into the mobile app so users can access and play audio sermons.

## Current Issue

**Bug:** Audio Sermons card appears on the home screen, but when tapped, the collection screen shows "No items in this collection" even though sermons exist on the website. The collection children are not being loaded properly from the API.

**Screenshot:** See attached screenshot showing the empty collection state.

**Root Cause:** The API endpoint in `wsp-mobile/lib/pages.php` was not including `title` and `description` fields in the children array, and was not filtering for published children only.

**Fix Applied:**
- Updated `collection_data()` method to include `title` and `description` fields in children array
- Added `->published()` filter to ensure only published children are returned
- Updated `content_data()` method with the same improvements for consistency

**Testing:**
- Maestro test created: `audio-verification-simple.yaml`
- Test initially failed (showcasing the bug), now passes after API fix is deployed
- ✅ Test verified: Collection children load correctly with "God's Power Tools" sermon visible
- ✅ API changes deployed and verified working

## Goals

1. Integrate the sermons collection into the mobile app
2. Display sermons collection in the app navigation/content structure
3. Enable audio playback functionality for sermons
4. Test collection loading and audio playback

## Acceptance Criteria

- Sermons collection is accessible in the mobile app
- Collection displays sermon items correctly
- Audio playback works for sermon items
- Collection loads from the website API endpoint
- Error handling for missing or unavailable audio files

## Notes

- Collection URL: https://ffci.fiveq.dev/sermons
- Currently contains one sermon as initial content
- Related to ticket [075](075-integrate-audio-sermons.md) - this ticket tracks the integration work now that the collection exists
- May require audio player component work from ticket [023](023-audio-player-component.md)
- Collection structure should be verified via the mobile API endpoint

## References

- Collection URL: https://ffci.fiveq.dev/sermons
- Related ticket: [075](075-integrate-audio-sermons.md) - Integrate Audio Sermons Collection
- Related ticket: [023](023-audio-player-component.md) - Audio Player Component
