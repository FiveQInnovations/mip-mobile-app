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

    func testResourcesTabShowsResourcesList() throws {
        let app = launchApp()

        let resourcesTab = app.tabBars.buttons["Resources"]
        XCTAssertTrue(resourcesTab.waitForExistence(timeout: 45), "Expected the Resources tab to appear.")
        resourcesTab.tap()

        let resourcesTitle = app.navigationBars["Resources"].firstMatch
        let htmlContentView = app.webViews["html-content-view"].firstMatch

        XCTAssertTrue(
            resourcesTitle.waitForExistence(timeout: 20) || app.staticTexts["Resources"].waitForExistence(timeout: 5),
            "Expected Resources to appear after opening the Resources tab."
        )
        XCTAssertTrue(
            htmlContentView.waitForExistence(timeout: 20),
            "Expected the Resources screen to show HTML page content."
        )

        addScreenshot(named: "Resources list")
    }

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
}
