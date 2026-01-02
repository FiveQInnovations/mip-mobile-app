---
status: backlog
area: rn-mip-app
created: 2026-01-20
---

# Update package versions to match Expo SDK requirements

## Context
Several packages have version mismatches with the installed Expo SDK. Some are minor version mismatches and some are patch versions. While these may not cause immediate issues, keeping packages aligned with Expo SDK requirements ensures compatibility and reduces potential bugs.

## Tasks
- [ ] Run `npx expo install --check` to review dependency updates
- [ ] Update packages with minor version mismatches:
  - `react-native-screens`: ~4.16.0 (found 4.19.0)
  - `react-native-webview`: 13.15.0 (found 13.16.0)
  - `@react-navigation/bottom-tabs`: ^7.4.0 (found ^7.9.0)
  - `@react-navigation/native-stack`: ^7.3.16 (found ^7.9.0)
- [ ] Update packages with patch version mismatches:
  - `@react-navigation/native`: ^7.1.8 (found ^7.1.26)
- [ ] Test app functionality after updates
- [ ] Verify EAS builds still work correctly
- [ ] If any packages need to stay on current versions, add them to `expo.install.exclude` in `package.json`

## Notes

### Discovery (2026-01-20)
- Found by `expo-doctor` during EAS Android build process
- 5 packages out of date total
- Minor version mismatches (4 packages):
  - `react-native-screens`: ~4.16.0 expected, 4.19.0 found
  - `react-native-webview`: 13.15.0 expected, 13.16.0 found
  - `@react-navigation/bottom-tabs`: ^7.4.0 expected, ^7.9.0 found
  - `@react-navigation/native-stack`: ^7.3.16 expected, ^7.9.0 found
- Patch version mismatches (1 package):
  - `@react-navigation/native`: ^7.1.8 expected, ^7.1.26 found

### Recommendations
- Use `npx expo install --check` to review updates before applying
- Test thoroughly after updates, especially navigation-related packages
- Consider updating to newer versions if they're compatible (some found versions are newer than expected)

