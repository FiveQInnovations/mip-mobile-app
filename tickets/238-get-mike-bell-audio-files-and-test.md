---
status: backlog
area: ws-ffci-copy
phase: core
created: 2026-01-29
---

# Import ~30 Audio Messages from Google Drive into Kirby

## Context

Mike Bell provided ~30 audio message files via Google Drive. These need to be imported into the Kirby website as media entries so they are available in the app's media library. This will also serve as a real-world test of the app with a larger media dataset.

## Goals

1. Download the ~30 audio files from Google Drive
2. Import each file into the Kirby site as audio message entries (title, audio file, any metadata)
3. Verify the media tab in the app displays and plays all entries correctly

## Acceptance Criteria

- All ~30 audio messages are imported into Kirby
- Each entry has appropriate metadata (title, date, speaker, audio file)
- Media tab in app lists all messages without errors
- Audio playback works for imported files
- App performance is acceptable with the full media library loaded

## Notes

- Google Drive folder link found — no longer need to follow up with Mike
- Check if files have consistent naming conventions to infer titles/dates
- May need to create a batch import process or do it manually per file

## References

- Google Drive folder: https://drive.google.com/drive/folders/1nQeXBNmSST0fk5QuXX3537aLnndAOgnM
- Related: ticket #201 (iOS audio player), ticket #235 (media tab categories)
