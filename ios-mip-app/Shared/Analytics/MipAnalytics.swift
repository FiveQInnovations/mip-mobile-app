//
//  MipAnalytics.swift
//  FFCI
//
//  Centralized Firebase Analytics navigation and content events (ticket 029).
//

import FirebaseAnalytics
import Foundation

enum MipAnalytics {
    /// Matches CMS home sentinel used in menu filtering.
    static let homePageUuid = "__home__"

    /// Log when the app becomes active (not automatically collected on iOS).
    static func logAppOpen() {
        Analytics.logEvent(AnalyticsEventAppOpen, parameters: nil)
    }

    /// GA4 `screen_view` with stable `screen_name` and optional SwiftUI/view class name.
    static func logScreenView(screenName: String, screenClass: String? = nil) {
        let name = truncate(screenName, maxLen: 100)
        var params: [String: Any] = [
            AnalyticsParameterScreenName: name
        ]
        if let screenClass {
            params[AnalyticsParameterScreenClass] = truncate(screenClass, maxLen: 100)
        }
        Analytics.logEvent(AnalyticsEventScreenView, parameters: params)
    }

    /// Spec `content_view` with page identity for engagement reporting.
    static func logContentView(pageUuid: String, title: String, contentType: String) {
        Analytics.logEvent("content_view", parameters: [
            "page_uuid": truncate(pageUuid, maxLen: 100),
            "page_title": truncate(title, maxLen: 100),
            "content_type": truncate(contentType, maxLen: 100)
        ])
    }

    /// Spec `external_link` when opening Safari / system browser (ticket 031).
    static func logExternalLink(
        url: URL,
        pageUuid: String?,
        pageTitle: String?,
        linkLabel: String?,
        linkSource: String
    ) {
        var params: [String: Any] = [
            "link_url": truncate(url.absoluteString, maxLen: 100),
            "link_source": truncate(linkSource, maxLen: 100)
        ]
        if let host = url.host, !host.isEmpty {
            params["link_domain"] = truncate(host, maxLen: 100)
        }
        if let pageUuid, !pageUuid.isEmpty {
            params["page_uuid"] = truncate(pageUuid, maxLen: 100)
        }
        if let pageTitle, !pageTitle.isEmpty {
            params["page_title"] = truncate(pageTitle, maxLen: 100)
        }
        if let linkLabel, !linkLabel.isEmpty {
            params["link_label"] = truncate(linkLabel, maxLen: 100)
        }
        Analytics.logEvent("external_link", parameters: params)
    }

    private static func truncate(_ string: String, maxLen: Int) -> String {
        guard string.count > maxLen else { return string }
        return String(string.prefix(maxLen))
    }
}
