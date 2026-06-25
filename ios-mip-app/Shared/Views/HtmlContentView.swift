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

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.fiveq.mip", category: "HtmlContent")

// Custom URL scheme handler for Basic Auth resource loading
class AuthURLSchemeHandler: NSObject, WKURLSchemeHandler {
    private let config = SiteConfig.shared
    
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
        
        let originalURLString = url.absoluteString.replacingOccurrences(
            of: "\(config.authScheme)://",
            with: "https://"
        )
        guard let originalURL = URL(string: originalURLString) else {
            if !isTaskStopped(urlSchemeTask) {
                urlSchemeTask.didFailWithError(NSError(domain: "Invalid URL conversion", code: -1))
            }
            return
        }
        
        var request = URLRequest(url: originalURL)
        let credentials = "\(config.basicAuthUsername):\(config.basicAuthPassword)"
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
    /// Page context for `external_link` when opening links from HTML (ticket 031).
    let analyticsPageUuid: String
    let analyticsPageTitle: String

    // Run hero normalization before didFinish to avoid visible contrast flicker.
    private static let heroContrastPreloadScript = """
    (function() {
        function removeBlurEffects(element) {
            if (!element) return;
            element.style.setProperty('filter', 'none', 'important');
            element.style.setProperty('-webkit-filter', 'none', 'important');
            element.style.setProperty('backdrop-filter', 'none', 'important');
        }

        function markHeroSection(anchorElement) {
            if (!anchorElement) return null;
            const section = anchorElement.closest('._section');
            if (!section) return null;
            section.classList.add('_hero-section');
            return section;
        }

        function normalizeHeroImageRendering(section) {
            if (!section) return;
            const blurTargets = section.querySelectorAll(
                '._background, ._background picture, ._background img, ._hero-background, ._hero-background picture, ._hero-background img'
            );
            blurTargets.forEach(function(target) {
                removeBlurEffects(target);
                target.style.setProperty('opacity', '1', 'important');
                target.style.setProperty('mix-blend-mode', 'normal', 'important');
                target.style.setProperty('background-blend-mode', 'normal', 'important');
            });
        }

        function collapseDecorativeBackgrounds() {
            document.querySelectorAll('._background').forEach(function(bg) {
                const hasMedia = bg.querySelector('picture, img, video, iframe, embed, object, source');
                if (!hasMedia && bg.textContent.trim() === '') {
                    bg.classList.add('_background-empty');
                }
            });
        }

        function markPairedCtaSections() {
            document.querySelectorAll('._section').forEach(function(section) {
                const headings = section.querySelectorAll(':scope > ._heading');
                const buttonGroups = section.querySelectorAll(':scope > ._button-group');
                const emptyBackgrounds = section.querySelectorAll(':scope > ._background-empty');
                if (headings.length === 2 && buttonGroups.length === 2 && emptyBackgrounds.length >= 1) {
                    section.classList.add('_paired-cta-section');
                    headings[0].classList.add('_paired-cta-card-start');
                    headings[1].classList.add('_paired-cta-card-start');
                    buttonGroups[0].classList.add('_paired-cta-card-end');
                    buttonGroups[1].classList.add('_paired-cta-card-end');
                }
            });
        }

        function markImageCardSections() {
            function styleValue(element, property) {
                if (!element) return '';
                const target = property.toLowerCase();
                const styleAttr = element.getAttribute('style') || '';
                const parts = styleAttr.split(';');
                for (let i = 0; i < parts.length; i++) {
                    const colon = parts[i].indexOf(':');
                    if (colon === -1) continue;
                    const name = parts[i].slice(0, colon).trim().toLowerCase();
                    if (name === target) {
                        return parts[i].slice(colon + 1).trim();
                    }
                }
                return '';
            }

            function imageCardBackgroundFor(section) {
                return styleValue(section, 'background-color')
                    || styleValue(section.querySelector(':scope > ._background-empty'), '--bgColor')
                    || styleValue(section.querySelector(':scope > ._background'), '--bgColor')
                    || '#D9232A';
            }

            function imageCardHeadingColorFor(section, heading) {
                return styleValue(section, 'color')
                    || styleValue(heading, '--theme-content')
                    || styleValue(section, '--theme-content')
                    || '#ffffff';
            }

            function isImageOnlySection(section) {
                const imageLinks = section.querySelectorAll(':scope > a._image-link');
                if (imageLinks.length === 0) return false;
                return !section.querySelector(':scope > ._heading, :scope > ._text, :scope > ._button-group, :scope > ._background');
            }

            document.querySelectorAll('._section').forEach(function(section) {
                const heading = section.querySelector(':scope > ._heading');
                const decorativeBackgrounds = section.querySelectorAll(':scope > ._background-empty');
                const hasBodyContent = section.querySelector(':scope > ._text, :scope > ._button-group, :scope > a._image-link, :scope > figure._image');
                if (!heading || decorativeBackgrounds.length === 0 || hasBodyContent) return;

                let sibling = section.nextElementSibling;
                let imageSections = [];
                while (sibling && sibling.classList && sibling.classList.contains('_section') && isImageOnlySection(sibling)) {
                    imageSections.push(sibling);
                    sibling = sibling.nextElementSibling;
                }
                if (imageSections.length === 0) return;

                const imageCardBackground = imageCardBackgroundFor(section);
                const imageCardHeadingColor = imageCardHeadingColorFor(section, heading);

                section.classList.add('_image-card-heading-section');
                section.style.setProperty('--image-card-bg', imageCardBackground);
                section.style.setProperty('--image-card-heading-color', imageCardHeadingColor);
                section.style.setProperty('background-color', imageCardBackground, 'important');
                section.querySelectorAll(':scope > ._heading, :scope > ._heading *').forEach(function(el) {
                    el.style.setProperty('color', imageCardHeadingColor, 'important');
                    el.style.setProperty('text-shadow', 'none', 'important');
                });
                imageSections.forEach(function(imageSection) {
                    imageSection.classList.add('_image-card-grid-section');
                    imageSection.style.setProperty('--image-card-bg', imageCardBackground);
                    imageSection.style.setProperty('background-color', imageCardBackground, 'important');
                });
            });
        }

        function forceHeroContrast(element, className) {
            if (!element) return;
            element.classList.add(className);
            element.style.setProperty('color', '#ffffff', 'important');
            element.style.setProperty('text-shadow', '0 2px 8px rgba(0,0,0,0.84)', 'important');
            element.querySelectorAll('*').forEach(function(el) {
                el.style.setProperty('color', '#ffffff', 'important');
                el.style.setProperty('text-shadow', '0 2px 8px rgba(0,0,0,0.84)', 'important');
            });
        }

        function forceHeroHeadingContrast(headingEl) {
            forceHeroContrast(headingEl, '_hero-heading');
        }

        function forceHeroIntroContrast(textEl) {
            forceHeroContrast(textEl, '_hero-intro');
        }

        function normalizeHeroContrast() {
            collapseDecorativeBackgrounds();
            markPairedCtaSections();
            markImageCardSections();

            const heroContentBeforeBackground = document.querySelectorAll('._section ._heading + ._text + ._button-group + ._background, ._section ._heading + ._button-group + ._background');
            heroContentBeforeBackground.forEach(function(bg) {
                if (bg.classList.contains('_background-empty')) return;
                bg.classList.add('_hero-background');
                const section = markHeroSection(bg);
                section.classList.add('_hero-overlay-section');
                const heading = section.querySelector(':scope > ._heading');
                const introText = section.querySelector(':scope > ._text');
                if (heading) {
                    forceHeroHeadingContrast(heading);
                }
                if (introText) {
                    forceHeroIntroContrast(introText);
                }
                normalizeHeroImageRendering(section);
            });

            const heroBackgroundFirst = document.querySelectorAll('._section ._background + ._heading');
            heroBackgroundFirst.forEach(function(heading) {
                const bg = heading.previousElementSibling;
                if (bg && bg.classList.contains('_background-empty')) return;
                if (bg && bg.classList.contains('_background') && bg.parentNode) {
                    bg.parentNode.insertBefore(heading, bg);
                }
                forceHeroHeadingContrast(heading);
                if (bg && bg.classList.contains('_background')) {
                    bg.classList.add('_hero-background');
                }
                const heroSection = markHeroSection(heading);
                normalizeHeroImageRendering(heroSection);
            });

            const heroHeadingFirst = document.querySelectorAll('._section ._heading + ._background');
            heroHeadingFirst.forEach(function(bg) {
                if (bg.classList.contains('_background-empty')) return;
                bg.classList.add('_hero-background');
                const heading = bg.previousElementSibling;
                if (heading && heading.classList.contains('_heading')) {
                    forceHeroHeadingContrast(heading);
                }
                const heroSection = markHeroSection(bg);
                normalizeHeroImageRendering(heroSection);
            });

            const heroHeadingTextBackground = document.querySelectorAll('._section ._heading + ._text + ._background');
            heroHeadingTextBackground.forEach(function(bg) {
                if (bg.classList.contains('_background-empty')) return;
                bg.classList.add('_hero-background');
                const introText = bg.previousElementSibling;
                const heading = introText ? introText.previousElementSibling : null;
                if (heading && heading.classList.contains('_heading')) {
                    forceHeroHeadingContrast(heading);
                }
                if (introText && introText.classList.contains('_text')) {
                    forceHeroIntroContrast(introText);
                }
                const heroSection = markHeroSection(bg);
                normalizeHeroImageRendering(heroSection);
            });
        }

        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', normalizeHeroContrast, { once: true });
        } else {
            normalizeHeroContrast();
        }
        window.addEventListener('load', normalizeHeroContrast, { once: true });
        setTimeout(normalizeHeroContrast, 350);
    })();
    """
    
