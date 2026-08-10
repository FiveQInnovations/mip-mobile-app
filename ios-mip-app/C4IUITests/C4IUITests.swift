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

    private func waitForTabButton(in app: XCUIApplication, named name: String, timeout: TimeInterval) -> XCUIElement? {
        let candidates = [
            app.tabBars.buttons[name].firstMatch,
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

    private func scrollUntilVisible(_ element: XCUIElement, in app: XCUIApplication, maxSwipes: Int = 4) -> Bool {
        if element.exists {
            return true
        }

        for _ in 0..<maxSwipes {
            app.swipeUp()
            if element.waitForExistence(timeout: 2) {
                return true
            }
        }

        return element.exists
    }

    func testHomeScreenLoadsSuccessfully() throws {
        let app = launchApp()

        let homeLoaded =
            app.staticTexts["Welcome to Christians for Israel"].firstMatch.waitForExistence(timeout: 45) ||
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

    func testHomeScreenShowsC4IContent() throws {
        let app = launchApp()

        let welcomeText = app.staticTexts["Welcome to Christians for Israel"].firstMatch
        XCTAssertTrue(
            welcomeText.waitForExistence(timeout: 45),
            "Expected the C4I home screen headline to appear."
        )

        XCTAssertTrue(
            app.staticTexts["Take Part in the Mission"].firstMatch.waitForExistence(timeout: 10),
            "Expected C4I mission CTA section to appear."
        )

        addScreenshot(named: "C4I Home content")
    }

    func testMainTabsExist() throws {
        let app = launchApp()

        for tabName in ["Home", "Ministries", "Watch", "Give", "More"] {
            XCTAssertNotNil(
                waitForTabButton(in: app, named: tabName, timeout: 45),
                "Expected the \(tabName) tab to appear."
            )
        }

        addScreenshot(named: "C4I Main tabs")
    }

    func testMinistriesTabShowsNestedPageContent() throws {
        let app = launchApp()

        guard let ministriesTab = waitForTabButton(in: app, named: "Ministries", timeout: 45) else {
            XCTFail("Expected the Ministries tab to appear.")
            return
        }
        ministriesTab.tap()

        let htmlContentView = app.webViews["html-content-view"].firstMatch

        XCTAssertTrue(
            htmlContentView.waitForExistence(timeout: 20),
            "Expected the Ministries page to render HTML content."
        )

        addScreenshot(named: "C4I Ministries page")
    }

    func testMoreTabShowsC4ISections() throws {
        let app = launchApp()

        guard let moreTab = waitForTabButton(in: app, named: "More", timeout: 45) else {
            XCTFail("Expected the More tab to appear.")
            return
        }
        moreTab.tap()

        for sectionName in ["About", "Learn", "Get Involved"] {
            XCTAssertTrue(
                app.staticTexts[sectionName].firstMatch.waitForExistence(timeout: 10),
                "Expected the \(sectionName) section in the C4I More menu."
            )
        }

        XCTAssertTrue(
            app.staticTexts["Donate"].firstMatch.waitForExistence(timeout: 10),
            "Expected Donate item in the C4I More menu."
        )

        XCTAssertTrue(
            scrollUntilVisible(app.staticTexts["Links"].firstMatch, in: app),
            "Expected the Links section in the C4I More menu."
        )

        XCTAssertTrue(
            scrollUntilVisible(app.staticTexts["Store"].firstMatch, in: app),
            "Expected Store item in the C4I More menu."
        )

        addScreenshot(named: "C4I More menu")
    }

    func testSearchOpensFromHome() throws {
        let app = launchApp()

        let searchButton = app.buttons["search-button"].firstMatch
        XCTAssertTrue(searchButton.waitForExistence(timeout: 45), "Expected the search button to appear on the home screen.")
        searchButton.tap()

        XCTAssertTrue(
            app.textFields["search-input"].firstMatch.waitForExistence(timeout: 20),
            "Expected the search input to appear after opening search."
        )

        addScreenshot(named: "C4I Search opened")
    }
}
