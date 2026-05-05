//
//  VimeoPlayerView.swift
//  FFCI
//
//  Vimeo embed player for video collection items
//

import SwiftUI
import WebKit

struct VimeoPlayerView: UIViewRepresentable {
    let url: String
    let embedHtml: String?

    init(url: String, embedHtml: String? = nil) {
        self.url = url
        self.embedHtml = embedHtml
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.accessibilityIdentifier = "vimeo-player-view"
        webView.loadHTMLString(playerHtml, baseURL: URL(string: "https://player.vimeo.com"))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(playerHtml, baseURL: URL(string: "https://player.vimeo.com"))
    }

    private var playerHtml: String {
        let body = iframeHtml ?? sanitizedEmbedHtml ?? fallbackHtml
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                html, body {
                    margin: 0;
                    padding: 0;
                    width: 100%;
                    height: 100%;
                    overflow: hidden;
                    background: #000;
                }
                .player {
                    position: relative;
                    width: 100%;
                    height: 100%;
                }
                iframe {
                    position: absolute;
                    inset: 0;
                    width: 100%;
                    height: 100%;
                    border: 0;
                }
                a {
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    width: 100%;
                    height: 100%;
                    color: white;
                    font: 600 16px -apple-system, BlinkMacSystemFont, sans-serif;
                    text-decoration: none;
                    background: #111827;
                }
            </style>
        </head>
        <body>
            <div class="player">
                \(body)
            </div>
        </body>
        </html>
        """
    }

    private var iframeHtml: String? {
        guard let videoId = vimeoVideoId else { return nil }
        let src = "https://player.vimeo.com/video/\(videoId)?playsinline=1&title=0&byline=0&portrait=0"
        return "<iframe src=\"\(src)\" allow=\"autoplay; fullscreen; picture-in-picture; clipboard-write; encrypted-media; web-share\" allowfullscreen></iframe>"
    }

    private var sanitizedEmbedHtml: String? {
        guard let embedHtml,
              !embedHtml.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }
        return embedHtml
    }

    private var fallbackHtml: String {
        guard let escapedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return "<a href=\"\(url)\">Open Video</a>"
        }
        return "<a href=\"\(escapedUrl)\">Open Video</a>"
    }

    private var vimeoVideoId: String? {
        guard let components = URLComponents(string: url),
              let host = components.host?.lowercased(),
              host == "vimeo.com" || host.hasSuffix(".vimeo.com") else {
            return nil
        }

        let segments = components.path
            .split(separator: "/")
            .map(String.init)

        if let videoIndex = segments.firstIndex(of: "video"),
           segments.indices.contains(videoIndex + 1),
           segments[videoIndex + 1].allSatisfy(\.isNumber) {
            return segments[videoIndex + 1]
        }

        return segments.first { segment in
            segment.allSatisfy(\.isNumber)
        }
    }
}

#Preview {
    VimeoPlayerView(url: "https://vimeo.com/1073969684?share=copy&fl=sv&fe=ci")
        .aspectRatio(16 / 9, contentMode: .fit)
}
