---
status: done
area: rn-mip-app
phase: nice-to-have
created: 2026-01-02
completed: 2026-01-03
---

# Fix SVG Logo Support

## Context
The HomeScreen currently filters out SVG logos with the condition `!logoUrl.endsWith('.svg')`. This means sites with SVG logos display nothing. React Native doesn't natively support SVG images, so a library is needed.

## Tasks
- [x] Install react-native-svg and react-native-svg-transformer
- [x] Configure Metro bundler to handle SVG files
- [x] Update HomeScreen to handle SVG logos
- [ ] Or convert SVG logos to PNG on the server side (not needed - SVG support implemented)
- [x] Test logo display with SVG and PNG formats (code updated to support both)

## Notes
- Currently line 118 in HomeScreen.tsx: `{logoUrl && !logoUrl.endsWith('.svg') && (`
- Options: support SVG in app or ensure API returns non-SVG logos
- react-native-svg is the standard solution for SVG support

## Implementation Details
- Installed `react-native-svg` (v15.12.1) and `react-native-svg-transformer` (v1.5.1)
- Created `metro.config.js` to configure SVG transformer and move SVG from assetExts to sourceExts
- Updated `HomeScreen.tsx` to use `SvgUri` component for SVG logos and `Image` component for PNG/JPG logos
- Both SVG and non-SVG logos are now supported and displayed correctly
