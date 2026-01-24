//
//  ContentView.swift
//  FFCI
//
//  Main content view with tab navigation
//

import SwiftUI
import os.log

private let logger = Logger(subsystem: "com.fiveq.ffci", category: "UI")

struct ContentView: View {
    @StateObject private var appState = AppState()
    
    var body: some View {
        Group {
            if appState.isLoading {
                LoadingView()
            } else if let error = appState.error {
                ErrorView(message: error) {
                    appState.loadSiteData()
                }
            } else if let siteData = appState.siteData {
                MainTabView(siteData: siteData)
            }
        }
        .task {
            appState.loadSiteData()
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
    @State private var selectedTab = 0
    
    // Filter menu to non-home tabs
    var menuItems: [MenuItem] {
        siteData.menu.filter { $0.page.uuid != "__home__" }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home tab
            HomeView(
                siteMeta: siteData.siteData,
                onQuickTaskClick: { uuid in
                    logger.notice("Quick task clicked: \(uuid)")
                    // Navigate to page - for now just log
                },
                onFeaturedClick: { uuid in
                    logger.notice("Featured clicked: \(uuid)")
                    // Navigate to page - for now just log
                }
            )
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)
            
            // Dynamic tabs from menu
            ForEach(Array(menuItems.enumerated()), id: \.element.page.uuid) { index, item in
                TabPageView(uuid: item.page.uuid)
                    .tabItem {
                        Label(item.label, systemImage: iconForTab(item.icon, index))
                    }
                    .tag(index + 1)
            }
        }
        .accentColor(Color("PrimaryColor"))
    }
    
    private func iconForTab(_ iconName: String?, _ index: Int) -> String {
        // Map icon names from API to SF Symbols
        if let iconName = iconName?.lowercased() {
            switch iconName {
            case "book-outline", "book":
                return "book.fill"
            case "library-outline", "library":
                return "book.fill"
            case "information-circle-outline", "info":
                return "info.circle.fill"
            case "heart-outline", "heart":
                return "heart.fill"
            case "menu-outline", "menu":
                return "line.3.horizontal"
            default:
                break
            }
        }
        
        // Default icons by position
        switch index {
        case 0:
            return "book.fill"
        case 1:
            return "info.circle.fill"
        case 2:
            return "heart.fill"
        default:
            return "line.3.horizontal"
        }
    }
}

#Preview {
    ContentView()
}
