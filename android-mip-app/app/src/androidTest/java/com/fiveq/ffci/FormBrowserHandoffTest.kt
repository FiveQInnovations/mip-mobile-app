package com.fiveq.ffci

import androidx.test.core.app.ActivityScenario
import androidx.test.espresso.web.sugar.Web.onWebView
import androidx.test.espresso.web.webdriver.DriverAtoms.findElement
import androidx.test.espresso.web.webdriver.DriverAtoms.webClick
import androidx.test.espresso.web.webdriver.Locator
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import androidx.test.uiautomator.By
import androidx.test.uiautomator.UiDevice
import androidx.test.uiautomator.UiObject2
import androidx.test.uiautomator.Until
import org.junit.After
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class FormBrowserHandoffTest {
    private lateinit var device: UiDevice
    private lateinit var scenario: ActivityScenario<MainActivity>

    @Before
    fun launchApp() {
        device = UiDevice.getInstance(InstrumentationRegistry.getInstrumentation())
        scenario = ActivityScenario.launch(MainActivity::class.java)
        waitForText("Home", "Expected the app home screen to appear.")
    }

    @After
    fun closeApp() {
        scenario.close()
    }

    @Test
    fun tappingContactFormOnContactUsOpensTheWebsiteInTheBrowser() {
        openContactUs()
        tapLinkOnPage(label = "Contact Form")

        assertBrowserOpened(
            failureMessage = "Expected Contact Form to leave the app and open its website in the browser."
        )
    }

    @Test
    fun tappingPrayerRequestOnContactUsOpensTheWebsiteInTheBrowser() {
        openContactUs()
        tapLinkOnPage(label = "Submit a Prayer Request")

        assertBrowserOpened(
            failureMessage = "Expected Prayer Request to leave the app and open its website in the browser."
        )
    }

    @Test
    fun selectingChaplainRequestFromSearchOpensTheWebsiteInTheBrowser() {
        waitForDescription("Search", "Expected Search to be available from the home screen.").click()

        val searchInput = device.wait(
            Until.findObject(By.clazz("android.widget.EditText")),
            ELEMENT_TIMEOUT_MILLIS
        )
        assertNotNull("Expected the search field to appear.", searchInput)
        searchInput.text = "Chaplain Request"

        val chaplainResult = device.wait(
            Until.findObject(
                By.clazz("android.widget.TextView").text("Chaplain Request")
            ),
            ELEMENT_TIMEOUT_MILLIS
        )
        assertNotNull("Expected search results to include Chaplain Request.", chaplainResult)
        chaplainResult!!.click()

        assertBrowserOpened(
            failureMessage = "Expected Chaplain Request from search to open its website in the browser."
        )
    }

    @Test
    fun tappingMembershipFormOpensTheWebsiteInTheBrowser() {
        openPageFromSearch(query = "Become a Member", title = "Become a Member")
        tapLinkOnPage(label = "Membership Form")

        assertBrowserOpened(
            failureMessage = "Expected Membership Form to leave the app and open its website in the browser."
        )
    }

    @Test
    fun tappingStartAChapterFormOpensTheWebsiteInTheBrowser() {
        openPageFromSearch(query = "Start a Chapter", title = "Start a Chapter")
        tapLinkOnPage(label = "Start a Chapter Form")

        assertBrowserOpened(
            failureMessage = "Expected Start a Chapter Form to leave the app and open its website in the browser."
        )
    }

    @Test
    fun tappingContactUsToStartAChapterOpensTheWebsiteInTheBrowser() {
        openPageFromSearch(query = "Start a Chapter", title = "Start a Chapter")
        tapLinkOnPage(label = "Contact Us to Start a Chapter")

        assertBrowserOpened(
            failureMessage = "Expected Contact Us to Start a Chapter to leave the app and open its website in the browser."
        )
    }

    private fun openContactUs() {
        waitForText("Connect", "Expected the Connect tab to appear.").click()
        waitForText("Contact Us", "Expected the Connect tab to open Contact Us.")
    }

    private fun openPageFromSearch(query: String, title: String) {
        waitForDescription("Search", "Expected Search to be available from the home screen.").click()

        val searchInput = device.wait(
            Until.findObject(By.clazz("android.widget.EditText")),
            ELEMENT_TIMEOUT_MILLIS
        )
        assertNotNull("Expected the search field to appear.", searchInput)
        searchInput.text = query

        val result = device.wait(
            Until.findObject(By.clazz("android.widget.TextView").text(title)),
            ELEMENT_TIMEOUT_MILLIS
        )
        assertNotNull("Expected search results to include $title.", result)
        result!!.click()

        waitForText(title, "Expected search to open $title.")
    }

    private fun waitForDescription(description: String, failureMessage: String): UiObject2 {
        val element = device.wait(
            Until.findObject(By.desc(description)),
            ELEMENT_TIMEOUT_MILLIS
        )
        assertNotNull(failureMessage, element)
        return element
    }

    private fun waitForText(text: String, failureMessage: String): UiObject2 {
        val element = device.wait(
            Until.findObject(By.text(text)),
            ELEMENT_TIMEOUT_MILLIS
        )
        assertNotNull(failureMessage, element)
        return element
    }

    private fun tapLinkOnPage(label: String) {
        val webViewIsReady = device.wait(
            Until.hasObject(By.clazz("android.webkit.WebView")),
            ELEMENT_TIMEOUT_MILLIS
        )
        assertTrue("Expected the page content to finish loading.", webViewIsReady)

        onWebView()
            .withElement(
                findElement(
                    Locator.XPATH,
                    "//a[contains(@aria-label, '$label')]"
                )
            )
            .perform(webClick())
    }

    private fun assertBrowserOpened(failureMessage: String) {
        val browserOpened = device.wait(
            Until.hasObject(By.pkg("com.android.chrome")),
            BROWSER_TIMEOUT_MILLIS
        )
        assertTrue(
            failureMessage,
            browserOpened
        )
    }

    private companion object {
        const val ELEMENT_TIMEOUT_MILLIS = 45_000L
        const val BROWSER_TIMEOUT_MILLIS = 10_000L
    }
}
