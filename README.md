# MIP Mobile Apps

This repo contains native mobile apps for the MIP mobile platform, plus the original Astro prototype that proved the API and content model before the project moved native.

The important shift: this is no longer a React Native/Expo project. It started that way, but audio player reliability and native behavior pushed the project toward separate Swift and Kotlin apps. Cursor agents made that switch practical: the native apps were rebuilt quickly, tested repeatedly, and the iOS app is deployed to TestFlight and the App Store.

If you are a React Native developer coming into this repo, think of it less as "learn all native development first" and more as "use native project conventions, strong testing hooks, and specialized agents to keep the feedback loop short."

## Current Shape

```
mip-mobile-app/
├── ios-mip-app/          # Native iOS app in Swift/SwiftUI
├── android-mip-app/      # Native Android app in Kotlin/Jetpack Compose
├── astro-prototype/      # Original Astro PWA/API prototype
├── tickets/              # Markdown ticket system
├── docs/                 # Focused reference docs that survived cleanup
└── .cursor/              # Project agents, skills, and rules
```

## Project History

The project began with `astro-prototype/`. That app was useful because it proved the Kirby mobile API, menu structure, page rendering, collection rendering, and basic media flows without needing an app store build.

The next phase was React Native. That got the project closer to the final product, but the audio player became expensive to stabilize. Rather than keep layering workarounds onto a cross-platform abstraction, the project moved to native apps:

- `ios-mip-app/` is Swift/SwiftUI.
- `android-mip-app/` is Kotlin/Jetpack Compose.
- Shared behavior comes from the Kirby mobile API and from cross-platform implementation patterns, not from shared UI code.

That tradeoff worked well here. Native app code gave better control over platform behavior, and agents made the extra platform surface area manageable.

## Apps

### iOS: `ios-mip-app/`

The iOS app is a native SwiftUI project. FFCI is the main shipped app, and the C4I target proves the same codebase can create another app quickly with per-site configuration.

Key files:

- `ios-mip-app/FFCI.xcodeproj/` - Xcode project with FFCI and C4I schemes.
- `ios-mip-app/FFCI/FFCIApp.swift` - FFCI app entry point.
- `ios-mip-app/C4I/C4IApp.swift` - C4I app entry point.
- `ios-mip-app/FFCI/API/SiteConfig.swift` - loads per-target `SiteConfig.plist`.
- `ios-mip-app/FFCI/API/MipApiClient.swift` - mobile API client.
- `ios-mip-app/FFCI/Views/` - SwiftUI screens and components.
- `ios-mip-app/FFCIUITests/FFCIUITests.swift` - XCUI tests for FFCI.
- `ios-mip-app/C4IUITests/C4IUITests.swift` - XCUI tests for C4I.

React Native mental model: SwiftUI views are closer to React components than UIKit view controllers. State lives in Swift properties and observable objects instead of hooks, and navigation is platform-native.

### Android: `android-mip-app/`

The Android app is native Kotlin with Jetpack Compose.

Key files:

- `android-mip-app/app/src/main/java/com/fiveq/ffci/MainActivity.kt` - Android entry point.
- `android-mip-app/app/src/main/java/com/fiveq/ffci/MipApp.kt` - main Compose app shell.
- `android-mip-app/app/src/main/java/com/fiveq/ffci/config/AppConfig.kt` - app/site config.
- `android-mip-app/app/src/main/java/com/fiveq/ffci/data/api/MipApiClient.kt` - mobile API client.
- `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/screens/` - Compose screens.
- `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/components/` - Compose components, including HTML and audio.

Android was especially strong for command-line exploration. `adb` can dump the UI hierarchy, tap coordinates, scroll, capture screenshots, and inspect logs without needing much IDE interaction. That made agent-driven verification very effective.

### Astro Prototype: `astro-prototype/`

The Astro prototype is not the production app. Keep it as historical context and as a lightweight API/content experiment bed.

It proved:

- `/mobile-api` shape and menu data.
- Content page rendering.
- Collection and media rendering.
- Early navigation ideas.
- Cypress-based test ideas.

The Cypress tests were useful early, then became flaky enough that they stopped being the main verification strategy. Do not treat the Astro test suite as the source of truth for current mobile behavior.

## Testing Recommendations

Use native tests and platform tools before reaching for cross-platform UI automation.

For iOS, prefer XCUI tests. Maestro was easy to start with, but became flaky over time around simulator state, app launch, and app detection. XCUI testing was enabled late in the project and proved faster and more stable for the important smoke and screenshot flows.

Start here:

- `docs/ios-xcuitest-guide.md`
- `ios-mip-app/FFCIUITests/FFCIUITests.swift`
- `ios-mip-app/C4IUITests/C4IUITests.swift`

For Android, use Gradle plus `adb`:

