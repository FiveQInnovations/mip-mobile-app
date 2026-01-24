package com.fiveq.ffci.ui.components

import android.webkit.WebResourceRequest
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.viewinterop.AndroidView

@Composable
fun HtmlContent(
    html: String,
    onNavigate: ((String) -> Unit)? = null,
    modifier: Modifier = Modifier
) {
    // Wrap HTML with basic styling
    val styledHtml = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                    font-size: 16px;
                    line-height: 1.6;
                    color: #0f172a;
                    padding: 0 16px;
                    margin: 0;
                }
                h1, h2, h3, h4, h5, h6 {
                    color: #0f172a;
                    margin-top: 1.5em;
                    margin-bottom: 0.5em;
                }
                p {
                    margin: 1em 0;
                }
                a {
                    color: #D9232A;
                    text-decoration: none;
                }
                img {
                    max-width: 100%;
                    height: auto;
                    border-radius: 8px;
                }
                ul, ol {
                    padding-left: 24px;
                }
                li {
                    margin: 0.5em 0;
                }
                blockquote {
                    border-left: 4px solid #D9232A;
                    margin: 1em 0;
                    padding-left: 16px;
                    color: #475569;
                }
            </style>
        </head>
        <body>
            $html
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

                        // For now, block external links (could open in browser in future)
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
