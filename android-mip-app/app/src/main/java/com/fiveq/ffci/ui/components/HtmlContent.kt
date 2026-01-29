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
import com.fiveq.ffci.config.AppConfig

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

    // Get primary color from config for CSS
    val config = AppConfig.get()
    val primaryColor = config.primaryColor

    // Wrap HTML with basic styling
    val styledHtml = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                :root {
                    --primary-color: $primaryColor;
                }
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
                    border-left: 3px solid var(--primary-color);
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
                /* Accordion styling - force all items open and style as cards */
                details {
                    display: block !important;
                    background: rgba(255, 255, 255, 0.1);
                    border: 1px solid rgba(255, 255, 255, 0.2);
                    border-radius: 12px;
                    padding: 20px;
                    margin-bottom: 16px;
                    margin-top: 16px;
                }
                /* Force all accordion items to be open */
                details[open] {
                    display: block !important;
                }
                /* Also target accordion class-based structures */
                .accordion,
                .accordion-item,
                [class*="accordion"] {
                    background: rgba(255, 255, 255, 0.1);
                    border: 1px solid rgba(255, 255, 255, 0.2);
                    border-radius: 12px;
                    padding: 20px;
                    margin-bottom: 16px;
                    margin-top: 16px;
                }
                /* Accordion title styling */
                summary,
                .accordion-title,
                [class*="accordion-title"],
                [class*="accordion-header"] {
                    display: block !important;
                    font-size: 20px;
                    font-weight: 700;
                    color: inherit;
                    margin-bottom: 12px;
                    cursor: default;
                    list-style: none;
                    padding: 0;
                }
                /* Hide default disclosure triangle */
                summary::-webkit-details-marker {
                    display: none !important;
                }
                summary::marker {
                    display: none !important;
                }
                /* Hide radio buttons in accordions - they're not needed since items are always open */
                details input[type="radio"],
                .accordion input[type="radio"],
                [class*="accordion"] input[type="radio"] {
                    display: none !important;
                }
                /* Accordion content styling */
                details > *:not(summary),
                .accordion-content,
                [class*="accordion-content"] {
                    display: block !important;
                    color: inherit;
                    font-size: 17px;
                    line-height: 28px;
                    margin-top: 0;
                }
                /* Ensure lists inside accordion have proper spacing */
                details ul,
                details ol,
                .accordion ul,
                .accordion ol,
                [class*="accordion"] ul,
                [class*="accordion"] ol {
                    margin: 12px 0;
                    padding-left: 24px;
                }
                details li,
                .accordion li,
                [class*="accordion"] li {
                    margin: 8px 0;
                }
                /* Accordion items inherit text color from parent section */
                ._section[style*="color"] details,
                ._section[style*="color"] summary,
                ._section[style*="color"] details > *,
                ._section[style*="color"] .accordion,
                ._section[style*="color"] .accordion-item,
                ._section[style*="color"] [class*="accordion"] {
                    color: inherit !important;
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
                    color: var(--primary-color);
                    text-decoration: none;
                    font-weight: 600;
                    background: rgba(217, 35, 42, 0.08);
                    padding: 4px 6px;
                    border-bottom: 2px solid var(--primary-color);
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
                    border-left: 4px solid var(--primary-color);
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
                /* Primary button - uses config primary color */
                a[class*="_button-priority"] {
                    background-color: var(--primary-color) !important;
                    background: var(--primary-color) !important;
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
                    color: var(--primary-color) !important;
                    border: 2px solid var(--primary-color);
                }
                /* Regular button (non-priority) */
                a[class*="_button"]:not([class*="_button-priority"]):not([class*="_button-secondary"]) {
                    background-color: var(--primary-color) !important;
                    background: var(--primary-color) !important;
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
                    javaScriptEnabled = true
                    loadWithOverviewMode = true
                    useWideViewPort = true
                    // Disable cache to prevent stale content
                    cacheMode = android.webkit.WebSettings.LOAD_NO_CACHE
                }

                webViewClient = object : WebViewClient() {
                    private val config = AppConfig.get()
                    private val credentials = Base64.encodeToString(
                        "${config.username}:${config.password}".toByteArray(),
                        Base64.NO_WRAP
                    )
                    private val baseHost = Uri.parse(config.apiBaseUrl).host ?: ""

                    override fun shouldInterceptRequest(
                        view: WebView?,
                        request: WebResourceRequest?
                    ): WebResourceResponse? {
                        val url = request?.url?.toString() ?: return null

                        // Add auth headers for site resources
                        if (url.contains(baseHost)) {
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

                    override fun onPageFinished(view: WebView?, url: String?) {
                        super.onPageFinished(view, url)
                        // Fix section background and text colors (inline styles need JS injection)
                        view?.evaluateJavascript("""
                            (function() {
                                const sections = document.querySelectorAll('._section');
                                if (sections.length === 0) return;
                                
                                let cssRules = '';
                                sections.forEach(function(section, index) {
                                    const styleAttr = section.getAttribute('style') || '';
                                    
                                    let bgMatch = styleAttr.match(/background-color:\s*([^;]+)/i);
                                    let colorMatch = styleAttr.match(/(?:^|;)\s*color:\s*([^;]+)/i);
                                    
                                    if (!bgMatch) {
                                        const bgElement = section.querySelector('._background[style*="--bgColor"]');
                                        if (bgElement) {
                                            const bgStyle = bgElement.getAttribute('style') || '';
                                            const bgColorVar = bgStyle.match(/--bgColor:\s*([^;]+)/i);
                                            if (bgColorVar && bgColorVar[1].trim() !== '') {
                                                bgMatch = bgColorVar;
                                            }
                                        }
                                    }
                                    
                                    if (bgMatch || colorMatch) {
                                        section.setAttribute('data-section-id', 'section-' + index);
                                        
                                        let rule = '._section[data-section-id="section-' + index + '"] { ';
                                        if (bgMatch) {
                                            rule += 'background-color: ' + bgMatch[1].trim() + ' !important; ';
                                        }
                                        if (colorMatch) {
                                            rule += 'color: ' + colorMatch[1].trim() + ' !important; ';
                                        }
                                        rule += '}\n';
                                        cssRules += rule;
                                        
                                        if (colorMatch) {
                                            cssRules += '._section[data-section-id="section-' + index + '"] * { color: inherit !important; }\n';
                                        }
                                    }
                                });
                                
                                if (cssRules) {
                                    const styleEl = document.createElement('style');
                                    styleEl.textContent = cssRules;
                                    document.head.appendChild(styleEl);
                                }
                            })();
                        """, null)
                        
                        // Force all accordion items to be open/expanded
                        view?.evaluateJavascript("""
                            (function() {
                                // Force all <details> elements open
                                const detailsElements = document.querySelectorAll('details');
                                detailsElements.forEach(function(details) {
                                    details.setAttribute('open', 'open');
                                    details.open = true;
                                });
                                
                                // Show all accordion content that might be hidden
                                // Handle radio button-based accordions
                                const radioInputs = document.querySelectorAll('input[type="radio"][name*="accordion"], input[type="radio"][id*="accordion"]');
                                radioInputs.forEach(function(radio) {
                                    // Find associated content and show it
                                    const radioId = radio.id;
                                    
                                    // Try to find content associated with this radio button
                                    if (radioId) {
                                        const content = document.querySelector('[for="' + radioId + '"] + *');
                                        if (content) {
                                            content.style.display = 'block';
                                        }
                                    }
                                    
                                    // Find content panels that might be controlled by radio buttons
                                    const panels = document.querySelectorAll('[class*="accordion-content"], [class*="panel"], [id*="panel"]');
                                    panels.forEach(function(panel) {
                                        panel.style.display = 'block';
                                        panel.classList.remove('hidden', 'collapse', 'collapsed');
                                    });
                                });
                                
                                // Show any hidden accordion content
                                const hiddenContent = document.querySelectorAll('[class*="accordion"] [style*="display: none"], [class*="accordion"] .hidden, [class*="accordion"] .collapse');
                                hiddenContent.forEach(function(element) {
                                    element.style.display = 'block';
                                    element.classList.remove('hidden', 'collapse', 'collapsed');
                                });
                            })();
                        """, null)
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
                                        "${config.apiBaseUrl}$url"
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
                                "${config.apiBaseUrl}$url"
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
                    AppConfig.get().apiBaseUrl,
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
                AppConfig.get().apiBaseUrl,
                styledHtml,
                "text/html",
                "UTF-8",
                null
            )
        }
    )
}