    init(
        html: String,
        onNavigate: ((String) -> Void)?,
        contentHeight: Binding<CGFloat> = .constant(200),
        analyticsPageUuid: String = "",
        analyticsPageTitle: String = ""
    ) {
        self.html = html
        self.onNavigate = onNavigate
        self._contentHeight = contentHeight
        self.analyticsPageUuid = analyticsPageUuid
        self.analyticsPageTitle = analyticsPageTitle
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.userContentController.addUserScript(
            WKUserScript(
                source: Self.heroContrastPreloadScript,
                injectionTime: .atDocumentStart,
                forMainFrameOnly: true
            )
        )
        
        let authHandler = AuthURLSchemeHandler()
        configuration.setURLSchemeHandler(authHandler, forURLScheme: SiteConfig.shared.authScheme)
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.accessibilityIdentifier = "html-content-view"
        
        context.coordinator.webView = webView
        context.coordinator.contentHeightBinding = _contentHeight
        
        let styledHtml = wrapHtml(html)
        context.coordinator.loadedHtml = styledHtml
        webView.loadHTMLString(styledHtml, baseURL: SiteConfig.shared.siteBaseURL)
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        context.coordinator.analyticsPageUuid = analyticsPageUuid
        context.coordinator.analyticsPageTitle = analyticsPageTitle
        let styledHtml = wrapHtml(html)
        guard context.coordinator.loadedHtml != styledHtml else { return }
        context.coordinator.loadedHtml = styledHtml
        webView.loadHTMLString(styledHtml, baseURL: SiteConfig.shared.siteBaseURL)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            onNavigate: onNavigate,
            analyticsPageUuid: analyticsPageUuid,
            analyticsPageTitle: analyticsPageTitle
        )
    }
    
    private func wrapHtml(_ html: String) -> String {
        // Fix images with empty src but valid srcset
        var fixedHtml = html
        
        // Issue 5: Patch each image tag individually (Android parity)
        let imgPattern = "<img[^>]+>"
        if let imgRegex = try? NSRegularExpression(pattern: imgPattern, options: .caseInsensitive) {
            let nsString = fixedHtml as NSString
            let matches = imgRegex.matches(in: fixedHtml, options: [], range: NSRange(location: 0, length: nsString.length))
            
            for match in matches.reversed() {
                let imgTag = nsString.substring(with: match.range)
                guard imgTag.contains("src=\"\""), imgTag.contains("srcset=\"") else { continue }

                if let srcsetRange = imgTag.range(of: "srcset=\"(https?://[^\\s\"]+)", options: .regularExpression) {
                    let srcsetMatch = String(imgTag[srcsetRange])
                    if let urlRange = srcsetMatch.range(of: "https?://[^\\s\"]+", options: .regularExpression) {
                        let firstUrl = String(srcsetMatch[urlRange])
                        let patchedTag = imgTag.replacingOccurrences(of: "src=\"\"", with: "src=\"\(firstUrl)\"")
                        fixedHtml = (fixedHtml as NSString).replacingCharacters(in: match.range, with: patchedTag)
                    }
                }
            }
        }
        
        // Replace first-party site URLs with custom scheme for Basic Auth
        let config = SiteConfig.shared
        for host in config.firstPartyHosts {
            let escapedHost = NSRegularExpression.escapedPattern(for: host)
            let urlPattern = "(https?)://((?:www\\.)?\(escapedHost))"
            if let regex = try? NSRegularExpression(pattern: urlPattern, options: .caseInsensitive) {
                let range = NSRange(fixedHtml.startIndex..<fixedHtml.endIndex, in: fixedHtml)
                fixedHtml = regex.stringByReplacingMatches(
                    in: fixedHtml,
                    options: [],
                    range: range,
                    withTemplate: "\(config.authScheme)://$2"
                )
            }
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
                ._background-empty {
                    display: none !important;
                    min-height: 0 !important;
                    height: 0 !important;
                    margin: 0 !important;
                    padding: 0 !important;
                }
                ._background picture { position: absolute; top: 0; left: 0; width: 100%; height: 100%; z-index: 0; }
                ._background picture img { width: 100%; height: 100%; object-fit: cover; object-position: center; border-radius: 0; margin: 0; }
                ._background > *:not(picture) { position: relative; z-index: 2; }
                ._paired-cta-section,
                ._paired-cta-section[style*="background-color"] {
                    background-color: #f1f1f1 !important;
                    padding: 32px 16px !important;
                    margin-top: 32px !important;
                    margin-bottom: 32px !important;
                    display: block !important;
                }
                ._paired-cta-section ._paired-cta-card-start,
                ._paired-cta-section ._paired-cta-card-end {
                    background-color: #ffffff !important;
                    border-left: 1px solid #d9d9d9;
                    border-right: 1px solid #d9d9d9;
                    margin: 0 !important;
                    padding-left: 24px;
                    padding-right: 24px;
                }
                ._paired-cta-section ._paired-cta-card-start {
                    border-top: 1px solid #d9d9d9;
                    border-radius: 8px 8px 0 0;
                    padding-top: 56px;
                    padding-bottom: 12px;
                }
                ._paired-cta-section ._paired-cta-card-end {
                    border-bottom: 1px solid #d9d9d9;
                    border-radius: 0 0 8px 8px;
                    padding-top: 16px;
                    padding-bottom: 56px;
                    align-items: center;
                    margin-bottom: 20px !important;
                }
                ._paired-cta-section h1,
                ._paired-cta-section h2,
                ._paired-cta-section h3,
                ._paired-cta-section h4,
                ._paired-cta-section p {
                    color: #262626 !important;
                    text-shadow: none !important;
                }
                ._paired-cta-section ._paired-cta-card-end a[class*="_button"] {
                    width: auto !important;
                    min-width: 180px;
                    max-width: 100%;
                    padding: 14px 24px;
                    min-height: 48px;
                    margin-left: auto !important;
                    margin-right: auto !important;
                }
                ._paired-cta-section ._paired-cta-card-end a[class*="_button"],
                ._paired-cta-section ._paired-cta-card-end a[class*="_button"] span {
                    color: #ffffff !important;
                    text-shadow: none !important;
                }
                ._image-card-heading-section,
                ._image-card-heading-section[style*="background-color"],
                ._image-card-grid-section {
                    background-color: var(--image-card-bg, #D9232A) !important;
                    background-image: none !important;
                    width: calc(100% + 32px) !important;
                    max-width: none !important;
                    margin-left: -16px !important;
                    margin-right: -16px !important;
                    box-sizing: border-box !important;
                }
                ._image-card-heading-section {
                    padding: 48px 16px 20px !important;
                    margin-top: 32px !important;
                    margin-bottom: 0 !important;
                }
                ._image-card-heading-section h1,
                ._image-card-heading-section h2,
                ._image-card-heading-section h3,
                ._image-card-heading-section h4,
                ._image-card-heading-section * {
                    color: var(--image-card-heading-color, #ffffff) !important;
                    text-shadow: none !important;
                }
                ._image-card-grid-section {
                    display: grid !important;
                    grid-template-columns: 1fr;
                    gap: 12px;
                    padding: 0 24px 24px !important;
                    margin-top: 0 !important;
                    margin-bottom: 0 !important;
                }
                ._image-card-grid-section + ._image-card-grid-section {
                    padding-top: 12px !important;
                }
                ._image-card-grid-section:last-of-type {
                    padding-bottom: 48px !important;
                    margin-bottom: 32px !important;
                }
                ._image-card-grid-section > a._image-link {
                    display: flex !important;
                    min-height: 220px;
                    align-items: center;
                    justify-content: center;
                    background-color: #ffffff !important;
                    border: 1px solid #d9d9d9 !important;
                    border-radius: 8px !important;
                    padding: 28px 20px !important;
                    margin: 0 !important;
                    box-shadow: none !important;
                }
                ._image-card-grid-section figure,
                ._image-card-grid-section picture {
                    margin: 0 !important;
                    width: 100%;
                }
                ._image-card-grid-section img {
                    display: block;
                    max-width: 220px !important;
                    max-height: 150px;
                    width: auto !important;
                    height: auto !important;
                    object-fit: contain;
                    margin: 0 auto !important;
                    border-radius: 0 !important;
                }
                ._image-card-grid-section figcaption {
                    color: #64748b !important;
                    text-align: center;
                    margin-top: 12px;
                    font-size: 16px;
                    line-height: 22px;
                }
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
                /* Priority buttons match the website's blue action style */
                a[class*="_button-priority"] {
                    background-color: #024D91 !important;
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
                /* PDF download list styling parity with Android WebView fix */
                ._downloads {
                    margin: 16px 0;
                }
                ._download-item {
                    margin: 8px 0;
                }
                ._download-item a {
                    display: flex !important;
                    flex-direction: row;
                    align-items: center;
                    gap: 10px;
                    padding: 12px 14px !important;
                    background-color: #f8fafc !important;
                    border: 1px solid #e2e8f0 !important;
                    border-bottom: 1px solid #e2e8f0 !important;
                    border-radius: 8px;
                    text-decoration: none !important;
                    color: inherit !important;
                }
                ._download-icon {
                    flex-shrink: 0;
                    width: 24px;
                    height: 24px;
                    color: #64748b;
                    display: flex;
                    align-items: center;
                }
                ._download-icon svg {
                    width: 24px;
                    height: 24px;
                    fill: #64748b;
                }
                ._download-title {
                    flex: 1;
                    font-size: 16px;
                    font-weight: 600;
                    color: #0f172a !important;
                    line-height: 1.4;
                }
                ._download-type {
                    display: none;
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
                ._image-card-heading-section,
                ._image-card-heading-section[style*="background-color"],
                ._image-card-grid-section,
                ._image-card-grid-section[style*="background-color"] {
                    background-color: var(--image-card-bg, #D9232A) !important;
                    background-image: none !important;
                    width: calc(100% + 32px) !important;
                    max-width: none !important;
                    margin-left: -16px !important;
                    margin-right: -16px !important;
                    box-sizing: border-box !important;
                }
                ._image-card-heading-section,
                ._image-card-heading-section[style*="background-color"] {
                    padding: 48px 16px 20px !important;
                    margin-top: 32px !important;
                    margin-bottom: 0 !important;
                }
                ._image-card-heading-section ._heading,
                ._image-card-heading-section ._heading *,
                ._image-card-heading-section h1,
                ._image-card-heading-section h2,
                ._image-card-heading-section h3,
                ._image-card-heading-section h4 {
                    color: var(--image-card-heading-color, #ffffff) !important;
                    text-shadow: none !important;
                }
                ._image-card-heading-section + ._image-card-grid-section,
                ._image-card-heading-section + ._image-card-grid-section[style*="background-color"] {
                    margin-top: 0 !important;
                    margin-bottom: 0 !important;
                    padding-top: 0 !important;
                }
                ._image-card-grid-section + ._image-card-grid-section,
                ._image-card-grid-section[style*="background-color"] + ._image-card-grid-section[style*="background-color"] {
                    padding-top: 12px !important;
                }
                ._image-card-grid-section,
                ._image-card-grid-section[style*="background-color"] {
                    display: grid !important;
                    grid-template-columns: 1fr;
                    gap: 12px;
                }
                /* Issue 4: Tailwind Utility Classes */
                .mb-2 { margin-bottom: 8px !important; }
                .mb-4 { margin-bottom: 16px !important; }
                .mb-8 { margin-bottom: 32px !important; }
                .mb-12 { margin-bottom: 48px !important; }
                .mt-8 { margin-top: 32px !important; }
                .py-24 { padding-top: 96px !important; padding-bottom: 96px !important; }
                .text-center { text-align: center; }
                .text-left { text-align: left; }

                /* Issue 1: Hero Title Contrast */
                ._background::before {
                    content: "";
                    position: absolute;
                    inset: 0;
                    background: linear-gradient(180deg, rgba(15,23,42,0.28) 0%, rgba(15,23,42,0.42) 100%);
                    z-index: 1;
                    pointer-events: none;
                }
                ._background h1, ._background h2, ._background h3,
                ._background h4, ._background h5, ._background h6,
                ._background p, ._background ._heading, ._background ._text {
                    color: #ffffff !important;
                    text-shadow: 0 2px 6px rgba(15,23,42,0.6);
                }
                ._section ._background + ._heading h1,
                ._section ._background + ._heading h2,
                ._section ._background + ._heading h3,
                ._section ._background + ._heading h4 {
                    color: #ffffff !important;
                    text-shadow: 0 2px 6px rgba(15,23,42,0.7);
                }
                ._section ._background + ._heading {
                    margin-top: 0; margin-bottom: 10px;
                    padding: 14px 14px 12px;
                    background: rgba(15,23,42,0.72);
                    border-radius: 8px; position: relative; z-index: 3;
                }
                ._hero-heading {
                    margin-top: 0; margin-bottom: 10px;
                    padding: 14px 14px 12px;
                    background: rgba(15,23,42,0.72);
                    border-radius: 8px; position: relative; z-index: 3;
                }
                ._hero-heading h1, ._hero-heading h2, ._hero-heading h3, ._hero-heading h4 {
                    color: #ffffff !important;
                    text-shadow: 0 2px 8px rgba(0,0,0,0.84);
                }
                ._hero-heading * {
                    color: #ffffff !important;
                    text-shadow: 0 2px 8px rgba(0,0,0,0.84);
                }
                ._hero-intro {
                    margin-top: 0; margin-bottom: 12px;
                    padding: 12px 14px;
                    background: rgba(15,23,42,0.68);
                    border-radius: 8px; position: relative; z-index: 3;
                }
                ._hero-intro * {
                    color: #ffffff !important;
                    text-shadow: 0 2px 8px rgba(0,0,0,0.84);
                }
                ._hero-background {
                    margin-top: 0;
                }
                /* Generic hero section overrides: apply to all pages consistently */
                ._hero-section,
                ._hero-section[style*="background-color"] {
                    background-color: transparent !important;
                    background-image: none !important;
                    width: 100% !important;
                    max-width: 100% !important;
                    margin-left: 0 !important;
                    margin-right: 0 !important;
                    padding-left: 0 !important;
                    padding-right: 0 !important;
                }
                ._hero-section ._background::before,
                ._hero-section ._hero-background::before {
                    content: none !important;
                    display: none !important;
                    background: none !important;
                    opacity: 0 !important;
                }
                ._hero-section ._background + ._heading,
                ._hero-section ._hero-heading {
                    background: rgba(2,77,145,0.90) !important;
                    border-left: 4px solid #D9232A;
                    padding-left: 12px;
                }
                ._hero-section ._background,
                ._hero-section ._background picture,
                ._hero-section ._background img,
                ._hero-section ._hero-background,
                ._hero-section ._hero-background picture,
                ._hero-section ._hero-background img {
                    background-color: #ffffff !important;
                    opacity: 1 !important;
                    filter: none !important;
                    -webkit-filter: none !important;
                    backdrop-filter: none !important;
                    -webkit-backdrop-filter: none !important;
                    mix-blend-mode: normal !important;
                    background-blend-mode: normal !important;
                }
                ._hero-overlay-section,
                ._hero-overlay-section[style*="background-color"] {
                    min-height: 520px;
                    display: flex !important;
                    flex-direction: column;
                    justify-content: center;
                    overflow: hidden;
                    padding: 76px 16px 64px !important;
                    margin-left: -16px !important;
                    margin-right: -16px !important;
                    width: calc(100% + 32px) !important;
                    max-width: none !important;
                    background-color: #0f172a !important;
                }
                ._hero-overlay-section > :not(._hero-background):not(._background) {
                    position: relative;
                    z-index: 2;
                }
                ._hero-overlay-section ._background,
                ._hero-overlay-section ._hero-background {
                    position: absolute !important;
                    inset: 0;
                    width: 100% !important;
                    height: 100% !important;
                    min-height: 0 !important;
                    margin: 0 !important;
                    border-radius: 0 !important;
                    z-index: 0;
                    background-color: #0f172a !important;
                }
                ._hero-overlay-section ._background::before,
                ._hero-overlay-section ._hero-background::before {
                    content: "" !important;
                    display: block !important;
                    position: absolute;
                    inset: 0;
                    background: linear-gradient(180deg, rgba(15,23,42,0.58) 0%, rgba(15,23,42,0.66) 100%) !important;
                    opacity: 1 !important;
                    z-index: 1;
                    pointer-events: none;
                }
                ._hero-overlay-section ._background picture,
                ._hero-overlay-section ._hero-background picture,
                ._hero-overlay-section ._background img,
                ._hero-overlay-section ._hero-background img {
                    position: absolute !important;
                    inset: 0;
                    width: 100% !important;
                    height: 100% !important;
                    object-fit: cover !important;
                    border-radius: 0 !important;
                    margin: 0 !important;
                }
                ._hero-overlay-section ._hero-heading,
                ._hero-overlay-section ._hero-intro {
                    background: transparent !important;
                    border-left: 0 !important;
                    border-radius: 0 !important;
                    padding-left: 0 !important;
                    padding-right: 0 !important;
                    text-align: center;
                }
                ._hero-overlay-section ._hero-heading {
                    margin-bottom: 16px !important;
                }
                ._hero-overlay-section ._hero-intro {
                    margin-bottom: 22px !important;
                }
                ._hero-overlay-section ._button-group {
                    position: relative;
                    z-index: 2;
                }

                /* Issue 3: Iframe / Embed Responsive CSS */
                iframe, embed, object {
                    display: block;
                    width: 100% !important;
                    max-width: 100% !important;
                    border: 0;
                    margin: 12px 0;
                    box-sizing: border-box;
                }
                iframe[src*="firefighters.org"] {
                    background: transparent;
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
        var loadedHtml: String?
        private let prayerRequestAnchor = "prayer-request-response"
        var analyticsPageUuid: String
        var analyticsPageTitle: String
        
        init(
            onNavigate: ((String) -> Void)?,
            analyticsPageUuid: String,
            analyticsPageTitle: String
        ) {
            self.onNavigate = onNavigate
            self.analyticsPageUuid = analyticsPageUuid
            self.analyticsPageTitle = analyticsPageTitle
        }

        private func normalizedUrlForNavigation(_ url: URL) -> URL {
            guard url.scheme?.lowercased() == SiteConfig.shared.authScheme else {
                return url
            }

            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.scheme = "https"
            return components?.url ?? url
        }

        private func isFormPage(_ url: URL) -> Bool {
            let path = url.path.lowercased()
            let fragment = url.fragment?.lowercased()
            return path.contains("/prayer-request") ||
                path.contains("/chaplain-request") ||
                path.contains("/forms/") ||
                fragment?.hasSuffix("-response") == true
        }

        private func normalizedUrlForExternalOpen(_ url: URL) -> URL {
            let normalized = normalizedUrlForNavigation(url)
            return normalizedFormUrlForExternalOpen(normalized)
        }

        private func normalizedFormUrlForExternalOpen(_ url: URL) -> URL {
            guard url.path.lowercased().contains("/prayer-request") else {
                return url
            }

            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            let currentFragment = components?.fragment?.trimmingCharacters(in: .whitespacesAndNewlines)

            // Preserve existing explicit non-empty fragments to avoid breaking deep links.
            if let fragment = currentFragment, !fragment.isEmpty, fragment != prayerRequestAnchor {
                return url
            }

            if currentFragment == prayerRequestAnchor {
                return url
            }

            components?.fragment = prayerRequestAnchor
            return components?.url ?? url
        }

        private func openInExternalBrowser(_ url: URL, linkLabel: String? = nil) {
            let normalized = normalizedUrlForExternalOpen(url)
            MipAnalytics.logExternalLink(
                url: normalized,
                pageUuid: analyticsPageUuid.isEmpty ? nil : analyticsPageUuid,
                pageTitle: analyticsPageTitle.isEmpty ? nil : analyticsPageTitle,
                linkLabel: linkLabel,
                linkSource: "html_content"
            )
            UIApplication.shared.open(normalized)
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Fix WKWebView not rendering background colors from inline styles
            // WKWebView with isOpaque=false can fail to apply inline background-color
            // Solution: Create a <style> block with explicit CSS rules for each section
            webView.evaluateJavaScript("""
                (function() {
                    document.querySelectorAll('._background').forEach(function(bg) {
                        const hasMedia = bg.querySelector('picture, img, video, iframe, embed, object, source');
                        if (!hasMedia && bg.textContent.trim() === '') {
                            bg.classList.add('_background-empty');
                        }
                    });

                    document.querySelectorAll('._section').forEach(function(section) {
                        const headings = section.querySelectorAll(':scope > ._heading');
                        const buttonGroups = section.querySelectorAll(':scope > ._button-group');
                        const emptyBackgrounds = section.querySelectorAll(':scope > ._background-empty');
                        if (headings.length === 2 && buttonGroups.length === 2 && emptyBackgrounds.length >= 1) {
                            section.classList.add('_paired-cta-section');
                            section.style.setProperty('background-color', '#f1f1f1', 'important');
                            headings[0].classList.add('_paired-cta-card-start');
                            headings[1].classList.add('_paired-cta-card-start');
                            buttonGroups[0].classList.add('_paired-cta-card-end');
                            buttonGroups[1].classList.add('_paired-cta-card-end');
                        }
                    });

                    function styleValue(element, property) {
                        if (!element) return '';
                        const target = property.toLowerCase();
                        const styleAttr = element.getAttribute('style') || '';
                        const parts = styleAttr.split(';');
                        for (let i = 0; i < parts.length; i++) {
                            const colon = parts[i].indexOf(':');
                            if (colon === -1) continue;
                            const name = parts[i].slice(0, colon).trim().toLowerCase();
                            if (name === target) {
                                return parts[i].slice(colon + 1).trim();
                            }
                        }
                        return '';
                    }

                    function imageCardBackgroundFor(section) {
                        return styleValue(section, 'background-color')
                            || styleValue(section.querySelector(':scope > ._background-empty'), '--bgColor')
                            || styleValue(section.querySelector(':scope > ._background'), '--bgColor')
                            || '#D9232A';
                    }

                    function imageCardHeadingColorFor(section, heading) {
                        return styleValue(section, 'color')
                            || styleValue(heading, '--theme-content')
                            || styleValue(section, '--theme-content')
                            || '#ffffff';
                    }

                    function isImageOnlySection(section) {
                        const imageLinks = section.querySelectorAll(':scope > a._image-link');
                        if (imageLinks.length === 0) return false;
                        return !section.querySelector(':scope > ._heading, :scope > ._text, :scope > ._button-group, :scope > ._background');
                    }

                    document.querySelectorAll('._section').forEach(function(section) {
                        const heading = section.querySelector(':scope > ._heading');
                        const decorativeBackgrounds = section.querySelectorAll(':scope > ._background-empty');
                        const hasBodyContent = section.querySelector(':scope > ._text, :scope > ._button-group, :scope > a._image-link, :scope > figure._image');
                        if (!heading || decorativeBackgrounds.length === 0 || hasBodyContent) return;

                        let sibling = section.nextElementSibling;
                        let imageSections = [];
                        while (sibling && sibling.classList && sibling.classList.contains('_section') && isImageOnlySection(sibling)) {
                            imageSections.push(sibling);
                            sibling = sibling.nextElementSibling;
                        }
                        if (imageSections.length === 0) return;

                        const imageCardBackground = imageCardBackgroundFor(section);
                        const imageCardHeadingColor = imageCardHeadingColorFor(section, heading);

                        section.classList.add('_image-card-heading-section');
                        section.style.setProperty('--image-card-bg', imageCardBackground);
                        section.style.setProperty('--image-card-heading-color', imageCardHeadingColor);
                        section.style.setProperty('background-color', imageCardBackground, 'important');
                        section.style.setProperty('margin-bottom', '0', 'important');
                        section.querySelectorAll(':scope > ._heading, :scope > ._heading *').forEach(function(el) {
                            el.style.setProperty('color', imageCardHeadingColor, 'important');
                            el.style.setProperty('text-shadow', 'none', 'important');
                        });
                        imageSections.forEach(function(imageSection) {
                            imageSection.classList.add('_image-card-grid-section');
                            imageSection.style.setProperty('--image-card-bg', imageCardBackground);
                            imageSection.style.setProperty('background-color', imageCardBackground, 'important');
                            imageSection.style.setProperty('margin-top', '0', 'important');
                            imageSection.style.setProperty('margin-bottom', '0', 'important');
                        });
                    });

                    const sections = document.querySelectorAll('._section');
                    if (sections.length === 0) return;

                    function parseCssColor(value) {
                        if (!value) return null;
                        const color = value.trim().toLowerCase();
                        if (color === 'transparent') return null;
                        let hex = color.match(/^#([0-9a-f]{3}|[0-9a-f]{6})$/i);
                        if (hex) {
                            let raw = hex[1];
                            if (raw.length === 3) {
                                raw = raw.split('').map(function(ch) { return ch + ch; }).join('');
                            }
                            return {
                                r: parseInt(raw.slice(0, 2), 16),
                                g: parseInt(raw.slice(2, 4), 16),
                                b: parseInt(raw.slice(4, 6), 16)
                            };
                        }
                        let rgb = color.match(/^rgba?\\(\\s*([\\d.]+)\\s*,\\s*([\\d.]+)\\s*,\\s*([\\d.]+)(?:\\s*,\\s*([\\d.]+))?/i);
                        if (rgb) {
                            if (rgb[4] !== undefined && Number(rgb[4]) === 0) return null;
                            return {
                                r: Number(rgb[1]),
                                g: Number(rgb[2]),
                                b: Number(rgb[3])
                            };
                        }
                        return null;
                    }

                    function luminance(channel) {
                        const value = channel / 255;
                        return value <= 0.03928 ? value / 12.92 : Math.pow((value + 0.055) / 1.055, 2.4);
                    }

                    function relativeLuminance(color) {
                        return 0.2126 * luminance(color.r) + 0.7152 * luminance(color.g) + 0.0722 * luminance(color.b);
                    }

                    function contrastRatio(first, second) {
                        const lighter = Math.max(relativeLuminance(first), relativeLuminance(second));
                        const darker = Math.min(relativeLuminance(first), relativeLuminance(second));
                        return (lighter + 0.05) / (darker + 0.05);
                    }

                    function readableTextColor(backgroundValue, declaredValue) {
                        const background = parseCssColor(backgroundValue);
                        if (!background) return null;

                        const fallbackText = parseCssColor('#334155');
                        const declaredText = parseCssColor(declaredValue) || fallbackText;
                        if (contrastRatio(background, declaredText) >= 4.5) {
                            return declaredValue ? declaredValue.trim() : null;
                        }

                        const white = parseCssColor('#ffffff');
                        const dark = parseCssColor('#0f172a');
                        return contrastRatio(background, white) >= contrastRatio(background, dark) ? '#ffffff' : '#0f172a';
                    }

                    function effectiveBackgroundColor(section, bgMatch) {
                        if (bgMatch && bgMatch[1]) {
                            const inlineValue = bgMatch[1].trim();
                            if (parseCssColor(inlineValue)) return inlineValue;
                        }

                        const computedValue = window.getComputedStyle(section).backgroundColor;
                        if (parseCssColor(computedValue)) return computedValue;

                        const bgElement = section.querySelector(':scope > ._background, :scope > ._background-empty');
                        if (bgElement) {
                            const bgStyle = window.getComputedStyle(bgElement);
                            if (parseCssColor(bgStyle.backgroundColor)) return bgStyle.backgroundColor;
                        }

                        return bgMatch && bgMatch[1] ? bgMatch[1].trim() : '';
                    }

                    function effectiveTextColor(section, colorMatch) {
                        if (colorMatch && colorMatch[1]) {
                            const inlineValue = colorMatch[1].trim();
                            if (parseCssColor(inlineValue)) return inlineValue;
                        }

                        const textElement = section.querySelector('h1, h2, h3, h4, h5, h6, p, li, a:not([class*="_button"]):not([class*="_image-link"]), ._heading, ._text, ._blockquote');
                        const computedValue = window.getComputedStyle(textElement || section).color;
                        return parseCssColor(computedValue) ? computedValue : '';
                    }

                    function forceReadableSectionText(section, color) {
                        if (!color) return;
                        section.style.setProperty('color', color, 'important');
                        section.querySelectorAll('h1, h2, h3, h4, h5, h6, p, li, a:not([class*="_button"]):not([class*="_image-link"]), ._heading, ._heading *, ._text, ._text *, ._blockquote, ._blockquote *').forEach(function(el) {
                            if (el.closest('._button-group')) return;
                            el.style.setProperty('color', color, 'important');
                            el.style.setProperty('text-shadow', 'none', 'important');
                        });
                    }
                    
                    // Build CSS rules for each section with background-color
                    let cssRules = '';
                    sections.forEach(function(section, index) {
                        const styleAttr = section.getAttribute('style') || '';
                        const isHeroSection = section.classList.contains('_hero-section');
                        const isPairedCtaSection = section.classList.contains('_paired-cta-section');
                        const isImageCardSection = section.classList.contains('_image-card-heading-section') || section.classList.contains('_image-card-grid-section');
                        
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
                        
                        const bgValue = effectiveBackgroundColor(section, bgMatch);
                        const colorValue = effectiveTextColor(section, colorMatch);

                        if (bgValue || colorValue) {
                            // Add a unique data attribute to target this specific section
                            section.setAttribute('data-section-id', 'section-' + index);
                            const readableColor = (!isHeroSection && !isPairedCtaSection && !isImageCardSection)
                                ? readableTextColor(bgValue, colorValue)
                                : null;
                            
                            let rule = '._section[data-section-id="section-' + index + '"] { ';
                            if (bgMatch) {
                                if (isPairedCtaSection) {
                                    rule += 'background-color: #f1f1f1 !important; ';
                                } else if (isImageCardSection) {
                                    rule += 'background-color: var(--image-card-bg, #D9232A) !important; ';
                                } else if (!isHeroSection) {
                                    rule += 'background-color: ' + bgValue + ' !important; ';
                                } else {
                                    cssRules += '._section._hero-section[data-section-id="section-' + index + '"] { background-color: transparent !important; background-image: none !important; }\\n';
                                }
                            }
                            if (readableColor) {
                                section.setAttribute('data-readable-text-color', readableColor);
                                rule += 'color: ' + readableColor + ' !important; ';
                            } else if (colorMatch) {
                                rule += 'color: ' + colorValue + ' !important; ';
                            }
                            rule += '}\\n';
                            cssRules += rule;
                            
                            // Also add child text color inheritance
                            if (readableColor) {
                                forceReadableSectionText(section, readableColor);
                                cssRules += '._section[data-section-id="section-' + index + '"] h1, ._section[data-section-id="section-' + index + '"] h2, ._section[data-section-id="section-' + index + '"] h3, ._section[data-section-id="section-' + index + '"] h4, ._section[data-section-id="section-' + index + '"] h5, ._section[data-section-id="section-' + index + '"] h6, ._section[data-section-id="section-' + index + '"] p, ._section[data-section-id="section-' + index + '"] li, ._section[data-section-id="section-' + index + '"] a:not([class*="_button"]):not([class*="_image-link"]), ._section[data-section-id="section-' + index + '"] ._heading, ._section[data-section-id="section-' + index + '"] ._heading *, ._section[data-section-id="section-' + index + '"] ._text, ._section[data-section-id="section-' + index + '"] ._text *, ._section[data-section-id="section-' + index + '"] ._blockquote, ._section[data-section-id="section-' + index + '"] ._blockquote * { color: inherit !important; text-shadow: none !important; }\\n';
                            } else if (colorMatch) {
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

                    document.querySelectorAll('._section[data-readable-text-color]').forEach(function(section) {
                        forceReadableSectionText(section, section.getAttribute('data-readable-text-color'));
                    });
                    
                    // Fix blockquote elements inside colored sections
                    const blockquotes = document.querySelectorAll('._section ._blockquote');
                    blockquotes.forEach(function(bq) {
                        const section = bq.closest('._section');
                        if (section) {
                            const sectionStyle = section.getAttribute('style') || '';
                            const colorMatch = sectionStyle.match(/(?:^|;)\\s*color:\\s*([^;]+)/i);
                            const readableColor = section.getAttribute('data-readable-text-color');
                            if (readableColor || colorMatch) {
                                const color = readableColor || colorMatch[1].trim();
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
            
            updateContentHeight(for: webView)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self, weak webView] in
                guard let webView else { return }
                self?.updateContentHeight(for: webView)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self, weak webView] in
                guard let webView else { return }
                self?.updateContentHeight(for: webView)
            }
        }

        private func updateContentHeight(for webView: WKWebView) {
            webView.evaluateJavaScript("""
                (function() {
                    const body = document.body;
                    const doc = document.documentElement;
                    const height = Math.max(
                        body ? body.scrollHeight : 0,
                        body ? body.offsetHeight : 0,
                        doc ? doc.scrollHeight : 0,
                        doc ? doc.offsetHeight : 0
                    );
                    return Math.ceil(height + 24);
                })();
            """) { [weak self] result, _ in
                guard let rawHeight = result as? NSNumber else { return }
                let height = CGFloat(truncating: rawHeight)
                guard height > 0 else { return }

                DispatchQueue.main.async {
                    if let currentHeight = self?.contentHeightBinding?.wrappedValue,
                       abs(currentHeight - height) < 8 {
                        return
                    }
                    self?.contentHeightBinding?.wrappedValue = height
                }
            }
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let rawUrl = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }

            let url = normalizedUrlForNavigation(rawUrl)
            
            let urlString = url.absoluteString
            let navigationType = navigationAction.navigationType
            
            let baseURLString = SiteConfig.shared.siteBaseURL.absoluteString
            if urlString == baseURLString || 
               urlString == "\(baseURLString)/" ||
               (SiteConfig.shared.isFirstPartyHost(url.host) && (url.path.isEmpty || url.path == "/")) {
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
            if isFormPage(url) {
                openInExternalBrowser(url)
                decisionHandler(.cancel)
                return
            }
            
            if let host = url.host, !SiteConfig.shared.isFirstPartyHost(host), !urlString.hasPrefix("/") {
                openInExternalBrowser(url)
                decisionHandler(.cancel)
                return
            }
            
            // Internal non-UUID links - try to resolve via API
            Task { [weak webView] in
                if let uuid = await MipApiClient.shared.resolvePageUuidByUrl(url) {
                    logger.notice("Resolved internal link \(urlString) to UUID: \(uuid)")
                    await MainActor.run {
                        onNavigate?(uuid)
                    }
                } else {
                    logger.notice("Failed to resolve internal link \(urlString), falling back to in-webview load")
                    await MainActor.run {
                        _ = webView?.load(URLRequest(url: url))
                    }
                }
            }
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
