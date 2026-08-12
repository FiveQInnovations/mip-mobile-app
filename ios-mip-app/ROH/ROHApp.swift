import SwiftUI

@main
struct ROHApp: App {
    @StateObject private var store = ROHContentStore(language: .preferred)
    @StateObject private var player = ROHAudioPlayerModel()
    @AppStorage(ROHContentLanguage.onboardingCompletedKey) private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    ROHRootView()
                } else {
                    ROHWelcomeView {
                        hasCompletedOnboarding = true
                    }
                }
            }
                .environmentObject(store)
                .environmentObject(player)
                .environment(\.locale, store.language.locale)
                .task(id: hasCompletedOnboarding) {
                    if hasCompletedOnboarding {
                        await store.loadInitialContent()
                    }
                }
        }
    }
}
