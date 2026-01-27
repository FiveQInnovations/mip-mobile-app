//
//  HomeLogoView.swift
//  FFCI
//
//  Logo section for homepage - displays main Firefighters for Christ logo
//

import SwiftUI
import WebKit

struct HomeLogoView: View {
    let siteMeta: SiteMeta
    
    var body: some View {
        VStack {
            if let logo = siteMeta.logo {
                // Process logo URL - prepend base URL if relative
                let logoUrl = logo.starts(with: "http://") || logo.starts(with: "https://")
                    ? logo
                    : "https://ffci.fiveq.dev\(logo)"
                
                SVGImageView(url: logoUrl)
                    .frame(width: 240, height: 144) // 5:3 aspect ratio, reduced from 280x168
            } else {
                // No logo URL - show site title
                Text(siteMeta.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.059, green: 0.090, blue: 0.164))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
        .background(Color(red: 0.973, green: 0.980, blue: 0.988)) // Light gray #F8FAFC
    }
}

struct SVGImageView: UIViewRepresentable {
    let url: String
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        
        // Create HTML with SVG image - transparent background
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <style>
                * { margin: 0; padding: 0; box-sizing: border-box; }
                html, body { 
                    width: 100%; 
                    height: 100%; 
                    background: transparent; 
                    overflow: hidden;
                }
                body { 
                    display: flex; 
                    justify-content: center; 
                    align-items: center;
                }
                img { 
                    max-width: 100%; 
                    max-height: 100%; 
                    object-fit: contain;
                }
            </style>
        </head>
        <body>
            <img src="\(url)" alt="Logo" />
        </body>
        </html>
        """
        
        webView.loadHTMLString(html, baseURL: URL(string: url))
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // No update needed
    }
}

#Preview {
    HomeLogoView(
        siteMeta: SiteMeta(
            title: "Firefighters for Christ",
            social: nil,
            logo: "https://ffci-5q.b-cdn.net/image/logo-mobile.svg",
            homepageQuickTasks: nil,
            homepageFeatured: nil
        )
    )
}