```bash
cd android-mip-app
./gradlew compileDebugKotlin
./gradlew installDebug
adb shell am start -n com.fiveq.ffci/.MainActivity
adb shell uiautomator dump /sdcard/window_dump.xml
adb exec-out screencap -p > /tmp/android-verification.png
```

The Android workflow is documented in:

- `.cursor/skills/android-build/SKILL.md`
- `.cursor/skills/android-feature-workflow/SKILL.md`

## Use The Agents

This repo is built to be worked by Cursor agents. The fastest path is usually not "one developer manually searches everything, edits everything, and tests everything." The better path is to split the work:

1. Scout the ticket.
2. Implement on the correct platform.
3. Build and verify with platform-specific tools.
4. Ask for human QA before marking work complete.

Important agents:

- `.cursor/agents/scout-ticket.md` - researches a ticket, maps code locations, and writes findings into the ticket.
- `.cursor/agents/implement-ios-swift.md` - handles Swift/iOS implementation work.
- `.cursor/agents/add-swift-file-xcode.md` - adds new Swift files to `project.pbxproj` correctly.
- `.cursor/agents/visual-tester.md` - reviews screenshots and visual quality.
- `.cursor/agents/implement-wsp-mobile.md` - handles Kirby mobile API plugin work.
- `.cursor/agents/implement-ws-ffci.md` - handles FFCI Kirby site work.

Important skills:

- `.cursor/skills/create-ticket/SKILL.md` - how to create tickets and regenerate the index.
- `.cursor/skills/android-build/SKILL.md` - Android build/install/log/screenshot loop.
- `.cursor/skills/android-feature-workflow/SKILL.md` - Android feature workflow.
- `.cursor/skills/ios-simulator/SKILL.md` - standard simulator and screenshot commands.
- `.cursor/skills/manager-ios-swift-manual/SKILL.md` - iOS manager workflow for agent coordination and manual QA.

The project also has repo rules in `.cursor/rules/`. The most important ones for day-to-day agent work are:

- `.cursor/rules/ticket-status-workflow.mdc`
- `.cursor/rules/ios-build-standards.mdc`

Read those before asking an agent to move tickets or run iOS build work.

## Ticket System

Tickets live in `tickets/` and are indexed by `tickets/TICKETS.md`.

The workflow is:

```
backlog -> in-progress -> qa -> done
```

Agents may move work to `qa` when it is ready for review. Only the human reviewer should move tickets to `done`.

To add or edit tickets, follow `.cursor/skills/create-ticket/SKILL.md` and regenerate the index:

```bash
node tickets/generate-readme.js
```

Ticket `area` values matter because they route work to the right place:

- `ios-mip-app` - Swift/SwiftUI app.
- `android-mip-app` - Kotlin/Jetpack Compose app.
- `wsp-mobile` - Kirby mobile API plugin.
- `ws-ffci` - FFCI Kirby site.
- `astro-prototype` - historical prototype.
- `general` - cross-cutting repo work.

## Working Style For A React Native Developer

Do not try to recreate React Native patterns inside SwiftUI or Compose. Use the platform's normal patterns, then lean on the other native app as a reference.

Good cross-platform workflow:

- For an iOS ticket, check the Android implementation for behavior and data assumptions.
- For an Android ticket, check the iOS implementation for behavior and edge cases.
- Use React Native history only as a last-resort reference, not as the primary source.
- Keep API behavior in `wsp-mobile` when both apps would otherwise duplicate awkward parsing or guessing.
- Add stable accessibility identifiers when a UI path matters enough to test.

## Common Commands

iOS XCUI test example:

```bash
xcodebuild \
  -project "/Users/anthony/mip-mobile-app/ios-mip-app/FFCI.xcodeproj" \
  -scheme FFCI \
  -destination 'id=D9DE6784-CB62-4AC3-A686-4D445A0E7B57' \
  -derivedDataPath "/Users/anthony/mip-mobile-app/ios-mip-app/build-ui-tests" \
  test
```

Android build example:

```bash
cd android-mip-app
./gradlew compileDebugKotlin
./gradlew installDebug
```

Astro prototype example:

```bash
cd astro-prototype
npm install
npm run dev
```

## Practical Guidance

Use agents more than feels natural at first. This repo has enough platform-specific details that focused agents usually beat a single broad pass:

- `scout-ticket` reduces wandering.
- iOS agents avoid common Xcode project mistakes.
- Android skills keep the build/install/log loop consistent.
- Visual testing catches design regressions that normal assertions miss.
- Ticket status rules keep the human review step intact.

The native split is not a failure of the earlier prototype work. The Astro prototype and React Native phase answered important questions. The current repo is the result of those answers: native apps, API-driven content, target-based multi-site reuse, and agent-assisted development as the normal way to move quickly.
