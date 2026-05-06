//
//  C4IHomeView.swift
//  C4I
//
//  Christians for Israel home screen.
//

import SwiftUI
import os.log

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.fiveq.c4i", category: "C4IHomeView")

struct C4IHomeView: View {
    let siteMeta: SiteMeta
    var latestEpisodesLoader: (String) async throws -> [CollectionChild] = C4ILatestEpisodesLoader.live
    
    @Environment(\.openURL) private var openURL
    @State private var showSearch = false
    @State private var latestEpisodes: [CollectionChild] = []
    @State private var isLoadingEpisodes = false
    
    private let ministries = C4IHomeContent.ministries
    private let actions = C4IHomeContent.actions
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    HomeHeaderView(siteMeta: siteMeta, logo: C4IAppProfile.profile.headerLogo, onSearchTap: { showSearch = true })
                    heroSection
                    missionSection
                    latestEpisodesSection
                    takePartSection
                    impactSection
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showSearch) {
            SearchView()
        }
        .task {
            await loadLatestEpisodes()
        }
        .onAppear {
            MipAnalytics.logContentView(
                pageUuid: MipAnalytics.homePageUuid,
                title: siteMeta.title,
                contentType: "home"
            )
        }
    }
    
    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HomeLogoView(siteMeta: siteMeta)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Welcome to Christians for Israel")
                    .font(.largeTitle.weight(.bold))
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Empowering Hope, Supporting Israel, and Standing with God's Promises")
                    .font(.title3.weight(.medium))
                    .foregroundColor(.white.opacity(0.86))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            HStack(spacing: 12) {
                NavigationLink(destination: TabPageView(uuid: C4IAppProfile.ministriesUuid)) {
                    Text("Our Ministries")
                        .font(.headline)
                        .foregroundColor(Color("BrandPrimaryColor"))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .clipShape(Capsule())
                }
                
                NavigationLink(destination: TabPageView(uuid: C4IAppProfile.watchUuid)) {
                    Text("Watch Episodes")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .overlay(Capsule().stroke(Color.white.opacity(0.7), lineWidth: 1))
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("BrandSecondaryColor"))
    }
    
    private var missionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                title: "Our Core Mission",
                subtitle: "From Israel to communities in crisis, we respond with compassion, care for the vulnerable, and proclaim the truth of Christ."
            )
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 14) {
                    ForEach(ministries) { ministry in
                        NavigationLink(destination: TabPageView(uuid: ministry.uuid)) {
                            C4IMinistryCard(card: ministry)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 4)
            }
        }
        .padding(.vertical, 24)
        .background(Color(.systemBackground))
    }
    
    private var latestEpisodesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                title: "Israel: The Prophetic Connection",
                subtitle: "Biblical insight, prophetic teaching, and firsthand impact stories from Israel and beyond."
            )
            
            if isLoadingEpisodes && latestEpisodes.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 28)
            } else if latestEpisodes.isEmpty {
                NavigationLink(destination: TabPageView(uuid: C4IAppProfile.watchUuid)) {
                    C4IWatchFallbackCard()
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
            } else {
                VStack(spacing: 12) {
                    ForEach(latestEpisodes, id: \.uuid) { episode in
                        NavigationLink(destination: TabPageView(uuid: episode.uuid)) {
                            C4IEpisodeCard(episode: episode)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
            
            NavigationLink(destination: TabPageView(uuid: C4IAppProfile.watchUuid)) {
                Text("Browse All Episodes")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(Color("BrandPrimaryColor"))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 16)
            .padding(.top, 2)
        }
        .padding(.vertical, 24)
        .background(Color(red: 0.945, green: 0.961, blue: 0.976))
    }
    
    private var takePartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                title: "Take Part in the Mission",
                subtitle: "Whether you give, serve, or share, every action helps bless Israel and care for those in need."
            )
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
                ForEach(actions) { action in
                    actionCard(action)
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 24)
        .background(Color(.systemBackground))
    }
    
    private var impactSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Lives You've Helped Change")
                .font(.title2.weight(.bold))
                .foregroundColor(.white)
            Text("\"I had never experienced this kind of love before. Your team brought hope into my home.\"")
                .font(.title3.weight(.semibold))
                .foregroundColor(.white.opacity(0.92))
                .fixedSize(horizontal: false, vertical: true)
            NavigationLink(destination: TabPageView(uuid: C4IAppProfile.getInvolvedUuid)) {
                Text("Read More Stories of Hope")
                    .font(.headline)
                    .foregroundColor(Color("BrandPrimaryColor"))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 11)
                    .background(Color.white)
                    .clipShape(Capsule())
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack {
                AsyncImage(url: URL(string: "https://c4i-5q.b-cdn.net/image/kid-israel-flag-bg.png?crop=2000,1125,0,0&width=1400")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color("BrandSecondaryColor")
                }
                Color("BrandSecondaryColor").opacity(0.78)
            }
        )
        .clipped()
    }
    
    private func sectionHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title2.weight(.bold))
                .foregroundColor(.primary)
            Text(subtitle)
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private func actionCard(_ action: C4IActionCard) -> some View {
        switch action.destination {
        case .page(let uuid):
            NavigationLink(destination: TabPageView(uuid: uuid)) {
                C4IActionTile(action: action)
            }
            .buttonStyle(.plain)
        case .external(let urlString):
            Button {
                guard let url = URL(string: urlString) else { return }
                MipAnalytics.logExternalLink(
                    url: url,
                    pageUuid: MipAnalytics.homePageUuid,
                    pageTitle: nil,
                    linkLabel: action.title,
                    linkSource: "home_action"
                )
                openURL(url)
            } label: {
                C4IActionTile(action: action)
            }
            .buttonStyle(.plain)
        }
    }
    
    @MainActor
    private func loadLatestEpisodes() async {
        guard latestEpisodes.isEmpty else { return }
        isLoadingEpisodes = true
        defer { isLoadingEpisodes = false }
        
        do {
            latestEpisodes = try await latestEpisodesLoader(C4IAppProfile.watchUuid)
        } catch {
            logger.error("Failed to load C4I latest episodes: \(error.localizedDescription)")
        }
    }
}

enum C4ILatestEpisodesLoader {
    static func live(watchUuid: String) async throws -> [CollectionChild] {
        let page = try await MipApiClient.shared.getPage(uuid: watchUuid)
        return Array((page.children ?? []).prefix(3))
    }
}
