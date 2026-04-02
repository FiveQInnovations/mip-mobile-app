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

    private func waitForTabButton(in app: XCUIApplication, named name: String, timeout: TimeInterval) -> XCUIElement? {
        let candidates = [
            app.tabBars.buttons[name].firstMatch,
            app.navigationBars.buttons[name].firstMatch,
            app.buttons[name].firstMatch
        ]

        let deadline = Date().addingTimeInterval(timeout)
        repeat {
            if let candidate = candidates.first(where: \.exists) {
                return candidate
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.25))
        } while Date() < deadline

        return candidates.first(where: \.exists)
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

        guard let mediaTab = waitForTabButton(in: app, named: "Media", timeout: 45) else {
            XCTFail("Expected the Media tab to appear.")
            return
        }
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

        guard let resourcesTab = waitForTabButton(in: app, named: "Resources", timeout: 45) else {
            XCTFail("Expected the Resources tab to appear.")
            return
        }
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

        guard let connectTab = waitForTabButton(in: app, named: "Connect", timeout: 45) else {
            XCTFail("Expected the Connect tab to appear.")
            return
        }
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

    func testSearchShowsResults() throws {
        let app = launchApp()

        let searchButton = app.buttons["search-button"].firstMatch
        XCTAssertTrue(searchButton.waitForExistence(timeout: 45), "Expected the search button to appear on the home screen.")
        searchButton.tap()

        let searchInput = app.textFields["search-input"].firstMatch
        XCTAssertTrue(searchInput.waitForExistence(timeout: 20), "Expected the search input to appear after opening search.")

        searchInput.tap()
        searchInput.typeText("Become a Member")

        let searchResultRow = app.buttons["search-result-row"].firstMatch
        let searchResultText = app.staticTexts["Become a Member"].firstMatch

        XCTAssertTrue(
            searchResultRow.waitForExistence(timeout: 20),
            "Expected at least one search result to appear."
        )
        XCTAssertTrue(
            searchResultText.waitForExistence(timeout: 10),
            "Expected the search results to include Become a Member."
        )
        XCTAssertFalse(
            app.staticTexts["No results found"].exists,
            "Expected search results instead of the empty state."
        )

        addScreenshot(named: "Search results")
    }
}
