import SwiftUI

@main
struct ROHApp: App {
    @StateObject private var store = ROHContentStore()

    var body: some Scene {
        WindowGroup {
            ROHRootView()
                .environmentObject(store)
                .task {
                    await store.loadInitialContent()
                }
        }
    }
}
