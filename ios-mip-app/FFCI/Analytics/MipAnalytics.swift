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

    private static func truncate(_ string: String, maxLen: Int) -> String {
        guard string.count > maxLen else { return string }
        return String(string.prefix(maxLen))
    }
}
