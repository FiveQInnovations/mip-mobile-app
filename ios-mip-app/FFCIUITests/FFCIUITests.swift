import XCTest

class FFCIUITestCase: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        let configuredBaseURL = ProcessInfo.processInfo.environment["FFCI_UI_TEST_API_BASE_URL"]?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        app.launchEnvironment["FFCI_API_BASE_URL_OVERRIDE"] = configuredBaseURL ?? ""
        app.launch()
        return app
    }

    func launchProductionApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["FFCI_API_BASE_URL_OVERRIDE"] = ""
        app.launch()
        return app
    }

    func addScreenshot(named name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func waitForTabButton(in app: XCUIApplication, named name: String, timeout: TimeInterval) -> XCUIElement? {
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

    func openContactUs(in app: XCUIApplication) -> XCUIElement? {
        guard let connectTab = waitForTabButton(in: app, named: "Connect", timeout: 45) else {
            XCTFail("Expected the Connect tab to appear.")
            return nil
        }
        connectTab.tap()

        let contactTitle = app.navigationBars["Contact Us"].firstMatch
        let htmlContentView = app.webViews["html-content-view"].firstMatch
        XCTAssertTrue(
            contactTitle.waitForExistence(timeout: 20) || app.staticTexts["Contact Us"].waitForExistence(timeout: 5),
            "Expected the Connect tab to open the Contact Us page."
        )
        XCTAssertTrue(
            htmlContentView.waitForExistence(timeout: 20),
            "Expected the Contact Us page to render HTML content."
        )

        return htmlContentView.exists ? htmlContentView : nil
    }

    func openPageFromSearch(
        in app: XCUIApplication,
        query: String,
        title: String
    ) -> XCUIElement? {
        let searchButton = app.buttons["search-button"].firstMatch
        guard searchButton.waitForExistence(timeout: 45) else {
            XCTFail("Expected the search button to appear on the home screen.")
            return nil
        }
        searchButton.tap()

        let searchInput = app.textFields["search-input"].firstMatch
        guard searchInput.waitForExistence(timeout: 20) else {
            XCTFail("Expected the search input to appear after opening search.")
            return nil
        }
        searchInput.tap()
        searchInput.typeText(query)

        let result = app.staticTexts[title].firstMatch
        guard result.waitForExistence(timeout: 20) else {
            XCTFail("Expected search results to include \(title).")
            return nil
        }
        result.tap()

        let pageTitle = app.navigationBars[title].firstMatch
        let htmlContentView = app.webViews["html-content-view"].firstMatch
        XCTAssertTrue(
            pageTitle.waitForExistence(timeout: 20) || app.staticTexts[title].waitForExistence(timeout: 5),
            "Expected search to open \(title)."
        )
        XCTAssertTrue(
            htmlContentView.waitForExistence(timeout: 20),
            "Expected \(title) to render HTML content."
        )

        return htmlContentView.exists ? htmlContentView : nil
    }

    func formControl(
        labeled label: String,
        in htmlContentView: XCUIElement,
        app: XCUIApplication
    ) -> XCUIElement? {
        let labelPredicate = NSPredicate(format: "label CONTAINS[c] %@", label)
        let link = htmlContentView.links.matching(labelPredicate).firstMatch
        let button = htmlContentView.buttons.matching(labelPredicate).firstMatch
        let control = link.waitForExistence(timeout: 10) ? link : button

        guard control.exists else {
            XCTFail("Expected the \(label) form control.")
            return nil
        }

        let topSafeArea = app.frame.minY + 100
        let bottomSafeArea = app.frame.maxY - 140
        for _ in 0..<24 {
            let controlFrame = control.frame
            let isVisiblyOnScreen =
                controlFrame.minY >= topSafeArea &&
                controlFrame.maxY <= bottomSafeArea

            if control.isHittable && isVisiblyOnScreen {
                return control
            }

            if controlFrame.maxY < topSafeArea {
                htmlContentView.swipeDown()
            } else {
                htmlContentView.swipeUp()
            }
        }

        let finalFrame = control.frame
        let isVisiblyOnScreen =
            finalFrame.minY >= topSafeArea &&
            finalFrame.maxY <= bottomSafeArea
        let isReadyToTap = control.isHittable && isVisiblyOnScreen
        XCTAssertTrue(isReadyToTap, "Expected the \(label) form control to become visibly tappable.")
        return isReadyToTap ? control : nil
    }

    func contactUsControl(
        labeled label: String,
        in app: XCUIApplication
    ) -> XCUIElement? {
        guard let htmlContentView = openContactUs(in: app) else {
            return nil
        }
        return formControl(labeled: label, in: htmlContentView, app: app)
    }

    func assertOpensSafari(
        control: XCUIElement,
        screenshotName: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let controlLabel = control.label
        control.tap()

        let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
        XCTAssertTrue(
            safari.wait(for: .runningForeground, timeout: 20),
            "Expected \(controlLabel) to open in Safari.",
            file: file,
            line: line
        )

        if safari.state == .runningForeground {
            addScreenshot(named: screenshotName)
        }
    }

    func assertPageContentBecomesVisible(
        containing text: String,
        in htmlContentView: XCUIElement,
        app: XCUIApplication,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let predicate = NSPredicate(format: "label CONTAINS[c] %@", text)
        let content = htmlContentView.descendants(matching: .any).matching(predicate).firstMatch

        guard content.waitForExistence(timeout: 20) else {
            XCTFail("Expected page content containing \(text).", file: file, line: line)
            return
        }

        let pageFrame = htmlContentView.frame
        let contentFrame = content.frame
        XCTAssertTrue(
            contentFrame.minY >= pageFrame.minY && contentFrame.maxY <= pageFrame.maxY,
            "Expected the page to include its content below the hero.",
            file: file,
            line: line
        )

        let visiblePageArea = CGRect(
            x: app.frame.minX,
            y: app.frame.minY + 100,
            width: app.frame.width,
            height: app.frame.height - 240
        )

        for _ in 0..<12 {
            if content.frame.intersects(visiblePageArea) {
                return
            }
            htmlContentView.swipeUp()
        }

        XCTFail("Expected page content containing \(text) to become visible when scrolling.", file: file, line: line)
    }

}

final class FFCIUITests: FFCIUITestCase {
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

    func testTappingMediaTabOpensSafari() throws {
        let app = launchApp()

        guard let mediaTab = waitForTabButton(in: app, named: "Media", timeout: 45) else {
            XCTFail("Expected the Media tab to appear.")
            return
        }

        assertOpensSafari(control: mediaTab, screenshotName: "Media website in Safari")
    }

    func testPartnershipsTabStillShowsItsIntroductionAfterSwitchingTabs() throws {
        let app = launchApp()

        guard let partnershipsTab = waitForTabButton(in: app, named: "Partnerships", timeout: 45) else {
            XCTFail("Expected the Partnerships tab to appear.")
            return
        }
        partnershipsTab.tap()

        let partnershipsTitle = app.navigationBars["Partnerships"].firstMatch
        let htmlContentView = app.webViews["html-content-view"].firstMatch

        XCTAssertTrue(
            partnershipsTitle.waitForExistence(timeout: 20) || app.staticTexts["Partnerships"].waitForExistence(timeout: 5),
            "Expected Partnerships to appear after opening the Partnerships tab."
        )
        XCTAssertTrue(
            htmlContentView.waitForExistence(timeout: 20),
            "Expected the Partnerships screen to show HTML page content."
        )
        assertPageContentBecomesVisible(
            containing: "Stronger Together in Service and Mission",
            in: htmlContentView,
            app: app
        )

        guard let homeTab = waitForTabButton(in: app, named: "Home", timeout: 10) else {
            XCTFail("Expected the Home tab to appear.")
            return
        }
        homeTab.tap()
        partnershipsTab.tap()

        let revisitedHtmlContentView = app.webViews["html-content-view"].firstMatch
        XCTAssertTrue(
            revisitedHtmlContentView.waitForExistence(timeout: 20),
            "Expected the Partnerships page to reappear after switching tabs."
        )
        assertPageContentBecomesVisible(
            containing: "Stronger Together in Service and Mission",
            in: revisitedHtmlContentView,
            app: app
        )

        addScreenshot(named: "Partnerships introduction")
    }

    func testConnectTabStillShowsContactDetailsAfterSwitchingTabs() throws {
        let app = launchApp()

        guard let connectTab = waitForTabButton(in: app, named: "Connect", timeout: 45) else {
            XCTFail("Expected the Connect tab to appear.")
            return
        }
        connectTab.tap()

        let connectTitle = app.navigationBars["Contact Us"].firstMatch
        let htmlContentView = app.webViews["html-content-view"].firstMatch

        XCTAssertTrue(
            connectTitle.waitForExistence(timeout: 20) || app.staticTexts["Contact Us"].waitForExistence(timeout: 5),
            "Expected Contact Us to appear after opening the Connect tab."
        )
        XCTAssertTrue(
            htmlContentView.waitForExistence(timeout: 20),
            "Expected the Connect screen to show HTML page content."
        )
        assertPageContentBecomesVisible(
            containing: "Mailing Address",
            in: htmlContentView,
            app: app
        )

        guard let homeTab = waitForTabButton(in: app, named: "Home", timeout: 10) else {
            XCTFail("Expected the Home tab to appear.")
            return
        }
        homeTab.tap()
        connectTab.tap()

        let revisitedHtmlContentView = app.webViews["html-content-view"].firstMatch
        XCTAssertTrue(
            revisitedHtmlContentView.waitForExistence(timeout: 20),
            "Expected the Contact Us page to reappear after switching tabs."
        )
        assertPageContentBecomesVisible(
            containing: "Mailing Address",
            in: revisitedHtmlContentView,
            app: app
        )

        addScreenshot(named: "Connect contact details")
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

    func testTappingPrayerRequestOnContactUsOpensSafari() throws {
        let app = launchApp()

        guard let prayerControl = contactUsControl(
            labeled: "Submit a Prayer Request",
            in: app
        ) else {
            return
        }

        assertOpensSafari(
            control: prayerControl,
            screenshotName: "Prayer Request in Safari"
        )
    }

    func testTappingContactFormOnContactUsOpensSafari() throws {
        let app = launchApp()

        guard let contactControl = contactUsControl(
            labeled: "Contact Form",
            in: app
        ) else {
            return
        }

        assertOpensSafari(
            control: contactControl,
            screenshotName: "Contact Form in Safari"
        )
    }

    func testRequestAChaplainAtBottomOfContactUsCanBeReachedAndOpened() throws {
        let app = launchApp()

        guard let chaplainControl = contactUsControl(
            labeled: "Request a Chaplain",
            in: app
        ) else {
            return
        }

        assertOpensSafari(
            control: chaplainControl,
            screenshotName: "Request a Chaplain in Safari"
        )
    }

    func testSelectingChaplainRequestFromSearchOpensSafari() throws {
        let app = launchApp()

        let searchButton = app.buttons["search-button"].firstMatch
        guard searchButton.waitForExistence(timeout: 45) else {
            XCTFail("Expected the search button to appear on the home screen.")
            return
        }
        searchButton.tap()

        let searchInput = app.textFields["search-input"].firstMatch
        guard searchInput.waitForExistence(timeout: 20) else {
            XCTFail("Expected the search input to appear after opening search.")
            return
        }
        searchInput.tap()
        searchInput.typeText("Chaplain Request")

        let chaplainResult = app.staticTexts["Chaplain Request"].firstMatch
        guard chaplainResult.waitForExistence(timeout: 20) else {
            XCTFail("Expected search results to include Chaplain Request.")
            return
        }
        chaplainResult.tap()

        let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
        XCTAssertTrue(
            safari.wait(for: .runningForeground, timeout: 20),
            "Expected Chaplain Request from search to open in Safari instead of an empty page in the app."
        )

        if safari.state == .runningForeground {
            addScreenshot(named: "Chaplain Request in Safari")
        }
    }

    func testTappingMembershipFormOpensSafari() throws {
        let app = launchApp()

        guard let htmlContentView = openPageFromSearch(
            in: app,
            query: "Become a Member",
            title: "Become a Member"
        ),
        let membershipControl = formControl(
            labeled: "Membership Form",
            in: htmlContentView,
            app: app
        ) else {
            return
        }

        assertOpensSafari(
            control: membershipControl,
            screenshotName: "Membership Form in Safari"
        )
    }

    func testTappingStartAChapterFormOpensSafari() throws {
        let app = launchApp()

        guard let htmlContentView = openPageFromSearch(
            in: app,
            query: "Start a Chapter",
            title: "Start a Chapter"
        ),
        let chapterControl = formControl(
            labeled: "Start a Chapter Form",
            in: htmlContentView,
            app: app
        ) else {
            return
        }

        assertOpensSafari(
            control: chapterControl,
            screenshotName: "Start a Chapter Form in Safari"
        )
    }

    func testTappingContactUsToStartAChapterOpensSafari() throws {
        let app = launchApp()

        guard let htmlContentView = openPageFromSearch(
            in: app,
            query: "Start a Chapter",
            title: "Start a Chapter"
        ),
        let chapterControl = formControl(
            labeled: "Contact Us to Start a Chapter",
            in: htmlContentView,
            app: app
        ) else {
            return
        }

        assertOpensSafari(
            control: chapterControl,
            screenshotName: "Contact Us to Start a Chapter in Safari"
        )
    }
}

final class FFCIProductionSmokeTests: FFCIUITestCase {
    func testPublishedHomeShowsFeaturedContent() throws {
        let app = launchProductionApp()
        let featuredByIdentifier = app.staticTexts["featured-section-title"]
        let featuredByLabel = app.staticTexts["Featured"]

        XCTAssertTrue(
            featuredByIdentifier.waitForExistence(timeout: 45) ||
                featuredByLabel.waitForExistence(timeout: 5),
            "Expected the published home screen to show Featured content."
        )
    }

    func testPublishedConnectPageShowsContactDetails() throws {
        let app = launchProductionApp()
        guard let htmlContentView = openContactUs(in: app) else {
            return
        }

        assertPageContentBecomesVisible(
            containing: "Mailing Address",
            in: htmlContentView,
            app: app
        )
    }

    func testPublishedPrayerRequestOpensInSafari() throws {
        let app = launchProductionApp()
        guard let prayerControl = contactUsControl(
            labeled: "Submit a Prayer Request",
            in: app
        ) else {
            return
        }

        assertOpensSafari(
            control: prayerControl,
            screenshotName: "Published Prayer Request in Safari"
        )
    }

    func testPublishedStartAChapterContactOpensInSafari() throws {
        let app = launchProductionApp()
        guard let htmlContentView = openPageFromSearch(
            in: app,
            query: "Start a Chapter",
            title: "Start a Chapter"
        ),
        let chapterControl = formControl(
            labeled: "Contact Us to Start a Chapter",
            in: htmlContentView,
            app: app
        ) else {
            return
        }

        assertOpensSafari(
            control: chapterControl,
            screenshotName: "Published Start a Chapter contact in Safari"
        )
    }
}
