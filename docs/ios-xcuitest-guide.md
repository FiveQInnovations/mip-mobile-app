# iOS XCUI Testing Guide

This guide is for a senior React Native developer who has not worked in Swift before.

The short version: if Maestro felt good at first but became flaky over time, XCUI Test is the native iOS option that gives you tighter integration with the simulator, app launch lifecycle, and Xcode tooling.

## Why We Moved Away From Maestro

Maestro was attractive because:

- It is easy to start.
- The YAML flows are approachable.
- It works across platforms.
- It is good for quick smoke tests.

The pain we hit in practice was reliability, especially over time:

- It could become flaky after the simulator had been sitting open for hours.
- It could fail to reliably launch the app.
- It could fail to reliably detect that the app had launched.
- When it failed, the debugging loop was less native to iOS tooling.

For App Store screenshots and high-confidence repeatable checks, those problems matter more than the initial setup speed.

## Why XCUI Test Was Better Here

XCUI Test gave us a few concrete benefits:

- It launches through Xcode's native test runner.
- It uses Apple's own accessibility tree and simulator integration.
- Screenshots are first-class test attachments inside the `.xcresult` bundle.
- Failures come with native Xcode logs, UI hierarchy dumps, recordings, and attachments.
- It was stable in repeat runs.

In this project, we ran the `Resources` and `Connect` tests 30 times at night and 30 times again the next morning after the simulator had been left open for hours. Both runs finished `30/30` green.

## Mental Model For A React Native Dev

You do not need to know much Swift to be productive in XCUI Test.

Think of it like this:

- `XCUIApplication()` is your app driver.
- `app.tabBars.buttons["Media"]` is like querying by accessible label.
- `waitForExistence(timeout:)` is your explicit wait.
- `tap()` is your interaction.
- `XCTAssertTrue(...)` is your assertion.
- `XCUIScreen.main.screenshot()` gives you a screenshot attachment.

You are not writing app logic in the test. You are driving the app from the outside.

## What A Test Looks Like

This project's tests live in `ios-mip-app/FFCIUITests/FFCIUITests.swift`.

Example:

```swift
func testConnectTabShowsConnectPage() throws {
    let app = launchApp()

    let connectTab = app.tabBars.buttons["Connect"]
    XCTAssertTrue(connectTab.waitForExistence(timeout: 45), "Expected the Connect tab to appear.")
    connectTab.tap()

    let connectTitle = app.navigationBars["Connect With Us"].firstMatch
    let htmlContentView = app.webViews["html-content-view"].firstMatch

    XCTAssertTrue(
        connectTitle.waitForExistence(timeout: 20) || app.staticTexts["Connect With Us"].waitForExistence(timeout: 5),
        "Expected Connect With Us to appear after opening the Connect tab."
    )
    XCTAssertTrue(
        htmlContentView.waitForExistence(timeout: 20),
        "Expected the Connect screen to show HTML page content."
    )

    addScreenshot(named: "Connect page")
}
```

A few takeaways:

- The test mostly reads like UI automation pseudocode.
- The hard part is usually finding stable accessibility hooks, not Swift syntax.
- Adding one good accessibility identifier in production code often makes the test much more stable.

## The Smallest Swift You Need To Know

You can read most XCUI tests with only a few concepts:

- `let` means "constant".
- `func` defines a function.
- `throws` means the function can fail.
- `firstMatch` gets the first matching UI element.
- Dot calls like `.tap()` and `.waitForExistence(...)` are just method calls.

You do not need to become a SwiftUI expert to maintain these tests.

## Where The Hooks Live

The tests became much more reliable once we used stable accessibility hooks.

Examples in this codebase:

- `featured-section-title` in `ios-mip-app/FFCI/Views/FeaturedSectionView.swift`
- `media-categories-title` in `ios-mip-app/FFCI/Views/TabPageView.swift`
- `html-content-view` in `ios-mip-app/FFCI/Views/HtmlContentView.swift`

The pattern is simple:

1. Add a stable `accessibilityIdentifier` in app code.
2. Prefer that identifier in the UI test.
3. Fall back to visible text only when necessary.

## How To Run A Single Test

From the repo root:

```bash
xcodebuild \
  -project "/Users/anthony/mip-mobile-app/ios-mip-app/FFCI.xcodeproj" \
  -scheme FFCI \
  -destination 'id=D9DE6784-CB62-4AC3-A686-4D445A0E7B57' \
  -derivedDataPath "/Users/anthony/mip-mobile-app/ios-mip-app/build-ui-tests" \
  -only-testing:FFCIUITests/FFCIUITests/testConnectTabShowsConnectPage \
  test
```

To run multiple screenshot tests together:

```bash
xcodebuild \
  -project "/Users/anthony/mip-mobile-app/ios-mip-app/FFCI.xcodeproj" \
  -scheme FFCI \
  -destination 'id=D9DE6784-CB62-4AC3-A686-4D445A0E7B57' \
  -derivedDataPath "/Users/anthony/mip-mobile-app/ios-mip-app/build-ui-tests" \
  -only-testing:FFCIUITests/FFCIUITests/testMediaTabShowsMediaResourcesAndCategories \
  -only-testing:FFCIUITests/FFCIUITests/testResourcesTabShowsResourcesList \
  -only-testing:FFCIUITests/FFCIUITests/testConnectTabShowsConnectPage \
  test
```

## Where Screenshots Go

XCUI screenshots are stored as attachments in the `.xcresult` bundle.

Example result bundle:

```bash
ios-mip-app/build-ui-tests/Logs/Test/Test-FFCI-YYYY.MM.DD_HH-MM-SS--0500.xcresult
```

Export the attachments like this:

```bash
xcrun xcresulttool export attachments \
  --path "ios-mip-app/build-ui-tests/Logs/Test/Test-FFCI-YYYY.MM.DD_HH-MM-SS--0500.xcresult" \
  --output-path "temp/submission-screenshots"
```

That gives you PNGs you can review or use for App Store submission.

## How To Think About Stability

A UI test is not trustworthy just because it passes once.

What helped here:

- Use explicit waits instead of assuming immediate rendering.
- Assert on stable identifiers.
- Keep each test focused on one screen and a few strong signals.
- Use Break and Verify: intentionally break the production selector and make sure the test goes red.
- Repeat runs in a loop to detect launch and detection flakiness.

In other words, treat UI tests like production monitoring checks, not just demos.

## Practical Recommendation

For this Swift app:

- Use XCUI Test for iOS screenshot flows and important iOS smoke paths.
- Keep accessibility identifiers intentional and stable.
- Use Maestro only if you need a cross-platform layer and can tolerate more flake.
- Prefer native XCTest artifacts when your main goal is App Store screenshot generation and confidence in iOS behavior.

If you already know React Native well, the fastest way into XCUI is:

1. Read `ios-mip-app/FFCIUITests/FFCIUITests.swift`
2. Run one test with `xcodebuild`
3. Add one selector
4. Add one assertion
5. Add one screenshot attachment

That is enough to become useful quickly.
