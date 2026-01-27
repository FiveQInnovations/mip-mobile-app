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
                body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; font-size: 17px; line-height: 28px; color: #334155; padding: 0 16px 32px 16px; margin: 0; overflow-x: hidden; }
                h1 { font-size: 34px; font-weight: 700; margin-top: 36px; margin-bottom: 20px; color: #0f172a; letter-spacing: -1px; line-height: 40px; }
                h2 { font-size: 28px; font-weight: 700; margin-top: 32px; margin-bottom: 16px; color: #0f172a; letter-spacing: -0.6px; line-height: 34px; }
                h3 { font-size: 23px; font-weight: 700; margin-top: 28px; margin-bottom: 12px; color: #024D91; line-height: 30px; padding-left: 12px; border-left: 3px solid #D9232A; }
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
                ._section {
                    /* No default styling for sections without backgrounds */
                }
                /* Only apply padding/margins to sections with background colors */
                ._section[style*="background-color"] {
                    padding: 24px 16px;
                    margin-left: -16px;
                    margin-right: -16px;
                    margin-top: 16px;
                    margin-bottom: 16px;
                }
                /* Ensure text colors within sections are applied */
                ._section[style*="color"] {
                    /* Text color is applied via inline style */
                }
                /* Ensure headings inherit section text color */
                ._section[style*="color"] h1,
                ._section[style*="color"] h2,
                ._section[style*="color"] h3,
                ._section[style*="color"] h4,
                ._section[style*="color"] h5,
                ._section[style*="color"] h6 {
                    color: inherit;
                }
                /* Ensure paragraphs and other text elements inherit section text color */
                ._section[style*="color"] p,
                ._section[style*="color"] li,
                ._section[style*="color"] span,
                ._section[style*="color"] div {
                    color: inherit;
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
