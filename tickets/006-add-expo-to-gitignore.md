---
status: done
area: rn-mip-app
created: 2026-01-20
---

# Add .expo directory to .gitignore

## Context
The `.expo` directory contains machine-specific device history and development server settings and should not be committed to version control. Expo Doctor detected that this directory is not currently ignored by Git.

## Tasks
- [x] Add `.expo/` to `.gitignore` - **Already present** (verified line 7 of .gitignore)
- [x] Verify `.expo` directory is ignored - **Verified** (no .expo files tracked in git)
- [x] Remove `.expo` from Git tracking if it was previously committed - **Not needed** (no .expo files were tracked)

## Notes

### Discovery (2026-01-20)
- Found by `expo-doctor` during EAS Android build process
- `.expo/` contains local development state that shouldn't be shared
- Quick fix - just needs to be added to `.gitignore`

