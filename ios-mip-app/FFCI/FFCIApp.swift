//
//  FFCIApp.swift
//  FFCI
//
//  Firefighters for Christ International
//

import SwiftUI
import FirebaseCore

@main
struct FFCIApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
