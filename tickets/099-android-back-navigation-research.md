---
status: done
area: android-mip-app
phase: core
created: 2026-01-24
---

# Android Back Navigation Research

## Context

Need to determine the best practice for back navigation in the Android app. Should there be an on-screen back button, or rely solely on the system back gesture/button? Different Android versions and devices handle this differently.

## Goals

1. Research Android back navigation best practices
2. Determine if on-screen back button is needed
3. Implement appropriate back navigation pattern

## Research Questions

- Do modern Android apps use on-screen back buttons?
- How does the system back gesture work with Jetpack Compose Navigation?
- What about devices with hardware/software navigation buttons?
- What does Material Design 3 recommend?

## Acceptance Criteria

- Back navigation works intuitively on all Android devices
- Users can always return to previous screen
- Navigation behavior matches user expectations
- Works with both gesture navigation and 3-button navigation

## Notes

- Jetpack Compose Navigation has built-in back stack management
- System back gesture became standard in Android 10+
- Some apps still show back arrow in toolbar for clarity

## References

- Material Design navigation guidelines
- Android gesture navigation documentation
- Previous ticket: 054-internal-page-back-navigation.md

---

## Research Findings (Scouted)

### React Native Reference

The React Native app (`rn-mip-app/`) implements a **hybrid approach** with both on-screen and system back navigation:

**UI Pattern** (`rn-mip-app/components/TabScreen.tsx:206-240`):
- Shows prominent "← Back" button in custom header when navigating into collections
- Header styling: primary color background, white text, elevated with shadow
- Only displays back button when `canGoBack = true` (internal navigation stack depth > 1)
- Uses TouchableOpacity with accessibility labels

**Navigation Strategy** (`rn-mip-app/app/_layout.tsx:9-34`):
- Expo Router Stack navigation with `headerShown: false` for most screens
- Dynamic page route `/page/[uuid]` shows system header with native back button
- System back gesture works automatically via Expo Router
- Internal stack management in TabScreen preserves tab context

**Key Implementation Details**:
- Internal navigation stack: `pageStack` state array (like Android's `mutableStateListOf`)
- Back handler: `goBack()` removes last item from stack
- No explicit gesture handlers needed - React Navigation handles it
- Accessibility: proper `accessibilityLabel` and `accessibilityRole` attributes

### Current Android Implementation Analysis

**Navigation Architecture** (`android-mip-app/app/src/main/java/com/fiveq/ffci/ui/navigation/NavGraph.kt`):

| Component | Current Behavior |
|-----------|------------------|
| `NavHost` | Jetpack Compose Navigation with system back stack |
| `HomeScreen` | Start destination, no back button |
| `TabScreen` | Shows Material 3 TopAppBar with back button when `canGoBack = true` |
| `SearchScreen` | Shows custom header with back IconButton, calls `navController.popBackStack()` |
| System Back | **Should work automatically** with current dependencies |

**TabScreen Back Navigation** (`TabScreen.kt:128-154`):
```kotlin
// Lines 76, 122-126, 128-154
val canGoBack = pageStack.size > 1

fun goBack() {
    if (pageStack.size > 1) {
        pageStack.removeAt(pageStack.lastIndex)
    }
}

Scaffold(
    topBar = {
        if (canGoBack) {
            TopAppBar(
                title = { Text(pageData?.title ?: "", maxLines = 1) },
                navigationIcon = {
                    IconButton(onClick = { goBack() }) {
                        Icon(
                            imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                            contentDescription = "Back"
                        )
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.primary,
                    titleContentColor = MaterialTheme.colorScheme.onPrimary,
                    navigationIconContentColor = MaterialTheme.colorScheme.onPrimary
                )
            )
        }
    }
)
```

**SearchScreen Back Navigation** (`SearchScreen.kt:127-191`):
- Custom header row with IconButton for back navigation
- Calls `onBackClick()` callback which triggers `navController.popBackStack()` in NavGraph
- System back should also work (NavController manages back stack)

**Dependencies** (`gradle/libs.versions.toml`):
- `navigation-compose: 2.8.4` ✅ (2.8.0+ required for predictive back)
- `activity-compose: 1.9.3` ✅ (1.6.0+ required for system animations)
- `targetSdk: 35` (Android 15) ✅

### Android Best Practices (2026)

**Material Design 3 Guidelines**:
1. **System back gesture is primary** - Standard since Android 10+
2. **On-screen back buttons are optional** - Can improve clarity in complex navigation
3. **TopAppBar back button is acceptable** - Common pattern for hierarchical navigation
4. **Predictive back is automatic** - Android 15+ shows preview animation during swipe gesture

**Jetpack Compose Navigation**:
- NavController automatically handles system back button/gesture
- Predictive back animations enabled by default with navigation-compose 2.8.0+
- No explicit `BackHandler` needed unless custom logic required
- Cross-fade animation between screens by default

**System Back Behavior**:
- **Android 10-14**: Gesture navigation (swipe from edge) or 3-button (back button)
- **Android 15+**: Predictive back with preview animation during gesture
- **Compose Navigation**: Both work automatically, no code needed

### Implementation Recommendations

**Current State**: ✅ **Already implemented correctly**

The Android app follows best practices:
1. ✅ Material 3 TopAppBar with back arrow in TabScreen
2. ✅ Clear back button in SearchScreen header  
3. ✅ System back should work automatically (NavController manages stack)
4. ✅ Dependencies support predictive back animations (2.8.4 + 1.9.3)
5. ✅ Matches React Native pattern (hybrid on-screen + system back)

**Testing Needed**:
1. Verify system back gesture works on Android 10+ devices
2. Test 3-button navigation on devices/emulators configured with buttons
3. Confirm predictive back animation shows on Android 15+ (API 35)
4. Test edge case: system back from SearchScreen vs on-screen back button

**Potential Enhancements** (Optional):
1. Add explicit `BackHandler` in TabScreen to intercept system back if custom logic needed
2. Configure custom predictive back animations (currently using defaults)
3. Add accessibility announcement when back navigation occurs
4. Consider exit confirmation on system back from home screen

### Code Locations

| File | Purpose | Changes Needed |
|------|---------|----------------|
| `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/screens/TabScreen.kt` | Internal navigation stack with TopAppBar back button | ✅ **No changes needed** - already correct |
| `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/screens/SearchScreen.kt` | Search screen with back button | ✅ **No changes needed** - already correct |
| `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/navigation/NavGraph.kt` | Navigation graph and routes | ✅ **No changes needed** - NavController handles system back |
| `android-mip-app/gradle/libs.versions.toml` | Dependency versions | ✅ **No changes needed** - versions support predictive back |

### Variables/Data Reference

**Navigation State**:
- `pageStack: SnapshotStateList<String>` - Internal navigation stack in TabScreen
- `canGoBack: Boolean` - Computed from `pageStack.size > 1`
- `navController: NavHostController` - Jetpack Navigation controller managing system back stack

**Back Handlers**:
- `TabScreen.goBack()` - Removes last page from internal stack
- `SearchScreen.onBackClick()` - Callback that triggers `navController.popBackStack()`
- System back gesture/button - Automatically handled by NavController

### Estimated Complexity

**Low** - This is primarily a research and testing ticket, not an implementation ticket.

**Why**: The Android app already implements the correct navigation pattern. The work required is:
1. Verify system back gestures work on physical/emulator devices
2. Test on different Android versions (10, 13, 14, 15)
3. Test both gesture and 3-button navigation modes
4. Document findings and mark ticket complete

**No code changes should be needed** unless testing reveals issues with system back gesture integration.
