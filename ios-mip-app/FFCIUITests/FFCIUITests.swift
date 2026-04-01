import XCTest

final class FFCIUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testHomeScreenShowsFeaturedAndCapturesScreenshot() throws {
        let app = XCUIApplication()
        app.launch()

        let featuredByIdentifier = app.staticTexts["featured-section-title"]
        let featuredByLabel = app.staticTexts["Featured"]

        let featuredExists =
            featuredByIdentifier.waitForExistence(timeout: 45) ||
            featuredByLabel.waitForExistence(timeout: 5)

        XCTAssertTrue(featuredExists, "Expected the Featured section to appear on the home screen.")

        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Home screen with Featured"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
