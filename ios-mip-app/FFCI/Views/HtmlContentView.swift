//
//  HtmlContentView.swift
//  FFCI
//
//  HTML content renderer using WKWebView
//

import SwiftUI
import WebKit
import Foundation
import os.log

private let logger = Logger(subsystem: "com.fiveq.ffci", category: "HtmlContent")

// Custom URL scheme handler for Basic Auth resource loading
class AuthURLSchemeHandler: NSObject, WKURLSchemeHandler {
    private let username = "fiveq"
    private let password = "demo"
    
    // Track stopped tasks to avoid calling methods on them after they're stopped
    private var stoppedTasks = Set<Int>()
    private let lock = NSLock()
    
    private func isTaskStopped(_ task: WKURLSchemeTask) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return stoppedTasks.contains(ObjectIdentifier(task as AnyObject).hashValue)
    }
    
    private func markTaskStopped(_ task: WKURLSchemeTask) {
        lock.lock()
        defer { lock.unlock() }
        stoppedTasks.insert(ObjectIdentifier(task as AnyObject).hashValue)
    }
    
    private func cleanupTask(_ task: WKURLSchemeTask) {
        lock.lock()
        defer { lock.unlock() }
        stoppedTasks.remove(ObjectIdentifier(task as AnyObject).hashValue)
    }
    
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let url = urlSchemeTask.request.url else {
            if !isTaskStopped(urlSchemeTask) {
                urlSchemeTask.didFailWithError(NSError(domain: "Invalid URL", code: -1))
            }
            return
        }
        
        // Extract the original HTTPS URL from the custom scheme
        // Custom scheme format: ffci-auth://ffci.fiveq.dev/path/to/resource
        let originalURLString = url.absoluteString.replacingOccurrences(of: "ffci-auth://", with: "https://")
        guard let originalURL = URL(string: originalURLString) else {
            if !isTaskStopped(urlSchemeTask) {
                urlSchemeTask.didFailWithError(NSError(domain: "Invalid URL conversion", code: -1))
            }
            return
        }
        
        // Create request with Basic Auth headers
        var request = URLRequest(url: originalURL)
        let credentials = "\(username):\(password)"
        if let credentialsData = credentials.data(using: .utf8) {
            let base64Credentials = credentialsData.base64EncodedString()
            request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        }
        
        // Perform the request
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            // Ensure we're on the main thread for WKURLSchemeTask methods
            DispatchQueue.main.async {
                // Check if task was stopped before we respond
                guard !self.isTaskStopped(urlSchemeTask) else {
                    return
                }
                
                if let error = error {
                    if !self.isTaskStopped(urlSchemeTask) {
                        urlSchemeTask.didFailWithError(error)
                    }
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      let data = data else {
                    if !self.isTaskStopped(urlSchemeTask) {
                        urlSchemeTask.didFailWithError(NSError(domain: "Invalid response", code: -1))
                    }
                    return
                }
                
                // Convert headers from [AnyHashable: Any] to [String: String]
                var headerFields: [String: String] = [:]
                for (key, value) in httpResponse.allHeaderFields {
                    if let keyString = key as? String, let valueString = value as? String {
                        headerFields[keyString] = valueString
                    }
                }
                
                // Create a new HTTPURLResponse with the original request URL (custom scheme)
                // WKWebView requires the response URL to match the request URL
                guard let responseURL = urlSchemeTask.request.url,
                      let newResponse = HTTPURLResponse(
                        url: responseURL,
                        statusCode: httpResponse.statusCode,
                        httpVersion: "HTTP/1.1",
                        headerFields: headerFields.isEmpty ? nil : headerFields
                      ) else {
                    if !self.isTaskStopped(urlSchemeTask) {
                        urlSchemeTask.didFailWithError(NSError(domain: "Failed to create response", code: -1))
                    }
                    return
                }
                
                // Final check before sending response
                guard !self.isTaskStopped(urlSchemeTask) else {
                    return
                }
                
                // Send response (must match request URL)
                urlSchemeTask.didReceive(newResponse)
                urlSchemeTask.didReceive(data)
                urlSchemeTask.didFinish()
                
                // Clean up tracking
                self.cleanupTask(urlSchemeTask)
            }
        }
        
        task.resume()
    }
    
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        // Mark task as stopped so we don't try to call methods on it
        markTaskStopped(urlSchemeTask)
    }
}

