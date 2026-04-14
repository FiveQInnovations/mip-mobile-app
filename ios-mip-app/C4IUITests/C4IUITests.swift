import XCTest

final class C4IUITests: XCTestCase {
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

    func testHomeScreenLoadsSuccessfully() throws {
        let app = launchApp()

        let homeLoaded =
            app.staticTexts["featured-section-title"].waitForExistence(timeout: 45) ||
            app.tabBars.firstMatch.waitForExistence(timeout: 45)

        XCTAssertTrue(homeLoaded, "Expected the home screen to load.")
        addScreenshot(named: "C4I Home screen")
    }

    func testSearchButtonExists() throws {
        let app = launchApp()

        let searchButton = app.buttons["search-button"].firstMatch
        XCTAssertTrue(
            searchButton.waitForExistence(timeout: 45),
            "Expected the search button to appear on the home screen."
        )

        addScreenshot(named: "C4I Home with search button")
    }
}
