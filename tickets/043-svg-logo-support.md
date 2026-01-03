---
status: backlog
area: rn-mip-app
created: 2026-01-02
---

# Fix SVG Logo Support

## Context
The HomeScreen currently filters out SVG logos with the condition `!logoUrl.endsWith('.svg')`. This means sites with SVG logos display nothing. React Native doesn't natively support SVG images, so a library is needed.

## Tasks
- [ ] Install react-native-svg and react-native-svg-transformer
- [ ] Configure Metro bundler to handle SVG files
- [ ] Update HomeScreen to handle SVG logos
- [ ] Or convert SVG logos to PNG on the server side
- [ ] Test logo display with SVG and PNG formats

## Notes
- Currently line 118 in HomeScreen.tsx: `{logoUrl && !logoUrl.endsWith('.svg') && (`
- Options: support SVG in app or ensure API returns non-SVG logos
- react-native-svg is the standard solution for SVG support
