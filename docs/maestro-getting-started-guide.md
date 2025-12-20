# Getting Started: React Native + Expo + Maestro

This guide helps you quickly set up a production-ready React Native project with Expo and Maestro testing, based on learnings from our playground project.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Project Setup](#project-setup)
3. [Testing Setup](#testing-setup)
4. [Best Practices](#best-practices)
5. [Common Pitfalls](#common-pitfalls)
6. [Project Structure](#project-structure)
7. [Development Workflow](#development-workflow)

## Quick Start

### Prerequisites Checklist

- [ ] **Node.js** (v18+ recommended)
- [ ] **npm** or **yarn**
- [ ] **Expo CLI**: `npm install -g expo-cli` (optional, can use npx)
- [ ] **Maestro CLI**: Install from [maestro.dev](https://maestro.dev)
- [ ] **iOS Development** (macOS only):
  - [ ] Xcode installed
  - [ ] Xcode Command Line Tools: `xcode-select --install`
  - [ ] CocoaPods: `sudo gem install cocoapods`
- [ ] **Android Development**:
  - [ ] Android Studio installed
  - [ ] Android SDK configured
  - [ ] Environment variables set (`ANDROID_HOME`, `PATH`)

### 1. Create Your Project

```bash
# Create Expo project with TypeScript
npx create-expo-app@latest MyApp --template blank-typescript

cd MyApp

# Install expo-dev-client (required for Maestro testing)
npx expo install expo-dev-client
```

### 2. Configure App Identifiers

**Critical:** Set proper bundle identifiers/package names from the start. Changing these later is painful.

Edit `app.json`:

```json
{
  "expo": {
    "name": "MyApp",
    "slug": "myapp",
    "scheme": "myapp",
    "ios": {
      "bundleIdentifier": "com.yourcompany.myapp"
    },
    "android": {
      "package": "com.yourcompany.myapp"
    }
  }
}
```

**Why this matters:**
- Bundle identifiers must be unique
- Used for app store submissions
- Required for deep linking
- Used in Maestro test files

### 3. Set Up Testing Directory

```bash
mkdir -p maestro
touch maestro/config.yaml
```

Create `maestro/config.yaml`:

```yaml
# Maestro configuration file
# Set default environment variables here
# Command-line -e flags will override these values
```

### 4. Build Native Apps

**iOS (macOS only):**
```bash
# Start a simulator first
maestro start-device --platform=ios

# Build and install (first build: 5-10 minutes)
npx expo run:ios
```

**Android:**
```bash
# Start an emulator
maestro start-device --platform=android

# Build and install (first build: 7-10 minutes)
npx expo run:android
```

### 5. Start Development Server

In a separate terminal:

```bash
npx expo start --dev-client
```

Keep this running - your app needs it to load JavaScript bundles.

## Project Setup

### Essential Dependencies

Your `package.json` should include:

```json
{
  "dependencies": {
    "expo": "~54.0.30",
    "expo-dev-client": "~6.0.20",
    "expo-router": "~6.0.21",
    "react": "19.1.0",
    "react-native": "0.81.5"
  },
  "scripts": {
    "start": "expo start --dev-client",
    "ios": "expo run:ios",
    "android": "expo run:android",
    "test:maestro": "maestro test maestro/",
    "test:maestro:ios": "maestro test maestro/",
    "test:maestro:android": "maestro test maestro/"
  }
}
```

### App Configuration (`app.json`)

**Key settings for production:**

```json
{
  "expo": {
    "name": "MyApp",
    "slug": "myapp",
    "version": "1.0.0",
    "scheme": "myapp",
    "newArchEnabled": true,  // Enable new React Native architecture
    "ios": {
      "bundleIdentifier": "com.yourcompany.myapp",
      "supportsTablet": true
    },
    "android": {
      "package": "com.yourcompany.myapp",
      "adaptiveIcon": {
        "backgroundColor": "#ffffff"
      }
    },
    "plugins": [
      "expo-router"
    ]
  }
}
```

## Testing Setup

### Platform-Specific Test Files

**Create separate test files for each platform:**

- `maestro/test-ios.yaml` - iOS-specific tests
- `maestro/test-android.yaml` - Android-specific tests
- `maestro/test-shared.yaml` - Cross-platform tests (if using Expo Go)

### iOS Test Template

Create `maestro/test-ios.yaml`:

```yaml
appId: com.yourcompany.myapp
---
- launchApp
- waitForAnimationToEnd

# Handle optional developer prompts
- tapOn:
    text: "Open"
    optional: true
    waitUntilVisible: false
- waitForAnimationToEnd

- tapOn:
    text: "Continue"
    optional: true
    waitUntilVisible: false
- waitForAnimationToEnd

# Your test steps here
- assertVisible: "Home screen"
```

**iOS-specific notes:**
- Use `launchApp` - it works reliably on iOS
- Use regex patterns for tab bar items: `".*TabName.*tab.*"`
- Handle optional developer menu prompts

### Android Test Template

Create `maestro/test-android.yaml`:

```yaml
appId: com.yourcompany.myapp
---
# Use Expo deep link instead of launchApp
- openLink: exp+myapp://expo-development-client/?url=http%3A%2F%2F192.168.0.105%3A8081

# Handle optional developer prompts
- tapOn:
    text: "Continue"
    optional: true
- waitForAnimationToEnd

# Your test steps here
- assertVisible: "Home screen"
```

**Android-specific notes:**
- **Always use `openLink` with Expo deep link** - `launchApp` doesn't work with Expo dev client
- Deep link format: `exp+<scheme>://expo-development-client/?url=http%3A%2F%2F<IP>%3A8081`
- Replace `<IP>` with your local network IP address
- Use resource IDs or direct text matching (not regex like iOS)

### Running Tests

```bash
# Run all tests
npm run test:maestro

# Run iOS tests
maestro test maestro/test-ios.yaml

# Run Android tests
maestro test maestro/test-android.yaml

# Run with specific device
maestro --udid <DEVICE_ID> test maestro/test-ios.yaml
```

## Best Practices

### 1. Start with iOS

**Why:** iOS setup is more straightforward and reliable for Maestro testing.

- iOS tests use `launchApp` which works out of the box
- Android requires deep link URLs that change with your network
- iOS simulator management is simpler

**Recommendation:** Get iOS testing working first, then tackle Android.

### 2. Use ATDD (Acceptance Test-Driven Development)

**Workflow:**
1. Write a failing test for a new feature
2. Run the test to confirm it fails
3. Implement the feature
4. Run the test again to confirm it passes

**Benefits:**
- Tests serve as documentation
- Forces you to think about user experience
- Catches regressions early
- See our `TESTING.md` for a complete ATDD example

### 3. Handle Optional Prompts

Always make developer menu prompts optional:

```yaml
- tapOn:
    text: "Continue"
    optional: true
    waitUntilVisible: false
```

**Why:** These prompts may or may not appear depending on:
- First launch vs subsequent launches
- Development vs production builds
- Platform differences

### 4. Wait for Animations

Always wait for animations to complete:

```yaml
- tapOn: "Some Button"
- waitForAnimationToEnd
- assertVisible: "Next Screen"
```

**Why:** Prevents flaky tests and timing issues.

### 5. Use Descriptive Test Names

```yaml
# Good
- assertVisible: "Home screen"
- assertVisible: "User profile loaded"

# Bad
- assertVisible: "Screen"
- assertVisible: "Text"
```

### 6. Add Accessibility Labels

For better test reliability, add accessibility labels to your React Native components:

```tsx
<Text accessibilityLabel="Home screen">Welcome</Text>
<Button accessibilityLabel="Submit button">Submit</Button>
```

### 7. Keep Test Files Organized

```
maestro/
├── config.yaml
├── test-ios.yaml
├── test-android.yaml
├── flows/
│   ├── login.yaml
│   ├── navigation.yaml
│   └── checkout.yaml
└── README.md
```

## Common Pitfalls

### 1. Android: Using `launchApp` Instead of `openLink`

**Problem:** `launchApp` doesn't work with Expo dev client on Android.

**Solution:** Always use `openLink` with Expo deep link scheme:

```yaml
- openLink: exp+myapp://expo-development-client/?url=http%3A%2F%2F<IP>%3A8081
```

**Why:** Expo dev client needs the development server URL to load JavaScript bundles.

### 2. Forgetting to Start Dev Server

**Problem:** App shows blank screen or can't connect.

**Solution:** Always run `npx expo start --dev-client` before testing.

**Tip:** Use a separate terminal window/tab and keep it running.

### 3. Wrong Bundle Identifier/Package Name

**Problem:** Tests can't find the app.

**Solution:** 
- Check `app.json` for correct identifiers
- Ensure test files use the same `appId`
- Rebuild native apps after changing identifiers

### 4. Network IP Address Changes

**Problem:** Android tests fail after changing networks.

**Solution:** 
- Use environment variables for IP address
- Or update deep link URLs in test files
- Consider using `localhost` if testing on same machine

### 5. Not Handling Optional Prompts

**Problem:** Tests fail intermittently when prompts appear.

**Solution:** Always mark developer menu prompts as optional:

```yaml
- tapOn:
    text: "Continue"
    optional: true
    waitUntilVisible: false
```

### 6. Platform-Specific Element Matching

**Problem:** Tests work on iOS but fail on Android (or vice versa).

**Solution:**
- **iOS:** Use regex patterns for tab bars: `".*TabName.*tab.*"`
- **Android:** Use resource IDs or exact text matching
- Create platform-specific test files

### 7. First Build Takes Forever

**Problem:** First native build takes 5-10 minutes.

**Solution:** This is normal! Subsequent builds are much faster. Be patient on first build.

## Project Structure

### Recommended Structure

```
MyApp/
├── app/                    # Expo Router app directory
│   ├── (tabs)/            # Tab navigation group
│   │   ├── _layout.tsx    # Tab layout
│   │   ├── index.tsx      # Home screen
│   │   └── profile.tsx    # Profile screen
│   ├── _layout.tsx        # Root layout
│   └── +not-found.tsx     # 404 screen
├── components/            # Reusable components
├── hooks/                 # Custom React hooks
├── utils/                 # Utility functions
├── maestro/              # Maestro test files
│   ├── config.yaml
│   ├── test-ios.yaml
│   └── test-android.yaml
├── app.json              # Expo configuration
├── package.json
└── tsconfig.json
```

### File Organization Tips

- **Keep screens in `app/` directory** (Expo Router convention)
- **Extract reusable components** to `components/`
- **Group related tests** in `maestro/flows/`
- **Document test files** with comments explaining why, not just what

## Development Workflow

### Daily Workflow

1. **Start development server:**
   ```bash
   npx expo start --dev-client
   ```

2. **Start simulator/emulator:**
   ```bash
   # iOS
   maestro start-device --platform=ios
   
   # Android
   maestro start-device --platform=android
   ```

3. **Make code changes** - Hot reload should update automatically

4. **Run tests:**
   ```bash
   npm run test:maestro
   ```

### Using MCP Tools (AI-Assisted Development)

If you're using AI assistants with Maestro MCP integration:

**1. List available devices:**
```javascript
mcp_maestro_list_devices()
// Returns structured JSON with all devices
```

**2. Run tests programmatically:**
```javascript
mcp_maestro_run_flow({
  device_id: "9844191C-3F55-4A30-93E6-71A1A4CD98B6",
  flow_yaml: "..."
})
```

**Benefits:**
- Run tests without switching to terminal
- Integrate testing into AI workflows
- Get immediate feedback
- Perfect for ATDD workflows

See `IOS_SETUP.md` for detailed MCP tool documentation.

### Testing Strategy

**1. Start with Happy Path Tests**
- Test core user flows first
- Don't try to test everything at once

**2. Add Edge Cases Gradually**
- Handle optional prompts
- Test error states
- Test different screen sizes

**3. Use ATDD for New Features**
- Write test first
- Implement feature
- Verify test passes

**4. Keep Tests Maintainable**
- Use descriptive names
- Add comments explaining why
- Group related tests together

## Next Steps

1. **Set up CI/CD:**
   - Integrate Maestro tests into your CI pipeline
   - Run tests on every PR
   - Consider Maestro Cloud for scalable testing

2. **Explore Advanced Features:**
   - Screenshot comparison
   - Performance testing
   - Visual regression testing

3. **Consider Expo MCP Server:**
   - Enhanced AI-assisted development
   - Documentation: https://docs.expo.dev/eas/ai/mcp/

4. **Join the Community:**
   - Maestro Slack: Join workspace, then `#maestro` channel
   - Expo Discord: https://chat.expo.dev

## Resources

- **Expo Documentation:** https://docs.expo.dev
- **Maestro Documentation:** https://maestro.dev
- **React Native Documentation:** https://reactnative.dev
- **Maestro GitHub:** https://github.com/mobile-dev-inc/maestro

## Troubleshooting

### Tests Can't Find Elements

1. Use `maestro inspect-view-hierarchy` to see current screen
2. Check accessibility labels in your code
3. Verify element text matches exactly (case-sensitive)
4. Use regex patterns for iOS tab bars

### App Won't Launch

1. Verify app is installed: `xcrun simctl listapps <DEVICE_ID>` (iOS)
2. Check dev server is running
3. Verify bundle identifier matches test file
4. Try manual launch first

### Build Fails

1. Clean build: `cd ios && xcodebuild clean` (iOS)
2. Reset pods: `cd ios && pod deintegrate && pod install` (iOS)
3. Clear cache: `npx expo start --clear`
4. Check Xcode/Android Studio versions

### Maestro Driver Issues

1. Ensure app is running before tests
2. Check driver packages are installed
3. Restart simulator/emulator
4. Rebuild native apps

## Summary

**Key Takeaways:**

1. ✅ **Start with iOS** - More reliable for initial setup
2. ✅ **Use `expo-dev-client`** - Required for Maestro testing
3. ✅ **Set bundle identifiers early** - Hard to change later
4. ✅ **Use `openLink` for Android** - `launchApp` doesn't work
5. ✅ **Handle optional prompts** - Make tests more resilient
6. ✅ **Wait for animations** - Prevent flaky tests
7. ✅ **Use ATDD workflow** - Write tests first, then implement
8. ✅ **Create platform-specific tests** - iOS and Android differ

**Quick Start Checklist:**

- [ ] Project created with `create-expo-app`
- [ ] `expo-dev-client` installed
- [ ] Bundle identifiers configured in `app.json`
- [ ] Native apps built (`expo run:ios` / `expo run:android`)
- [ ] Development server running (`expo start --dev-client`)
- [ ] First test file created (`maestro/test-ios.yaml`)
- [ ] Test runs successfully

You're ready to build! 🚀
