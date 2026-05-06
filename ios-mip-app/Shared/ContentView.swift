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
    @Environment(\.scenePhase) private var scenePhase
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
    @Environment(\.openURL) private var openURL
    @State private var selectedTab = 0
    @State private var previousSelectedTab = 0
    
    // Filter menu to non-home tabs
    var menuItems: [MenuItem] {
        siteData.menu.filter { $0.page.uuid != "__home__" }
    }
    
    var body: some View {
        tabView
        .accentColor(Color("BrandPrimaryColor"))
        .onAppear {
            logTabScreenView(for: selectedTab)
        }
    }
    
    @ViewBuilder
    private var tabView: some View {
        if C4IAppProfile.isCurrentSite {
            c4iTabView
        } else {
            defaultTabView
        }
    }
    
    private var defaultTabView: some View {
        TabView(selection: Binding(
            get: { selectedTab },
            set: { handleTabSelection($0) }
        )) {
            HomeView(
                siteMeta: siteData.siteData,
                onQuickTaskClick: { uuid in
                    logger.notice("Quick task clicked: \(uuid)")
                },
                onFeaturedClick: { uuid in
                    logger.notice("Featured clicked: \(uuid)")
                }
            )
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)
            
            ForEach(Array(menuItems.enumerated()), id: \.offset) { index, item in
                TabPageView(uuid: item.page.uuid)
                    .tabItem {
                        Label(item.label, systemImage: iconForTab(item.icon, index))
                    }
                    .tag(index + 1)
            }
        }
    }
    
    private var c4iTabView: some View {
        TabView(selection: Binding(
            get: { selectedTab },
            set: { handleC4ITabSelection($0) }
        )) {
            HomeView(
                siteMeta: siteData.siteData,
                onQuickTaskClick: { uuid in
                    logger.notice("Quick task clicked: \(uuid)")
                },
                onFeaturedClick: { uuid in
                    logger.notice("Featured clicked: \(uuid)")
                }
            )
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(C4IAppProfile.Tab.home.rawValue)
            
            TabPageView(uuid: C4IAppProfile.ministriesUuid)
                .tabItem {
                    Label("Ministries", systemImage: "heart.fill")
                }
                .tag(C4IAppProfile.Tab.ministries.rawValue)
            
            TabPageView(uuid: C4IAppProfile.watchUuid)
                .tabItem {
                    Label("Watch", systemImage: "play.rectangle.fill")
                }
                .tag(C4IAppProfile.Tab.watch.rawValue)
            
            Color.clear
                .tabItem {
                    Label("Give", systemImage: "gift.fill")
                }
                .tag(C4IAppProfile.Tab.give.rawValue)
            
            C4IMoreView()
                .tabItem {
                    Label("More", systemImage: "line.3.horizontal")
                }
                .tag(C4IAppProfile.Tab.more.rawValue)
        }
    }
    
    private func handleTabSelection(_ newSelection: Int) {
        guard let item = menuItem(forTabSelection: newSelection) else {
            selectedTab = newSelection
            logTabScreenView(for: newSelection)
            return
        }
        
        // External menu tabs should open Safari and keep the current in-app tab selected.
        if let externalUrl = item.externalUrl,
           let url = URL(string: externalUrl) {
            MipAnalytics.logExternalLink(
                url: url,
                pageUuid: item.page.uuid,
                pageTitle: nil,
                linkLabel: item.label,
                linkSource: "menu_tab"
            )
            openURL(url)
            return
        }
        
        selectedTab = newSelection
        previousSelectedTab = newSelection
        logTabScreenView(for: newSelection)
    }
    
    private func handleC4ITabSelection(_ newSelection: Int) {
        if newSelection == C4IAppProfile.Tab.give.rawValue {
            if let url = URL(string: C4IAppProfile.giveUrl) {
                MipAnalytics.logExternalLink(
                    url: url,
                    pageUuid: MipAnalytics.homePageUuid,
                    pageTitle: nil,
                    linkLabel: "Give",
                    linkSource: "menu_tab"
                )
                openURL(url)
            }
            selectedTab = previousSelectedTab
            return
        }
        
        selectedTab = newSelection
        previousSelectedTab = newSelection
        logTabScreenView(for: newSelection)
    }
    
    /// Stable `screen_name`: `home` or `tab/<menu_page_uuid>`.
    private func logTabScreenView(for selection: Int) {
        if C4IAppProfile.isCurrentSite {
            let screenName: String
            switch C4IAppProfile.Tab(rawValue: selection) {
            case .home:
                screenName = "home"
            case .ministries:
                screenName = "tab/\(C4IAppProfile.ministriesUuid)"
            case .watch:
                screenName = "tab/\(C4IAppProfile.watchUuid)"
            case .more:
                screenName = "more"
            default:
                return
            }
            MipAnalytics.logScreenView(screenName: screenName, screenClass: "MainTabView")
            return
        }
        
        if selection == 0 {
            MipAnalytics.logScreenView(screenName: "home", screenClass: "HomeView")
            return
        }
        guard let item = menuItem(forTabSelection: selection) else { return }
        MipAnalytics.logScreenView(
            screenName: "tab/\(item.page.uuid)",
            screenClass: "TabPageView"
        )
    }
    
    private func menuItem(forTabSelection selection: Int) -> MenuItem? {
        let menuIndex = selection - 1
        guard menuIndex >= 0, menuIndex < menuItems.count else {
            return nil
        }
        
        return menuItems[menuIndex]
    }
    
    private func iconForTab(_ iconName: String?, _ index: Int) -> String {
        // Map icon names from CMS API to SF Symbols
        if let iconName = iconName?.lowercased() {
            switch iconName {
            // CMS blueprint icon options
            case "home":
                return "house.fill"
            case "star":
                return "star.fill"
            case "book-outline", "book":
                return "book.fill"
            case "library-outline", "library":
                return "book.fill"
            case "people":
                return "person.2.fill"
            case "person":
                return "person.fill"
            case "information-circle-outline", "information-circle", "info":
                return "info.circle.fill"
            case "hand-left", "hand":
                return "hand.raised.fill"
            case "heart-outline", "heart":
                return "heart.fill"
            case "ellipse", "circle":
                return "circle.fill"
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

enum C4IAppProfile {
    static var isCurrentSite: Bool {
        SiteConfig.shared.authScheme == "c4i-auth"
    }
    
    enum Tab: Int {
        case home = 0
        case ministries = 1
        case watch = 2
        case give = 3
        case more = 4
    }
    
    static let aboutUuid = "xhZj4ejQ65bRhrJg"
    static let ministriesUuid = "7gh4hdoRQgSIE7nI"
    static let learnUuid = "pik8ysClOFGyllBY"
    static let watchUuid = "Sw5g5dDFh35ZEEIc"
    static let getInvolvedUuid = "XoMTNzgSpFybWSiy"
    static let giveUrl = "https://c4i.fiveq.dev/get-involved/donate"
    static let storeUrl = "https://c4i.fiveq.dev/store"
    
    static let moreSections: [C4IMoreSection] = [
        C4IMoreSection(title: "About", items: [
            C4IMoreItem(title: "About Us", systemImage: "info.circle", destination: .page(aboutUuid)),
            C4IMoreItem(title: "Our Story", systemImage: "book.closed", destination: .page("NT9a3MjdDUYuVOiS")),
            C4IMoreItem(title: "Leadership & Team", systemImage: "person.2", destination: .page("WjlIls52GzZvsk7t")),
            C4IMoreItem(title: "Contact", systemImage: "envelope", destination: .page("1eWnsUo0JF08lKMf"))
        ]),
        C4IMoreSection(title: "Learn", items: [
            C4IMoreItem(title: "Learn", systemImage: "graduationcap", destination: .page(learnUuid)),
            C4IMoreItem(title: "Audio", systemImage: "waveform", destination: .page("8zgomEX4mEIWyoiM")),
            C4IMoreItem(title: "Podcast", systemImage: "mic", destination: .page("aYf517xwvTitm6LH")),
            C4IMoreItem(title: "Prayer Map", systemImage: "map", destination: .page("y7s7fMXdoIlSqQJl"))
        ]),
        C4IMoreSection(title: "Get Involved", items: [
            C4IMoreItem(title: "Get Involved", systemImage: "hands.sparkles", destination: .page(getInvolvedUuid)),
            C4IMoreItem(title: "Donate", systemImage: "gift", destination: .external(giveUrl)),
            C4IMoreItem(title: "Pray", systemImage: "heart", destination: .page("Mvk1aXwec0DS2emw")),
            C4IMoreItem(title: "Volunteer", systemImage: "figure.2", destination: .page("aVDlKV98mUiHbwX3")),
            C4IMoreItem(title: "Book a Speaker", systemImage: "person.wave.2", destination: .page("SkJVxSJe1fSeZtjK"))
        ]),
        C4IMoreSection(title: "Links", items: [
            C4IMoreItem(title: "Store", systemImage: "bag", destination: .external(storeUrl))
        ])
    ]
}

struct C4IMoreSection: Identifiable {
    let id = UUID()
    let title: String
    let items: [C4IMoreItem]
}

struct C4IMoreItem: Identifiable {
    let id = UUID()
    let title: String
    let systemImage: String
    let destination: C4IMoreDestination
}

enum C4IMoreDestination {
    case page(String)
    case external(String)
}

struct C4IMoreView: View {
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(C4IAppProfile.moreSections) { section in
                    Section(section.title) {
                        ForEach(section.items) { item in
                            row(for: item)
                        }
                    }
                }
            }
            .navigationTitle("More")
        }
    }
    
    @ViewBuilder
    private func row(for item: C4IMoreItem) -> some View {
        switch item.destination {
        case .page(let uuid):
            NavigationLink(destination: TabPageView(uuid: uuid)) {
                C4IMoreRow(item: item)
            }
        case .external(let urlString):
            Button {
                guard let url = URL(string: urlString) else { return }
                MipAnalytics.logExternalLink(
                    url: url,
                    pageUuid: MipAnalytics.homePageUuid,
                    pageTitle: nil,
                    linkLabel: item.title,
                    linkSource: "more"
                )
                openURL(url)
            } label: {
                C4IMoreRow(item: item)
            }
        }
    }
}

private struct C4IMoreRow: View {
    let item: C4IMoreItem
    
    var body: some View {
        Label(item.title, systemImage: item.systemImage)
            .foregroundColor(.primary)
    }
}

#Preview {
    ContentView()
}
