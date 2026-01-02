---
status: backlog
area: rn-mip-app
created: 2026-01-02
---

# Android Baseline UX Issues

## Context
During BrowserStack testing on Android devices, two critical UX issues were identified that affect the baseline user experience on Android:

1. **Back button behavior**: Pressing the Android back button closes the app instead of navigating back to the home page or previous screen
2. **Tab bar visibility**: The bottom tab bar is partially or completely hidden behind the Android system navigation bar (home, back buttons)

These issues need to be fixed to provide a proper Android user experience that matches platform conventions.

## Tasks
- [ ] Fix back button behavior to navigate within app instead of closing
  - [ ] Investigate React Navigation back handler configuration
  - [ ] Implement proper back button handling for Android
  - [ ] Test back navigation from various screens
  - [ ] Ensure back button returns to home when appropriate
- [ ] Fix tab bar visibility issue
  - [ ] Investigate safe area handling for Android system navigation bar
  - [ ] Adjust tab bar positioning to account for system navigation bar
  - [ ] Test on various Android devices with different navigation bar styles
  - [ ] Verify tab bar is fully visible and accessible
- [ ] Test fixes on BrowserStack with multiple Android devices
- [ ] Verify fixes work on physical Android devices

## Notes

### Issue Discovery (2026-01-02)
- Discovered during BrowserStack testing on Samsung Galaxy S25
- Both issues affect core navigation and usability
- Need to ensure Android-specific navigation patterns are properly implemented

### Back Button Behavior
**Expected Behavior:**
- Back button should navigate to previous screen in app
- If on home page, back button should either do nothing or show exit confirmation
- Should follow Android navigation guidelines

**Current Behavior:**
- Back button immediately closes the app
- No navigation history handling

**Potential Solutions:**
- Use React Navigation's `useFocusEffect` with `BackHandler` from React Native
- Configure navigation stack properly to handle back navigation
- Consider using `react-native-screens` navigation state management

### Tab Bar Visibility
**Expected Behavior:**
- Tab bar should be fully visible above system navigation bar
- Should use safe area insets to account for system UI
- Should work on devices with gesture navigation and button navigation

**Current Behavior:**
- Tab bar is hidden behind Android system navigation bar
- Bottom tabs are partially or completely obscured

**Potential Solutions:**
- Use `react-native-safe-area-context` to get bottom inset
- Adjust tab bar padding/margin to account for system navigation bar height
- Test with `useSafeAreaInsets()` hook
- Consider using `paddingBottom` or `marginBottom` based on safe area insets

### Related Files
- `rn-mip-app/components/TabNavigator.tsx` - Tab bar component
- `rn-mip-app/app/_layout.tsx` - Root navigation layout
- `rn-mip-app/app/index.tsx` - Home screen
- `rn-mip-app/package.json` - Dependencies (react-native-safe-area-context, react-navigation)

### Testing Requirements
- Test on BrowserStack with multiple Android devices
- Test on physical Android device if available
- Verify on devices with:
  - Gesture navigation (Android 10+)
  - Button navigation (traditional Android)
  - Different screen sizes and aspect ratios