struct HtmlContentView: UIViewRepresentable {
    let html: String
    let onNavigate: ((String) -> Void)?
    @Binding var contentHeight: CGFloat
    
    init(html: String, onNavigate: ((String) -> Void)?, contentHeight: Binding<CGFloat> = .constant(200)) {
        self.html = html
        self.onNavigate = onNavigate
        self._contentHeight = contentHeight
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        
        // Register custom URL scheme handler for Basic Auth resource loading
        let authHandler = AuthURLSchemeHandler()
        configuration.setURLSchemeHandler(authHandler, forURLScheme: "ffci-auth")
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = .clear
        
        context.coordinator.webView = webView
        context.coordinator.contentHeightBinding = _contentHeight
        
        let styledHtml = wrapHtml(html)
        webView.loadHTMLString(styledHtml, baseURL: URL(string: "https://ffci.fiveq.dev"))
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let styledHtml = wrapHtml(html)
        webView.loadHTMLString(styledHtml, baseURL: URL(string: "https://ffci.fiveq.dev"))
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onNavigate: onNavigate)
    }
    
    private func wrapHtml(_ html: String) -> String {
        // Fix images with empty src but valid srcset
        var fixedHtml = html
        if let srcsetMatch = html.range(of: "srcset=\"(https?://[^\\s\"]+)", options: .regularExpression),
           let urlRange = html.range(of: "https?://[^\\s\"]+", options: .regularExpression, range: srcsetMatch) {
            let firstUrl = String(html[urlRange])
            fixedHtml = fixedHtml.replacingOccurrences(of: "src=\"\"", with: "src=\"\(firstUrl)\"")
        }
        
        // Replace ffci.fiveq.dev URLs with custom scheme for Basic Auth
        // This allows WKURLSchemeHandler to intercept and add auth headers
        // Handle both http:// and https:// URLs, and replace in src, srcset, and href attributes
        let urlPattern = "(https?://ffci\\.fiveq\\.dev)"
        if let regex = try? NSRegularExpression(pattern: urlPattern, options: .caseInsensitive) {
            let range = NSRange(fixedHtml.startIndex..<fixedHtml.endIndex, in: fixedHtml)
            fixedHtml = regex.stringByReplacingMatches(
                in: fixedHtml,
                options: [],
                range: range,
                withTemplate: "ffci-auth://ffci.fiveq.dev"
            )
        } else {
            // Fallback to simple string replacement if regex fails
            fixedHtml = fixedHtml.replacingOccurrences(
                of: "https://ffci.fiveq.dev",
                with: "ffci-auth://ffci.fiveq.dev",
                options: .caseInsensitive
            )
            fixedHtml = fixedHtml.replacingOccurrences(
                of: "http://ffci.fiveq.dev",
                with: "ffci-auth://ffci.fiveq.dev",
                options: .caseInsensitive
            )
        }
        
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; font-size: 17px; line-height: 28px; color: #334155; padding: 0 16px 32px 16px; margin: 0; overflow-x: hidden; background-color: transparent; }
                /* Critical: Ensure inline styles on any element are respected by WKWebView */
                [style*="background-color"] {
                    /* Force inline background-color styles to be applied */
                    background-attachment: scroll !important;
                    background-clip: border-box !important;
                    background-origin: padding-box !important;
                    background-repeat: repeat !important;
                }
                h1 { font-size: 34px; font-weight: 700; margin-top: 36px; margin-bottom: 20px; color: #0f172a; letter-spacing: -1px; line-height: 40px; }
                h2 { font-size: 28px; font-weight: 700; margin-top: 32px; margin-bottom: 16px; color: #0f172a; letter-spacing: -0.6px; line-height: 34px; }
                h3 { font-size: 23px; font-weight: 700; margin-top: 28px; margin-bottom: 12px; color: #024D91; line-height: 30px; padding-left: 12px; border-left: 3px solid #D9232A; }
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
                /* Blockquote text inside colored sections */
                ._section[style*="color"] ._blockquote,
                ._section[style*="color"] ._blockquote * {
                    color: inherit !important;
                }
                /* Remove red border from h3 in colored sections */
                ._section[style*="color"] h3 {
                    border-left: none;
                    padding-left: 0;
                }
                /* Accordion styling - force all items open and style as cards */
                /* Target details/summary structure */
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
                p { margin: 16px 0; }
                hr { display: none; }
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
                img { max-width: 100%; height: auto; border-radius: 8px; margin: 24px 0; }
                picture { display: block; width: 100%; }
                picture img { width: 100%; border-radius: 8px; margin: 24px 0; }
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
                /* Ensure sections with inline background-color styles display correctly */
                ._section[style*="background-color"] {
                    display: block !important;
                }
                ._background { position: relative; width: 100%; min-height: 200px; margin-bottom: 16px; border-radius: 8px; overflow: hidden; }
                ._background picture { position: absolute; top: 0; left: 0; width: 100%; height: 100%; z-index: 0; }
                ._background picture img { width: 100%; height: 100%; object-fit: cover; object-position: center; border-radius: 0; margin: 0; }
                ._background > *:not(picture) { position: relative; z-index: 1; }
                /* Button group - stack buttons vertically */
                ._button-group {
                    display: flex;
                    flex-direction: column;
                    gap: 12px;
                    margin: 16px 0;
                }
                /* Base button styles */
                a[class*="_button-priority"],
                a[class*="_button-secondary"],
                a[class*="_button"] {
                    display: block !important;
                    visibility: visible !important;
                    opacity: 1 !important;
                    width: 100%;
                    min-height: 56px;
                    padding: 18px 24px;
                    border-radius: 12px;
                    text-align: center;
                    font-size: 20px;
                    font-weight: 500;
                    letter-spacing: 0.5px;
                    text-decoration: none !important;
                    border-top: none !important;
                    border-left: none !important;
                    border-right: none !important;
                    border-bottom: none !important;
                    box-sizing: border-box;
                    margin: 8px 0 !important;
                    background: rgba(217, 35, 42, 0.08);
                    /* Reset all inherited styles that might cause red artifacts */
                    background-image: none !important;
                    background-position: initial !important;
                    background-repeat: initial !important;
                    background-attachment: initial !important;
                    background-size: initial !important;
                }
                /* Primary button - red background */
                a[class*="_button-priority"] {
                    background-color: #D9232A !important;
                    color: white !important;
                    border: none !important;
                }
                /* Secondary button - outline style */
                a[class*="_button-secondary"] {
                    background-color: transparent !important;
                    color: #D9232A !important;
                    border: 2px solid #D9232A;
                }
                /* Regular button */
                a[class*="_button"]:not([class*="_button-priority"]):not([class*="_button-secondary"]) {
                    background-color: #D9232A !important;
                    color: white !important;
                    border: none !important;
                }
                /* Button span should inherit */
                a[class*="_button-priority"] span,
                a[class*="_button-secondary"] span,
                a[class*="_button"] span {
                    color: inherit;
                }
                /* Section styling - support for background colors and text colors */
                /* Only apply padding/margins to sections with background colors */
                ._section[style*="background-color"] {
                    /* Use calc to make section full-width plus overflow body padding */
                    width: calc(100% + 32px) !important;
                    max-width: none !important;
                    margin-left: -16px !important;
                    margin-right: -16px !important;
                    margin-top: 16px !important;
                    margin-bottom: 16px !important;
                    /* Consistent padding on all sides */
                    padding: 24px 16px !important;
                    /* Force display block to ensure background is visible */
                    display: block !important;
                    /* Ensure inline styles are respected */
                    background-image: none !important;
                    min-height: 1px;
                    background-size: auto !important;
                    /* Ensure proper box model */
                    box-sizing: border-box !important;
                }
                /* Ensure inline styles are respected - use attribute selector to match any background-color value */
                div._section[style] {
                    /* Inline styles should already have background-color, but ensure they're applied */
                }
                /* Critical: Ensure sections with inline color styles apply color to all children */
                /* This ensures ALL descendants inherit the color from the section's inline style */
                ._section[style*="color"] * {
                    color: inherit !important;
                }
                /* Constrain embedded content (iframes, embeds) to prevent overflow */
                iframe, embed, object {
                    max-width: 100%;
                    width: 100%;
                    border: none;
                    box-sizing: border-box;
                }
                /* Catch-all to prevent any wide elements from overflowing */
                * {
                    max-width: 100%;
                    box-sizing: border-box;
                }
            </style>
        </head>
        <body>
            \(fixedHtml)
        </body>
        </html>
        """
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let onNavigate: ((String) -> Void)?
        weak var webView: WKWebView?
        var contentHeightBinding: Binding<CGFloat>?
        
        init(onNavigate: ((String) -> Void)?) {
            self.onNavigate = onNavigate
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Fix WKWebView not rendering background colors from inline styles
            // WKWebView with isOpaque=false can fail to apply inline background-color
            // Solution: Create a <style> block with explicit CSS rules for each section
            webView.evaluateJavaScript("""
                (function() {
                    const sections = document.querySelectorAll('._section');
                    if (sections.length === 0) return;
                    
                    // Build CSS rules for each section with background-color
                    let cssRules = '';
                    sections.forEach(function(section, index) {
                        const styleAttr = section.getAttribute('style') || '';
                        
                        // Parse background-color and color from inline style
                        let bgMatch = styleAttr.match(/background-color:\\s*([^;]+)/i);
                        let colorMatch = styleAttr.match(/(?:^|;)\\s*color:\\s*([^;]+)/i);
                        
                        // Also check for ._background child element with --bgColor CSS variable
                        // Some sections use a background block instead of inline style on the section
                        if (!bgMatch) {
                            const bgElement = section.querySelector('._background[style*="--bgColor"]');
                            if (bgElement) {
                                const bgStyle = bgElement.getAttribute('style') || '';
                                const bgColorVar = bgStyle.match(/--bgColor:\\s*([^;]+)/i);
                                if (bgColorVar && bgColorVar[1].trim() !== '') {
                                    bgMatch = bgColorVar;
                                }
                            }
                        }
                        
                        if (bgMatch || colorMatch) {
                            // Add a unique data attribute to target this specific section
                            section.setAttribute('data-section-id', 'section-' + index);
                            
                            let rule = '._section[data-section-id="section-' + index + '"] { ';
                            if (bgMatch) {
                                rule += 'background-color: ' + bgMatch[1].trim() + ' !important; ';
                            }
                            if (colorMatch) {
                                rule += 'color: ' + colorMatch[1].trim() + ' !important; ';
                            }
                            rule += '}\\n';
                            cssRules += rule;
                            
                            // Also add child text color inheritance
                            if (colorMatch) {
                                cssRules += '._section[data-section-id="section-' + index + '"] * { color: inherit !important; }\\n';
                            }
                        }
                    });
                    
                    // Fix text blocks and other elements with inline background-color or color
                    // Directly apply styles via JavaScript to ensure they work
                    const styledElements = document.querySelectorAll('[style]');
                    styledElements.forEach(function(el) {
                        if (el.classList.contains('_section')) return; // Already handled
                        
                        const styleAttr = el.getAttribute('style') || '';
                        const bgMatch = styleAttr.match(/background-color:\\s*([^;]+)/i);
                        const colorMatch = styleAttr.match(/(?:^|;)\\s*color:\\s*([^;]+)/i);
                        
                        // Directly apply via JavaScript style property
                        if (bgMatch) {
                            el.style.setProperty('background-color', bgMatch[1].trim(), 'important');
                        }
                        if (colorMatch) {
                            el.style.setProperty('color', colorMatch[1].trim(), 'important');
                        }
                    });
                    
                    // Fix blockquote elements inside colored sections
                    const blockquotes = document.querySelectorAll('._section ._blockquote');
                    blockquotes.forEach(function(bq) {
                        const section = bq.closest('._section');
                        if (section) {
                            const sectionStyle = section.getAttribute('style') || '';
                            const colorMatch = sectionStyle.match(/(?:^|;)\\s*color:\\s*([^;]+)/i);
                            if (colorMatch) {
                                const color = colorMatch[1].trim();
                                bq.style.setProperty('color', color, 'important');
                                // Also fix all children
                                bq.querySelectorAll('*').forEach(function(child) {
                                    child.style.setProperty('color', color, 'important');
                                });
                            }
                        }
                    });
                    
                    // Inject the CSS rules into a new style element
                    if (cssRules) {
                        const styleEl = document.createElement('style');
                        styleEl.textContent = cssRules;
                        document.head.appendChild(styleEl);
                    }
                })();
                
                // Force all accordion items to be open/expanded
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
                        const radioName = radio.name;
                        
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
            """) { _, _ in }
            
            // Calculate content height after page loads
            webView.evaluateJavaScript("document.body.scrollHeight") { [weak self] result, error in
                if let height = result as? CGFloat, height > 0 {
                    DispatchQueue.main.async {
                        self?.contentHeightBinding?.wrappedValue = height
                    }
                }
            }
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }
            
            let urlString = url.absoluteString
            let navigationType = navigationAction.navigationType
            
            // Allow navigation to baseURL (handles initial load from loadHTMLString)
            let baseURLString = "https://ffci.fiveq.dev"
            if urlString == baseURLString || 
               urlString == "\(baseURLString)/" ||
               (url.host == "ffci.fiveq.dev" && (url.path.isEmpty || url.path == "/")) {
                decisionHandler(.allow)
                return
            }
            
            // Only intercept user-clicked links (.linkActivated)
            if navigationType != .linkActivated {
                decisionHandler(.allow)
                return
            }
            
            logger.notice("Link clicked: \(urlString)")
            
            // Check for internal page links (/page/uuid format)
            if urlString.contains("/page/") {
                let components = urlString.components(separatedBy: "/page/")
                if components.count > 1 {
                    let uuidPart = components[1].components(separatedBy: "/").first ?? components[1].components(separatedBy: "?").first ?? components[1]
                    let uuid = uuidPart.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
                    
                    if uuid.count >= 8 && !uuid.allSatisfy({ $0.isNumber }) {
                        logger.notice("Navigating to page: \(uuid)")
                        onNavigate?(uuid)
                        decisionHandler(.cancel)
                        return
                    }
                }
            }
            
            // Form pages - open in external browser
            if urlString.contains("/prayer-request") || urlString.contains("/chaplain-request") || urlString.contains("/forms/") {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
                return
            }
            
            // External links - open in browser
            if let host = url.host, host != "ffci.fiveq.dev", !urlString.hasPrefix("/") {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
                return
            }
            
            // Internal non-UUID links - open in browser
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
        }
    }
}

#Preview {
    HtmlContentView(
        html: "<h1>Test HTML</h1><p>This is a test paragraph.</p>",
        onNavigate: { uuid in
            print("Navigate to: \(uuid)")
        }
    )
    .frame(height: 300)
}
