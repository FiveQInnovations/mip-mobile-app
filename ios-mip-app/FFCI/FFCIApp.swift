//
//  FFCIApp.swift
//  FFCI
//
//  Firefighters for Christ International
//

import SwiftUI
import FirebaseAnalytics
import FirebaseCore

@main
struct FFCIApp: App {
    init() {
        FirebaseApp.configure()
        // Plist may ship with IS_ANALYTICS_ENABLED false; ensure collection for GA4 / DebugView.
        Analytics.setAnalyticsCollectionEnabled(true)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
