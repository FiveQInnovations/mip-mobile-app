//
//  C4IApp.swift
//  C4I
//
//  Christians for Israel - Mobile App
//

import SwiftUI
import FirebaseAnalytics
import FirebaseCore

@main
struct C4IApp: App {
    init() {
        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            FirebaseApp.configure()
            Analytics.setAnalyticsCollectionEnabled(true)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
