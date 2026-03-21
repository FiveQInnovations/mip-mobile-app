---
status: done
area: ws-ffci
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

## Progress

All `.m4a` and `.mp3` files uploaded and published:
- [x] Share Your Faith *(was already created before this session)*
- [x] A Gift Too Wonderful
- [x] 10 Things Every Fireman Needs To Know
- [x] 2nd Mile Christian
- [x] A Message to Firefighters Worldwide
- [x] Awesome Marriage
- [x] Can Good Men Go To Hell
- [x] Doing the Impossible
- [x] How to Share Your Faith
- [x] How to Get Saved
- [x] Just Pray
- [x] Living a Life of Power
- [x] Motorhome Adventure
- [x] Parenting, Part 1
- [x] Parenting, Part 2
- [x] Protect Your Marriage
- [x] So You Want To Go To Heaven
- [x] Cheyane Caldwell: On the Razor's Edge *(mp4 video, uploaded as media entry)*
- [x] Encouraging Nicaragua Interview *(mp4 video, uploaded as media entry)*
- [x] FCC 2024 *(mp4 video, uploaded as media entry)*

## Import Workflow (for next agent)

All audio files are stored locally at:
`/Users/anthony/mip-mobile-app/temp/mike-bell-audio/FFC App Media/`

Completed files are moved to:
`/Users/anthony/mip-mobile-app/temp/mike-bell-audio/done/`

This folder is gitignored via the root `.gitignore` (`temp/` entry).

The Kirby panel is at: `https://ffci.fiveq.dev/panel`
Basic auth: `fiveq` / `demo`
Media Resources collection: `https://ffci.fiveq.dev/panel/pages/media-resources`

### Per-file steps

1. **Create draft** — On the Media Resources collection page, click **Add** in the Drafts section. Enter the title (use the filename without extension, cleaned up). Tab to let the URL slug auto-populate. Click **Create as Draft**.
2. **Set audio source** — On the new draft page, change the **Audio Source** dropdown from `URL` to `File`.
3. **Upload audio file** — Click **Upload** under the Audio File field. This opens a system file picker — ask the user to navigate to `FFC App Media/` and select the file.
4. **Save** — Once the file appears as attached, click **Save**.
5. **Publish** — Click the **Draft** status button → select **Published** → click **Change**.
6. **Move file locally** — Move the uploaded file from `FFC App Media/` to `done/` so the file picker stays clean for the next upload.

### Remaining files to upload

All files are done. The `FFC App Media/` folder is empty and all 20 entries are published in Kirby.

### Notes on files
- File names map directly to page titles (strip extension, clean underscores if any)
- Mix of `.m4a`, `.mp3`, and `.mp4` — Kirby accepts all of these as audio
- The 3 `.mp4` files are video/interview recordings, still import as audio entries
- `FCC 2024 final-1280.mp4` and the interview `.mp4` files may need custom titles

## Notes

- Google Drive folder link found — no longer need to follow up with Mike
- File names are consistent enough to use directly as page titles

## References

- Google Drive folder: https://drive.google.com/drive/folders/1nQeXBNmSST0fk5QuXX3537aLnndAOgnM
- Related: ticket #201 (iOS audio player), ticket #235 (media tab categories)
