package com.fiveq.ffci.ui.components

import android.content.Intent
import android.net.Uri
import android.util.Base64
import android.util.Log
import android.webkit.WebResourceRequest
import android.webkit.WebResourceResponse
import android.webkit.WebView
import android.webkit.WebViewClient
import java.net.URL
import javax.net.ssl.HttpsURLConnection
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.viewinterop.AndroidView

/**
 * Checks if a URL is a form page that should be opened in an external browser.
 * Matches the React Native implementation pattern.
 */
private fun isFormPage(url: String): Boolean {
    val formPaths = listOf("/prayer-request", "/chaplain-request", "/forms/")
    return formPaths.any { url.contains(it) }
}

@Composable
fun HtmlContent(
    html: String,
    onNavigate: ((String) -> Unit)? = null,
    modifier: Modifier = Modifier
) {
    // Debug: Log HTML content to check for buttons
    Log.d("HtmlContent", "Received HTML length: ${html.length}")
    val buttonMatches = Regex("class=\"[^\"]*_button[^\"]*\"").findAll(html).toList()
    if (buttonMatches.isNotEmpty()) {
        Log.d("HtmlContent", "Found ${buttonMatches.size} button class matches")
        buttonMatches.take(3).forEach { match ->
            val start = (match.range.first - 100).coerceAtLeast(0)
            val end = (match.range.last + 200).coerceAtMost(html.length)
            Log.d("HtmlContent", "Button HTML sample: ${html.substring(start, end)}")
        }
    } else {
        Log.w("HtmlContent", "No _button class found in HTML! First 1000 chars: ${html.take(1000)}")
    }
    
    // Fix images with empty src but valid srcset - extract first URL from srcset
    val srcsetPattern = Regex("srcset=\"(https?://[^\\s\"]+)")
    var fixedHtml = html

    srcsetPattern.find(html)?.let { match ->
        val firstUrl = match.groupValues[1]
        // Replace empty src="" with the found URL
        fixedHtml = fixedHtml.replace("src=\"\"", "src=\"$firstUrl\"")
    }

    // Wrap HTML with basic styling
    val styledHtml = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                    font-size: 17px;
                    line-height: 28px;
                    color: #334155;
                    padding: 0 16px;
                    margin: 0;
                }
                h1 {
                    font-size: 34px;
                    font-weight: 700;
                    margin-top: 36px;
                    margin-bottom: 20px;
                    color: #0f172a;
                    letter-spacing: -1px;
                    line-height: 40px;
                }
                h2 {
                    font-size: 28px;
                    font-weight: 700;
                    margin-top: 32px;
                    margin-bottom: 16px;
                    color: #0f172a;
                    letter-spacing: -0.6px;
                    line-height: 34px;
                }
                h3 {
                    font-size: 23px;
                    font-weight: 700;
                    margin-top: 16px;
                    margin-bottom: 12px;
                    color: #024D91;
                    line-height: 30px;
                    padding-left: 12px;
                    border-left: 3px solid #D9232A;
                }
                /* Headings and text inside colored sections inherit text color */
                ._section[style*="color"] h1,
                ._section[style*="color"] h2,
                ._section[style*="color"] h3,
                ._section[style*="color"] h4,
                ._section[style*="color"] h5,
                ._section[style*="color"] h6,
                ._section[style*="color"] p,
                ._section[style*="color"] ._text {
                    color: inherit !important;
                }
                /* Remove red border from h3 in colored sections */
                ._section[style*="color"] h3 {
                    border-left: none;
                    padding-left: 0;
                }
                h4 {
                    font-size: 20px;
                    font-weight: 600;
                    margin-top: 24px;
                    margin-bottom: 12px;
                    color: #0f172a;
                    line-height: 26px;
                }
                h5 {
                    font-size: 18px;
                    font-weight: 700;
                    margin-top: 20px;
                    margin-bottom: 10px;
                    color: #024D91;
                    line-height: 24px;
                }
                h6 {
                    font-size: 15px;
                    font-weight: 700;
                    margin-top: 18px;
                    margin-bottom: 8px;
                    color: #64748b;
                    line-height: 20px;
                    text-transform: uppercase;
                    letter-spacing: 1px;
                }
                p {
                    margin: 16px 0;
                }
                /* Tailwind spacing utilities */
                .mb-2 { margin-bottom: 8px !important; }
                .mb-4 { margin-bottom: 16px !important; }
                .mb-8 { margin-bottom: 32px !important; }
                .mb-12 { margin-bottom: 48px !important; }
                .mt-8 { margin-top: 32px !important; }
                .py-24 { padding-top: 96px !important; padding-bottom: 96px !important; }
                /* Text alignment */
                .text-center { text-align: center; }
                .text-left { text-align: left; }
                /* Base link styles - but NOT for buttons or image links */
                a:not([class*="_button"]):not([class*="_image-link"]):not([class*="image-link"]) {
                    color: #D9232A;
                    text-decoration: none;
                    font-weight: 600;
                    background: rgba(217, 35, 42, 0.08);
                    padding: 4px 6px;
                    border-bottom: 2px solid #D9232A;
                    border-radius: 4px;
                }
                /* Ensure buttons NEVER get base link styles */
                a[class*="_button"] {
                    /* Styles are defined separately below */
                }
                /* Remove red styling from image links - they shouldn't have borders/backgrounds */
                a._image-link,
                a[class*="_image-link"],
                a[class*="image-link"] {
                    background: none !important;
                    border: none !important;
                    border-bottom: none !important;
                    border-top: none !important;
                    border-left: none !important;
                    border-right: none !important;
                    padding: 0 !important;
                    border-radius: 0 !important;
                    display: block;
                }
                /* Remove red styling from ALL links except buttons - prevent artifacts */
                a:not([class*="_button"]) {
                    /* Only apply red styling to text links, not decorative elements */
                }
                /* Specifically target any decorative elements that might show red */
                ._button-group + a:not([class*="_button"]),
                a:not([class*="_button"]) + ._button-group,
                ._button-group ~ a:not([class*="_button"]) {
                    background: none !important;
                    border: none !important;
                    border-bottom: none !important;
                    padding: 0 !important;
                    border-radius: 0 !important;
                }
                /* Ensure buttons completely override base link styles */
                a[class*="_button"] {
                    /* Reset all inherited styles that might cause red artifacts */
                    background-image: none !important;
                    background-position: initial !important;
                    background-repeat: initial !important;
                    background-attachment: initial !important;
                    background-size: initial !important;
                }
                img {
                    max-width: 100%;
                    height: auto;
                    border-radius: 8px;
                    margin: 24px 0;
                }
                picture {
                    display: block;
                    width: 100%;
                }
                picture img {
                    width: 100%;
                    border-radius: 8px;
                    margin: 24px 0;
                }
                ._section {
                    position: relative;
                    padding: 24px 0;
                }
                /* First section doesn't need top padding */
                ._section:first-child {
                    padding-top: 0;
                }
                /* Reduce spacing for h3 that follows a section with background */
                ._section + ._section h3:first-child {
                    margin-top: 8px;
                }
                ._background {
                    position: absolute;
                    top: 0;
                    bottom: 0;
                    left: -16px;
                    right: -16px;
                    width: calc(100% + 32px);
                    margin-bottom: 0;
                    border-radius: 0;
                    overflow: hidden;
                    z-index: -1;
                    background-color: var(--bgColor, transparent);
                }
                ._background picture {
                    position: absolute;
                    top: 0;
                    left: 0;
                    width: 100%;
                    height: 100%;
                }
                ._background picture img {
                    width: 100%;
                    height: 100%;
                    object-fit: cover;
                    border-radius: 0;
                    margin: 0;
                }
                ul, ol {
                    padding-left: 24px;
                    margin: 16px 0;
                }
                li {
                    margin-bottom: 8px;
                }
                blockquote {
                    border-left: 4px solid #D9232A;
                    margin: 24px 0;
                    padding: 12px 0 12px 20px;
                    background: #f1f5f9;
                    font-style: italic;
                    font-size: 18px;
                    color: #475569;
                }
                hr {
                    margin: 32px 0;
                    border: none;
                    border-top: 1px solid #cbd5e1;
                }
                /* Hide any hr tags near buttons that might create red artifacts */
                ._button-group + hr,
                hr + ._button-group,
                ._button-group hr {
                    display: none !important;
                }
                /* Hide any decorative divs or spans with red borders/backgrounds near buttons */
                div[style*="border"],
                div[style*="background"],
                span[style*="border"],
                span[style*="background"] {
                    border: none !important;
                    background: none !important;
                }
                /* Specifically target any elements with red colors that might be decorative */
                div[style*="#D9232A"],
                div[style*="217, 35, 42"],
                span[style*="#D9232A"],
                span[style*="217, 35, 42"] {
                    display: none !important;
                }
                /* Button group - stack buttons vertically */
                ._button-group {
                    display: flex;
                    flex-direction: column;
                    gap: 12px;
                    margin: 16px 0;
                    border: none !important;
                    background: none !important;
                    padding: 0 !important;
                    position: relative;
                }
                /* Remove any pseudo-elements that might create decorative lines */
                ._button-group::before,
                ._button-group::after,
                a[class*="_button"]::before,
                a[class*="_button"]::after {
                    display: none !important;
                    content: none !important;
                }
                /* Hide any decorative elements that might appear between buttons */
                ._button-group > *:not(a[class*="_button"]) {
                    display: none !important;
                }
                /* Ensure no red artifacts from border-radius curves */
                ._button-group a[class*="_button"] {
                    overflow: hidden;
                    outline: none !important;
                    box-shadow: none !important;
                }
                /* Base button styles - use attribute selector to handle leading spaces in class */
                /* Override ALL base 'a' tag styles to prevent artifacts */
                a[class*="_button-priority"],
                a[class*="_button-secondary"],
                a[class*="_button"] {
                    display: block !important;
                    visibility: visible !important;
                    opacity: 1 !important;
                    width: 100%;
                    min-height: 56px;
                    padding: 18px 24px !important;
                    border-radius: 12px !important;
                    text-align: center;
                    font-size: 20px;
                    font-weight: 500;
                    letter-spacing: 0.5px;
                    text-decoration: none !important;
                    border: none !important;
                    border-bottom: none !important;
                    border-top: none !important;
                    border-left: none !important;
                    border-right: none !important;
                    background: none !important;
                    box-sizing: border-box;
                    margin: 8px 0 !important;
                    position: relative;
                    z-index: 1;
                }
                /* Primary button - red background */
                a[class*="_button-priority"] {
                    background-color: #D9232A !important;
                    background: #D9232A !important;
                    background-clip: padding-box !important;
                    color: white !important;
                    border: none !important;
                    border-bottom: none !important;
                    border-top: none !important;
                    border-left: none !important;
                    border-right: none !important;
                    /* Ensure no red shows outside the button */
                    clip-path: inset(0);
                }
                /* Secondary button - outline style */
                a[class*="_button-secondary"] {
                    background-color: transparent !important;
                    color: #D9232A !important;
                    border: 2px solid #D9232A;
                }
                /* Regular button (non-priority) */
                a[class*="_button"]:not([class*="_button-priority"]):not([class*="_button-secondary"]) {
                    background-color: #D9232A !important;
                    background: #D9232A !important;
                    color: white !important;
                    border: none !important;
                    border-bottom: none !important;
                    border-top: none !important;
                    border-left: none !important;
                    border-right: none !important;
                }
                /* Button span should inherit */
                a[class*="_button-priority"] span,
                a[class*="_button-secondary"] span,
                a[class*="_button"] span {
                    color: inherit;
                }
            </style>
        </head>
        <body>
            $fixedHtml
        </body>
        </html>
    """.trimIndent()

    AndroidView(
        modifier = modifier.fillMaxWidth(),
        factory = { context ->
            WebView(context).apply {
                // Clear WebView cache to ensure fresh content loads
                clearCache(true)
                clearHistory()
                
                settings.apply {
                    javaScriptEnabled = false
                    loadWithOverviewMode = true
                    useWideViewPort = true
                    // Disable cache to prevent stale content
                    cacheMode = android.webkit.WebSettings.LOAD_NO_CACHE
                }

                webViewClient = object : WebViewClient() {
                    private val credentials = Base64.encodeToString(
                        "fiveq:demo".toByteArray(),
                        Base64.NO_WRAP
                    )

                    override fun shouldInterceptRequest(
                        view: WebView?,
                        request: WebResourceRequest?
                    ): WebResourceResponse? {
                        val url = request?.url?.toString() ?: return null

                        // Add auth headers for ffci.fiveq.dev resources
                        if (url.contains("ffci.fiveq.dev")) {
                            try {
                                val connection = URL(url).openConnection() as HttpsURLConnection
                                connection.setRequestProperty("Authorization", "Basic $credentials")
                                connection.connect()

                                val contentType = connection.contentType ?: "image/jpeg"
                                val mimeType = contentType.split(";")[0]

                                return WebResourceResponse(
                                    mimeType,
                                    connection.contentEncoding ?: "UTF-8",
                                    connection.inputStream
                                )
                            } catch (e: Exception) {
                                return null
                            }
                        }
                        return null
                    }

                    override fun shouldOverrideUrlLoading(
                        view: WebView?,
                        request: WebResourceRequest?
                    ): Boolean {
                        val url = request?.url?.toString() ?: return false
                        Log.d("HtmlContent", "Link clicked: $url")

                        // Check for internal page links (e.g., /page/uuid format)
                        // Kirby 4 uses 16-character Base62 alphanumeric UUIDs (e.g., xhZj4ejQ65bRhrJg)
                        val pageMatch = Regex("/page/([a-zA-Z0-9-]+)").find(url)
                        if (pageMatch != null) {
                            val uuid = pageMatch.groupValues[1]
                            Log.d("HtmlContent", "Extracted UUID from /page/ link: $uuid")
                            // Validate it looks like a Kirby UUID (8+ alphanumeric chars, not purely numeric)
                            // Short numeric IDs like "3" indicate server-side transformation failed
                            val isValidUuid = uuid.length >= 8 && !uuid.all { it.isDigit() }
                            if (isValidUuid) {
                                Log.d("HtmlContent", "Valid UUID, navigating in-app: $uuid")
                                onNavigate?.invoke(uuid)
                                return true
                            } else {
                                // Looks like a numeric ID or slug, not a UUID - server transformation failed
                                // This shouldn't happen - pages should have proper UUIDs
                                Log.w("HtmlContent", "Invalid UUID format '/page/$uuid' - server should transform to proper UUID. Opening in browser.")
                                try {
                                    // Resolve relative URL to full URL for browser
                                    val fullUrl = if (url.startsWith("/")) {
                                        "https://ffci.fiveq.dev$url"
                                    } else {
                                        url
                                    }
                                    val intent = Intent(Intent.ACTION_VIEW, Uri.parse(fullUrl))
                                    view?.context?.startActivity(intent)
                                } catch (e: Exception) {
                                    Log.e("HtmlContent", "Failed to open /page/ link in browser: $url", e)
                                }
                                return true
                            }
                        }

                        // Form pages - open in external browser (matches RN behavior)
                        if (isFormPage(url)) {
                            try {
                                val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
                                view?.context?.startActivity(intent)
                            } catch (e: Exception) {
                                Log.e("HtmlContent", "Failed to open form page: $url", e)
                            }
                            return true
                        }

                        // Check if internal link (same domain or relative)
                        val baseHost = "ffci.fiveq.dev"
                        val isInternal = try {
                            val uri = Uri.parse(url)
                            uri.host == null || uri.host == baseHost || url.startsWith("/")
                        } catch (e: Exception) {
                            false
                        }

                        if (!isInternal) {
                            // External link - open in browser
                            try {
                                val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
                                view?.context?.startActivity(intent)
                            } catch (e: Exception) {
                                Log.e("HtmlContent", "Failed to open external link: $url", e)
                            }
                            return true
                        }

                        // Internal non-UUID link - open in browser
                        // These should ideally be transformed to /page/{uuid} format by the server
                        Log.d("HtmlContent", "Opening internal link in browser: $url")
                        try {
                            val fullUrl = if (url.startsWith("/")) {
                                "https://ffci.fiveq.dev$url"
                            } else {
                                url
                            }
                            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(fullUrl))
                            view?.context?.startActivity(intent)
                        } catch (e: Exception) {
                            Log.e("HtmlContent", "Failed to open internal link in browser: $url", e)
                        }
                        return true
                    }
                }

                loadDataWithBaseURL(
                    "https://ffci.fiveq.dev",
                    styledHtml,
                    "text/html",
                    "UTF-8",
                    null
                )
            }
        },
        update = { webView ->
            // Aggressively clear cache before each update to ensure fresh content
            webView.clearCache(true)
            webView.clearHistory()
            webView.settings.cacheMode = android.webkit.WebSettings.LOAD_NO_CACHE
            
            // Load fresh content
            webView.loadDataWithBaseURL(
                "https://ffci.fiveq.dev",
                styledHtml,
                "text/html",
                "UTF-8",
                null
            )
        }
    )
}
