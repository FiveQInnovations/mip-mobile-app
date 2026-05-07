//
//  ContentView.swift
//  FFCI
//
//  Main content view with tab navigation
//

import SwiftUI
import os.log

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.fiveq.mip", category: "UI")

struct ContentView: View {
    let profile: AppProfile

    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var appState = AppState()
    
    init(profile: AppProfile = .standard) {
        self.profile = profile
    }
    
    var body: some View {
        Group {
            if appState.isLoading {
                LoadingView()
            } else if let error = appState.error {
                ErrorView(message: error) {
                    appState.loadSiteData()
                }
            } else if let siteData = appState.siteData {
                MainTabView(siteData: siteData, profile: profile)
            }
        }
        .environment(\.htmlContentTheme, profile.htmlContentTheme)
        .task {
            appState.loadSiteData()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                MipAnalytics.logAppOpen()
            }
        }
    }
}

class AppState: ObservableObject {
    @Published var siteData: SiteData?
    @Published var isLoading = true
    @Published var error: String?
    
    func loadSiteData() {
        isLoading = true
        error = nil
        
        Task {
            do {
                let data = try await MipApiClient.shared.getSiteData()
                await MainActor.run {
                    self.siteData = data
                    self.isLoading = false
                    logger.notice("Site data loaded: \(data.menu.count) menu items")
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    self.isLoading = false
                    logger.error("Failed to load site data: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct MainTabView: View {
    let siteData: SiteData
    let profile: AppProfile

    @Environment(\.openURL) private var openURL
    @State private var selectedTab = 0
    @State private var previousSelectedTab = 0
    @State private var pageStacks: [Int: [String]] = [:]
    
    private var tabs: [AppTab] {
        profile.tabs(siteData)
    }
    
    var body: some View {
        TabView(selection: Binding(
            get: { selectedTab },
            set: { handleTabSelection($0) }
        )) {
            ForEach(tabs) { tab in
                tabContent(for: tab)
                    .tabItem {
                        Label(tab.title, systemImage: tab.systemImage)
                    }
                    .tag(tab.id)
            }
        }
        .accentColor(Color("BrandPrimaryColor"))
        .environment(\.pageRouter, PageRouter { uuid, preferredTabRootUuid in
            routePage(uuid: uuid, preferredTabRootUuid: preferredTabRootUuid)
        })
        .onAppear {
            logTabScreenView(for: selectedTab)
        }
    }
    
    @ViewBuilder
    private func tabContent(for tab: AppTab) -> some View {
        switch tab.destination {
        case .home:
            HomeView(
                siteMeta: siteData.siteData,
                profile: profile,
                onQuickTaskClick: { uuid in
                    logger.notice("Quick task clicked: \(uuid)")
                },
                onFeaturedClick: { uuid in
                    logger.notice("Featured clicked: \(uuid)")
                }
            )
        case .page(let uuid):
            TabPageView(uuid: uuid, pageStack: pageStackBinding(for: tab, rootUuid: uuid))
        case .external:
            Color.clear
        case .custom(let view):
            view
        }
    }
    
    private func pageStackBinding(for tab: AppTab, rootUuid: String) -> Binding<[String]> {
        Binding(
            get: {
                let stack = pageStacks[tab.id] ?? [rootUuid]
                return stack.isEmpty ? [rootUuid] : stack
            },
            set: { newStack in
                pageStacks[tab.id] = newStack.isEmpty ? [rootUuid] : newStack
            }
        )
    }
    
    private func handleTabSelection(_ newSelection: Int) {
        guard let tab = tabs.first(where: { $0.id == newSelection }) else {
            return
        }
    
        if case .external(let url, let pageUuid, let linkLabel, let linkSource) = tab.destination {
            MipAnalytics.logExternalLink(
                url: url,
                pageUuid: pageUuid,
                pageTitle: nil,
                linkLabel: linkLabel,
                linkSource: linkSource
            )
            openURL(url)
            selectedTab = previousSelectedTab
            return
        }

        selectedTab = newSelection
        previousSelectedTab = newSelection
        logTabScreenView(for: tab)
    }

    private func routePage(uuid: String, preferredTabRootUuid: String?) -> Bool {
        if let preferredTabRootUuid,
           let tab = tabs.first(where: { $0.pageRootUuid == preferredTabRootUuid }) {
            selectedTab = tab.id
            previousSelectedTab = tab.id
            pageStacks[tab.id] = uuid == preferredTabRootUuid ? [preferredTabRootUuid] : [preferredTabRootUuid, uuid]
            logTabScreenView(for: tab)
            return true
        }

        if let tab = tabs.first(where: { $0.pageRootUuid == uuid }) {
            selectedTab = tab.id
            previousSelectedTab = tab.id
            pageStacks[tab.id] = [uuid]
            logTabScreenView(for: tab)
            return true
        }

        return false
    }

    private func logTabScreenView(for selection: Int) {
        guard let tab = tabs.first(where: { $0.id == selection }) else { return }
        logTabScreenView(for: tab)
    }

    private func logTabScreenView(for tab: AppTab) {
        guard let screenName = tab.screenName else { return }
        MipAnalytics.logScreenView(screenName: screenName, screenClass: tab.screenClass)
    }
}

#Preview {
    ContentView()
}
