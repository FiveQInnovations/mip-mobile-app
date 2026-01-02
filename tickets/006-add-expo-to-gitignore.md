---
status: backlog
area: rn-mip-app
created: 2026-01-20
---

# Add .expo directory to .gitignore

## Context
The `.expo` directory contains machine-specific device history and development server settings and should not be committed to version control. Expo Doctor detected that this directory is not currently ignored by Git.

## Tasks
- [ ] Add `.expo/` to `.gitignore`
- [ ] Verify `.expo` directory is ignored
- [ ] Remove `.expo` from Git tracking if it was previously committed

## Notes

### Discovery (2026-01-20)
- Found by `expo-doctor` during EAS Android build process
- `.expo/` contains local development state that shouldn't be shared
- Quick fix - just needs to be added to `.gitignore`

