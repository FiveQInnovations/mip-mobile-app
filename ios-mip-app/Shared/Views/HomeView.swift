//
//  HomeView.swift
//  FFCI
//
//  Home screen with logo, featured content, and resources
//

import SwiftUI
import os.log

private let logger = Logger(subsystem: "com.fiveq.ffci", category: "HomeView")

struct HomeView: View {
    let siteMeta: SiteMeta
    let onQuickTaskClick: (String) -> Void
    let onFeaturedClick: (String) -> Void
    
    @State private var showSearch = false
    
    var body: some View {
        if C4IAppProfile.isCurrentSite {
            C4IHomeView(siteMeta: siteMeta)
        } else {
            defaultHomeView
        }
    }
    
    private var defaultHomeView: some View {
        NavigationStack {
            VStack(spacing: 0) {
            ScrollView {
            VStack(spacing: 0) {
                
                // Header with logo and search button
                HomeHeaderView(siteMeta: siteMeta, onSearchTap: { showSearch = true })
                
                // Logo section - main homepage logo
                HomeLogoView(siteMeta: siteMeta)
                
                // Featured section
                if let featured = siteMeta.homepageFeatured, !featured.isEmpty {
                    FeaturedSectionView(featured: featured, onFeaturedClick: onFeaturedClick)
                }
                
                // Resources section
                if let quickTasks = siteMeta.homepageQuickTasks, !quickTasks.isEmpty {
                    ResourcesScrollView(
                        quickTasks: quickTasks,
                        onQuickTaskClick: onQuickTaskClick
                    )
                }
                
                // Welcome message if no content
                if (siteMeta.homepageQuickTasks?.isEmpty ?? true) && (siteMeta.homepageFeatured?.isEmpty ?? true) {
                    VStack(spacing: 16) {
                        Text("Welcome to")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        Text(siteMeta.title)
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Explore resources and content using the tabs below.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(32)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                }
            }
            }
            .background(Color(.systemBackground))
            }
        }
        .sheet(isPresented: $showSearch) {
            SearchView()
        }
        .onAppear {
            MipAnalytics.logContentView(
                pageUuid: MipAnalytics.homePageUuid,
                title: siteMeta.title,
                contentType: "home"
            )
        }
    }
}

private struct C4IHomeView: View {
    let siteMeta: SiteMeta
    
    @Environment(\.openURL) private var openURL
    @State private var showSearch = false
    @State private var latestEpisodes: [CollectionChild] = []
    @State private var isLoadingEpisodes = false
    
    private let ministries = [
        C4IHomeCard(
            title: "Children at Risk",
            description: "Protecting and nurturing the most vulnerable through faith-based initiatives.",
            imageUrl: "https://c4i-5q.b-cdn.net/image/pexels-pixabay-163768.jpg?crop=1666,1333,334,0&width=700",
            uuid: "wOBbyxzzXbjT51nP"
        ),
        C4IHomeCard(
            title: "Feed the Hungry",
            description: "Providing meals and food security for struggling families across Canada and abroad.",
            imageUrl: "https://c4i-5q.b-cdn.net/image/feeding.jpg?crop=1665,1333,130,0&width=700",
            uuid: "JtjXwwg9lCuFe4ui"
        ),
        C4IHomeCard(
            title: "Humanitarian Aid",
            description: "Supporting the Jewish people through practical aid and spiritual encouragement.",
            imageUrl: "https://c4i-5q.b-cdn.net/image/aid-2.jpg?crop=1665,1333,168,0&width=700",
            uuid: "TMxzmwCuXBvjODle"
        ),
        C4IHomeCard(
            title: "New Immigrants",
            description: "Helping new arrivals integrate through care, mentoring, and basic needs.",
            imageUrl: "https://c4i-5q.b-cdn.net/image/pexels-liza-summer-6383158.jpg?crop=1665,1333,105,0&width=700",
            uuid: "i0bIgOyuNnBwnyRY"
        )
    ]
    
