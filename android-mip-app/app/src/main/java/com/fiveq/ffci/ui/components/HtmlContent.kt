package com.fiveq.ffci.ui.components

import android.content.Intent
import android.net.Uri
import android.util.Base64
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
                    margin-top: 28px;
                    margin-bottom: 12px;
                    color: #024D91;
                    line-height: 30px;
                    padding-left: 12px;
                    border-left: 3px solid #D9232A;
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
                a {
                    color: #D9232A;
                    text-decoration: none;
                    font-weight: 600;
                    background: rgba(217, 35, 42, 0.08);
                    padding: 4px 6px;
                    border-bottom: 2px solid #D9232A;
                    border-radius: 4px;
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
                ._background {
                    position: relative;
                    width: 100%;
                    min-height: 200px;
                    margin-bottom: 16px;
                    border-radius: 8px;
                    overflow: hidden;
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
                /* Button group - stack buttons vertically */
                ._button-group {
                    display: flex;
                    flex-direction: column;
                    gap: 12px;
                    margin: 16px 0;
                }
                /* Base button styles */
                ._button-priority,
                ._button-secondary,
                [class*="_button"] a,
                a[class*="_button"] {
                    display: block;
                    width: 100%;
                    padding: 18px 24px;
                    border-radius: 12px;
                    text-align: center;
                    font-size: 20px;
                    font-weight: 500;
                    letter-spacing: 0.5px;
                    text-decoration: none;
                    box-sizing: border-box;
                }
                /* Primary button - red background */
                ._button-priority {
                    background-color: #D9232A;
                    color: white !important;
                }
                /* Secondary button - outline style */
                ._button-secondary {
                    background-color: transparent;
                    color: #D9232A !important;
                    border: 2px solid #D9232A;
                }
                /* Button span should inherit */
                ._button-priority span,
                ._button-secondary span {
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
                settings.apply {
                    javaScriptEnabled = false
                    loadWithOverviewMode = true
                    useWideViewPort = true
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

                        // Check for internal page links (e.g., /page/uuid format)
                        val pageMatch = Regex("/page/([a-f0-9-]+)").find(url)
                        if (pageMatch != null) {
                            val uuid = pageMatch.groupValues[1]
                            onNavigate?.invoke(uuid)
                            return true
                        }

                        // Form pages - open in external browser (matches RN behavior)
                        if (isFormPage(url)) {
                            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
                            view?.context?.startActivity(intent)
                            return true
                        }

                        // Other external links - still block for now
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
