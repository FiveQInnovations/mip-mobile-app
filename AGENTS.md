# AGENTS.md

- ALWAYS USE PARALLEL TOOLS WHEN APPLICABLE.
- The iOS app lives in `ios-mip-app/`; keep guidance and code changes scoped there unless the task clearly touches other project files.
- Prefer automation: execute requested actions without confirmation unless blocked by missing information, signing constraints, simulator availability, or safety/irreversibility.
- Do not commit changes unless explicitly asked.

## Project Layout

- `ios-mip-app/MIP-iOS.xcodeproj` is the Xcode project.
- Shared Swift and SwiftUI code lives in `ios-mip-app/Shared/`.
- App-specific targets live in `ios-mip-app/C4I/` and `ios-mip-app/FFCI/`.
- UI tests live in `ios-mip-app/C4IUITests/` and `ios-mip-app/FFCIUITests/`.
- Each app target owns its bundled configuration, including `SiteConfig.plist` and any Firebase plist files.
- The shared schemes are `C4I` and `FFCI`.

## Swift And iOS Style

### General Principles

- Keep changes small, focused, and idiomatic Swift.
- Preserve existing SwiftUI patterns before introducing new architecture.
- Prefer value types (`struct`, `enum`) for models, view configuration, and SwiftUI views.
- Use reference types (`class`, `ObservableObject`) only for shared mutable state, service singletons, or object lifetimes that require identity.
- Prefer `let` over `var`; only use mutable state where mutation is required.
- Prefer early returns and `guard` for validation and failure paths.
- Avoid force unwraps. If an existing API requires one, keep the scope narrow and ensure the value is truly invariant.
- Avoid adding global state. Existing singletons such as `MipApiClient.shared` and `SiteConfig.shared` are established patterns; do not add more unless there is a concrete need.
- Use `os.log` / `Logger` for diagnostic logging. Do not use `print` in app code.
- Keep comments rare and useful. Explain non-obvious behavior, not what each line does.

### SwiftUI

- Keep views declarative and split only when it improves readability or reuse.
- Prefer `@State` for local view state, `@StateObject` for view-owned observable objects, and `@Environment` for app-wide dependencies already represented as environment values.
- Keep shared UI generic and driven by `AppProfile`, `SiteData`, and target-specific configuration rather than hardcoding one app's content in `Shared/`.
- Target-specific UI or behavior belongs in `C4I/` or `FFCI/` unless it is useful to both apps.
- Maintain accessibility identifiers used by UI tests, such as `search-button`, `search-input`, `search-result-row`, `html-content-view`, and section title identifiers.
- Use asset colors and existing brand assets where present instead of hardcoded colors in reusable views.

### Networking And Data

- Keep API access centralized in `Shared/API/`.
- Decode responses with `Codable` models from `ApiModels.swift` or nearby model files.
- Preserve async/await APIs for networking and cache access.
- Surface user-facing failures through view state rather than crashing, except for required bundled configuration such as malformed `SiteConfig.plist`.
- Do not log secrets, API keys, Basic Auth credentials, full auth headers, or Firebase configuration contents.

### App Targets

- `C4I` and `FFCI` are separate app targets sharing the same core UI.
- When changing shared behavior, consider both app profiles and both UI test suites.
- Keep target-specific strings, tabs, home content, assets, and configuration in the target folder when possible.
- Firebase configuration is conditional at launch; do not make analytics initialization crash when a plist is absent.

## Build And Test

- List schemes with:

```sh
xcodebuild -list -project ios-mip-app/MIP-iOS.xcodeproj
```

- Build C4I for the simulator with:

```sh
xcodebuild -project ios-mip-app/MIP-iOS.xcodeproj -scheme C4I -destination 'platform=iOS Simulator,name=iPhone 16' build
```

- Build FFCI for the simulator with:

```sh
xcodebuild -project ios-mip-app/MIP-iOS.xcodeproj -scheme FFCI -destination 'platform=iOS Simulator,name=iPhone 16' build
```

- Run C4I UI tests with:

```sh
xcodebuild -project ios-mip-app/MIP-iOS.xcodeproj -scheme C4I -destination 'platform=iOS Simulator,name=iPhone 16' test
```

- Run FFCI UI tests with:

```sh
xcodebuild -project ios-mip-app/MIP-iOS.xcodeproj -scheme FFCI -destination 'platform=iOS Simulator,name=iPhone 16' test
```

- If `iPhone 16` is unavailable, inspect installed simulators with `xcrun simctl list devices available` and use an available iOS simulator.
- UI tests depend on live app content and can take time to load; preserve existing generous waits unless replacing them with a more reliable synchronization point.
- When changing shared code, prefer building both `C4I` and `FFCI`. When changing only target-specific code, build at least that target.

## Dependencies And Xcode Files

- Swift package dependencies are resolved by Xcode through `MIP-iOS.xcodeproj`.
- Avoid manual edits to `project.pbxproj` unless necessary. Prefer Xcode-generated project changes when adding files, targets, packages, assets, or build settings.
- If manually editing project files, keep changes minimal and verify with `xcodebuild -list` or a targeted build.
- Do not move bundled plist files between targets without verifying target membership and runtime lookup behavior.

## Security

- Treat `SiteConfig.plist`, Firebase plist files, auth headers, API keys, and backend URLs as sensitive unless the user explicitly says otherwise.
- Never add real credentials to examples, tests, docs, or logs.
- Before committing, inspect changes for secrets and unrelated generated files.

## Pull Requests And Reviews

- Summaries should mention which target(s) are affected: shared, C4I, FFCI, or tests.
- Include the exact `xcodebuild` commands run and whether simulator tests were skipped.
- In code review, prioritize crashes, target-specific regressions, broken UI test identifiers, configuration handling, networking failures, and missing validation across both app targets.
