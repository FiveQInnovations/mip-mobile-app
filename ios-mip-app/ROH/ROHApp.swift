import SwiftUI

@main
struct ROHApp: App {
    @StateObject private var store = ROHContentStore(language: .preferred)
    @StateObject private var player = ROHAudioPlayerModel()

    var body: some Scene {
        WindowGroup {
            ROHRootView()
                .environmentObject(store)
                .environmentObject(player)
                .task {
                    await store.loadInitialContent()
                }
        }
    }
}
