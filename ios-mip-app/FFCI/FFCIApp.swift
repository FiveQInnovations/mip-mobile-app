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
        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            FirebaseApp.configure()
            Analytics.setAnalyticsCollectionEnabled(true)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(profile: .standard)
        }
    }
}