    private let actions = [
        C4IActionCard(title: "Donate", description: "Give critical resources where they are needed most.", systemImage: "gift.fill", destination: .external(C4IAppProfile.giveUrl), isPrimary: true),
        C4IActionCard(title: "Volunteer", description: "Join practical work that blesses Israel and local communities.", systemImage: "person.2.fill", destination: .page("aVDlKV98mUiHbwX3"), isPrimary: false),
        C4IActionCard(title: "Shop", description: "Visit the C4I store for ministry resources.", systemImage: "bag.fill", destination: .external(C4IAppProfile.storeUrl), isPrimary: false),
        C4IActionCard(title: "Pray", description: "Stand with Israel through focused prayer resources.", systemImage: "heart.fill", destination: .page("Mvk1aXwec0DS2emw"), isPrimary: false),
        C4IActionCard(title: "Book a Speaker", description: "Invite a Bible-grounded speaker for your church or event.", systemImage: "person.wave.2.fill", destination: .page("SkJVxSJe1fSeZtjK"), isPrimary: false)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    HomeHeaderView(siteMeta: siteMeta, onSearchTap: { showSearch = true })
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
            let page = try await MipApiClient.shared.getPage(uuid: C4IAppProfile.watchUuid)
            let episodes = Array((page.children ?? []).prefix(3))
            latestEpisodes = episodes
        } catch {
            logger.error("Failed to load C4I latest episodes: \(error.localizedDescription)")
        }
    }
}

private struct C4IHomeCard: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageUrl: String
    let uuid: String
}

private struct C4IActionCard: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let systemImage: String
    let destination: C4IMoreDestination
    let isPrimary: Bool
}

private struct C4IMinistryCard: View {
    let card: C4IHomeCard
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AsyncImage(url: URL(string: card.imageUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 252, height: 152)
            .clipped()
            
            VStack(alignment: .leading, spacing: 8) {
                Text(card.title)
                    .font(.headline.weight(.bold))
                    .foregroundColor(.primary)
                Text(card.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                Text("Learn More")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Color("BrandPrimaryColor"))
                    .padding(.top, 2)
            }
            .padding(14)
        }
        .frame(width: 252, alignment: .topLeading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.10), radius: 8, x: 0, y: 4)
    }
}

private struct C4IEpisodeCard: View {
    let episode: CollectionChild
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                if let cover = episode.cover, let url = URL(string: cover) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color("BrandPrimaryColor").opacity(0.18)
                    }
                } else {
                    LinearGradient(
                        colors: [Color("BrandPrimaryColor"), Color("BrandSecondaryColor")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
                
                Image(systemName: "play.fill")
                    .font(.title2.weight(.bold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.black.opacity(0.35))
                    .clipShape(Circle())
            }
            .frame(width: 108, height: 72)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Latest Episode")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Color("BrandPrimaryColor"))
                Text(episode.title)
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                Text("Watch now")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.bold))
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

private struct C4IWatchFallbackCard: View {
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "play.rectangle.fill")
                .font(.largeTitle)
                .foregroundColor(Color("BrandPrimaryColor"))
            VStack(alignment: .leading, spacing: 6) {
                Text("Watch the Latest Episodes")
                    .font(.headline.weight(.semibold))
                Text("Open Israel: The Prophetic Connection")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct C4IActionTile: View {
    let action: C4IActionCard
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: action.systemImage)
                .font(.title2.weight(.semibold))
                .foregroundColor(action.isPrimary ? .white : Color("BrandPrimaryColor"))
            Text(action.title)
                .font(.headline.weight(.bold))
                .foregroundColor(action.isPrimary ? .white : .primary)
            Text(action.description)
                .font(.caption)
                .foregroundColor(action.isPrimary ? .white.opacity(0.82) : .secondary)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
        .padding(14)
        .background(action.isPrimary ? Color("BrandPrimaryColor") : Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}


#Preview {
    HomeView(
        siteMeta: SiteMeta(
            title: "FFCI",
            social: nil,
            logo: nil,
            homepageQuickTasks: nil,
            homepageFeatured: nil
        ),
        onQuickTaskClick: { _ in },
        onFeaturedClick: { _ in }
    )
}
