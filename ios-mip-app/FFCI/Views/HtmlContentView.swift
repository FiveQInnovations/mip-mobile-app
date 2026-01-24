//
//  HtmlContentView.swift
//  FFCI
//
//  HTML content renderer using WKWebView
//

import SwiftUI
import WebKit
import os.log

private let logger = Logger(subsystem: "com.fiveq.ffci", category: "HtmlContent")

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
        
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; font-size: 17px; line-height: 28px; color: #334155; padding: 0 16px; margin: 0; }
                h1 { font-size: 34px; font-weight: 700; margin-top: 36px; margin-bottom: 20px; color: #0f172a; letter-spacing: -1px; line-height: 40px; }
                h2 { font-size: 28px; font-weight: 700; margin-top: 32px; margin-bottom: 16px; color: #0f172a; letter-spacing: -0.6px; line-height: 34px; }
                h3 { font-size: 23px; font-weight: 700; margin-top: 28px; margin-bottom: 12px; color: #024D91; line-height: 30px; padding-left: 12px; border-left: 3px solid #D9232A; }
                p { margin: 16px 0; }
                a { color: #D9232A; text-decoration: none; font-weight: 600; background: rgba(217, 35, 42, 0.08); padding: 4px 6px; border-bottom: 2px solid #D9232A; border-radius: 4px; }
                img { max-width: 100%; height: auto; border-radius: 8px; margin: 24px 0; }
                picture { display: block; width: 100%; }
                picture img { width: 100%; border-radius: 8px; margin: 24px 0; }
                ._background { position: relative; width: 100%; min-height: 200px; margin-bottom: 16px; border-radius: 8px; overflow: hidden; }
                ._background picture { position: absolute; top: 0; left: 0; width: 100%; height: 100%; }
                ._background picture img { width: 100%; height: 100%; object-fit: cover; border-radius: 0; margin: 0; }
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
