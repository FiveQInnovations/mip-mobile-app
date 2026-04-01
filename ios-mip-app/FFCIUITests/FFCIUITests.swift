import XCTest

final class FFCIUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()
        return app
    }

    private func addScreenshot(named name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testHomeScreenShowsFeaturedAndCapturesScreenshot() throws {
        let app = launchApp()

        let featuredByIdentifier = app.staticTexts["featured-section-title"]
        let featuredByLabel = app.staticTexts["Featured"]

        let featuredExists =
            featuredByIdentifier.waitForExistence(timeout: 45) ||
            featuredByLabel.waitForExistence(timeout: 5)

        XCTAssertTrue(featuredExists, "Expected the Featured section to appear on the home screen.")

        addScreenshot(named: "Home screen with Featured")
    }

    func testMediaTabShowsMediaResourcesAndCategories() throws {
        let app = launchApp()

        let mediaTab = app.tabBars.buttons["Media"]
        XCTAssertTrue(mediaTab.waitForExistence(timeout: 45), "Expected the Media tab to appear.")
        mediaTab.tap()

        let mediaResourcesTitle = app.navigationBars["Media Resources"].firstMatch
        let categoriesByIdentifier = app.staticTexts["media-categories-title"]
        let categoriesByLabel = app.staticTexts["Categories"]

        XCTAssertTrue(
            mediaResourcesTitle.waitForExistence(timeout: 20) || app.staticTexts["Media Resources"].waitForExistence(timeout: 5),
            "Expected Media Resources to appear after opening the Media tab."
        )
        XCTAssertTrue(
            categoriesByIdentifier.waitForExistence(timeout: 20) || categoriesByLabel.waitForExistence(timeout: 5),
            "Expected Categories to appear on the Media screen."
        )

        addScreenshot(named: "Media Resources with Categories")
    }
}
