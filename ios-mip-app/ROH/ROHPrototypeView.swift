import AVFoundation
import SwiftUI
import WebKit

let rohInk = Color(red: 0.03, green: 0.20, blue: 0.22)
let rohTeal = Color(red: 0.06, green: 0.54, blue: 0.61)
let rohCream = Color(red: 0.98, green: 0.97, blue: 0.94)

struct ROHRootView: View {
    @EnvironmentObject private var player: ROHAudioPlayerModel
    @State private var isPlayerPresented = false

    var body: some View {
        TabView {
            NavigationStack { ROHHomeView() }
                .rohMiniPlayerInset { isPlayerPresented = true }
                .tabItem { Label("Home", systemImage: "house") }
            NavigationStack { ROHShowsView() }
                .rohMiniPlayerInset { isPlayerPresented = true }
                .tabItem { Label("Podcasts", systemImage: "waveform") }
            NavigationStack { ROHArticlesView(isTabRoot: true) }
                .rohMiniPlayerInset { isPlayerPresented = true }
                .tabItem { Label("Blogs", systemImage: "text.page") }
            NavigationStack { ROHMoreView() }
                .rohMiniPlayerInset { isPlayerPresented = true }
                .tabItem { Label("More", systemImage: "ellipsis") }
        }
        .tint(rohTeal)
        .sheet(isPresented: $isPlayerPresented) {
            if let episode = player.currentEpisode {
                NavigationStack {
                    ROHEpisodeDetailView(episode: episode)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Close") { isPlayerPresented = false }
                            }
                        }
                }
            }
        }
    }
}

private struct ROHHomeView: View {
    @EnvironmentObject private var store: ROHContentStore
    @EnvironmentObject private var player: ROHAudioPlayerModel
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                ROHHeader(tagline: "LISTEN. READ. GROW.")

                if !store.features.isEmpty {
                    ROHSectionTitle("WHAT'S HAPPENING")
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 12) {
                            ForEach(store.features) { feature in
                                Button {
                                    if let url = feature.ctaButtonURL { openURL(url) }
                                } label: {
                                    ROHFeatureCard(feature: feature)
                                }
                                .buttonStyle(.plain)
                                .accessibilityIdentifier("roh-home-feature")
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                } else {
                    ROHSectionState(group: .features, emptyText: "No current announcements.")
                }

                if let episode = store.episodes.first {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("WITH NANCY DEMOSS WOLGEMUTH")
                            .font(.caption2.bold()).tracking(1.6).foregroundStyle(rohTeal)
                        Text("Helping women embrace God's truth for grace-filled living.")
                            .font(.system(size: 34, weight: .bold, design: .serif)).foregroundStyle(.white)
                        NavigationLink(value: episode) {
                            ROHEpisodeHero(episode: episode, showTitle: store.showTitle(for: episode))
                        }
                        .buttonStyle(.plain)
                        Button {
                            player.play(episode)
                        } label: {
                            Label(player.isCurrent(episode) && player.isPlaying ? "PAUSE EPISODE" : "PLAY EPISODE", systemImage: player.isCurrent(episode) && player.isPlaying ? "pause.fill" : "play.fill")
                        }
                        .buttonStyle(ROHCompactPlayButtonStyle())
                    }
                    .padding(20)
                    .background(rohInk)
                } else {
                    ROHSectionState(group: .episodes, emptyText: "No recent episodes.")
                }

                if !store.shows.isEmpty {
                    ROHSectionTitle("Explore shows")
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(alignment: .top, spacing: 12) {
                            ForEach(store.shows) { show in
                                NavigationLink(value: show) { ROHShowCard(show: show, width: 138) }
                                    .buttonStyle(.plain)
                            }
                        }
                    }
                    .contentMargins(.horizontal, 20, for: .scrollContent)
                } else {
                    ROHSectionState(group: .shows, emptyText: "No shows are available.")
                }

                if store.episodes.count > 1 {
                    ROHSectionTitle("Latest episodes")
                    ForEach(store.episodes.dropFirst().prefix(5)) { episode in
                        ROHEpisodeLinkRow(episode: episode, showTitle: store.showTitle(for: episode))
                        .padding(.horizontal, 20)
                    }
                }

                if !store.articles.isEmpty {
                    HStack {
                        ROHSectionTitle("Read the latest")
                        Spacer()
                        NavigationLink("View articles", destination: ROHArticlesView()).font(.caption.bold())
                    }
                    .padding(.trailing, 20)
                    ForEach(store.articles.prefix(3)) { article in
                        NavigationLink(value: article) { ROHArticleRow(article: article) }
                            .buttonStyle(.plain).padding(.horizontal, 20)
                    }
                } else {
                    ROHSectionState(group: .articles, emptyText: "No recent articles.")
                }

                if !store.products.isEmpty {
                    HStack {
                        ROHSectionTitle("Featured resources")
                        Spacer()
                        NavigationLink("View store", destination: ROHStoreView()).font(.caption.bold())
                    }
                    .padding(.trailing, 20)
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 12) {
                            ForEach(store.products.prefix(8)) { product in
                                NavigationLink(value: product) { ROHProductCard(product: product) }
                                    .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                } else {
                    ROHSectionState(group: .products, emptyText: "No featured resources.")
                }
            }
            .padding(.bottom, 24)
        }
        .background(rohCream)
        .toolbar(.hidden, for: .navigationBar)
        .refreshable { await store.refreshHome() }
        .rohDestinations()
    }
}

private struct ROHShowsView: View {
    @EnvironmentObject private var store: ROHContentStore
    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ROHHeader(title: "Podcasts")
                Text("Listen across the full podcast family without leaving the app.")
                    .font(.system(size: 26, weight: .medium, design: .serif))
                    .foregroundStyle(.secondary).padding(.horizontal, 20)
                if store.shows.isEmpty {
                    ROHSectionState(group: .shows, emptyText: "No shows are available.")
                } else {
                    LazyVGrid(columns: columns, spacing: 24) {
                        ForEach(store.shows) { show in
                            NavigationLink(value: show) { ROHShowCard(show: show) }.buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.bottom, 24)
        }
        .background(rohCream).toolbar(.hidden, for: .navigationBar)
        .navigationDestination(for: ROHShow.self) { ROHShowDetailView(show: $0) }
    }
}

private struct ROHShowDetailView: View {
    @EnvironmentObject private var store: ROHContentStore
    let show: ROHShow

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ROHRemoteImage(url: show.wideImageURL).frame(maxWidth: .infinity).frame(height: 230).clipShape(RoundedRectangle(cornerRadius: 16))
                    Text(show.title).font(.system(size: 34, weight: .bold, design: .serif)).foregroundStyle(rohInk)
                    if !show.hosts.isEmpty { Text("With \(show.hosts.joined(separator: ", "))").foregroundStyle(rohTeal) }
                    Text(show.languageName).font(.caption.bold()).foregroundStyle(.secondary)
                    if let description = show.description { Text(rohPlainText(from: description)).foregroundStyle(.secondary) }
                    Text("Latest episodes").font(.title2.bold()).foregroundStyle(rohInk).padding(.top, 8)
                    let episodes = store.showEpisodes[show.id] ?? []
                    if let error = store.showEpisodeErrors[show.id], episodes.isEmpty {
                        ROHInlineRetry(message: error) { await store.loadEpisodes(for: show, refresh: true) }
                    } else if store.showEpisodeLoading.contains(show.id) && episodes.isEmpty {
                        ProgressView().frame(maxWidth: .infinity).padding()
                    } else if episodes.isEmpty {
                        Text("No episodes are available for this show.").foregroundStyle(.secondary)
                    } else {
                        ForEach(episodes) { episode in
                            ROHEpisodeLinkRow(episode: episode, showTitle: show.title)
                                .task { await store.loadMoreEpisodes(for: show, currentItem: episode) }
                            Divider()
                        }
                        if let error = store.showEpisodeErrors[show.id] {
                            ROHInlineRetry(message: error) { await store.loadEpisodes(for: show) }
                        }
                    }
                }
                .frame(width: max(0, geometry.size.width - 40), alignment: .leading)
                .padding(20)
            }
        }
        .background(rohCream).navigationTitle(show.title).navigationBarTitleDisplayMode(.inline)
        .task { await store.loadEpisodes(for: show) }
        .navigationDestination(for: ROHEpisode.self) { ROHEpisodeDetailView(episode: $0) }
    }
}

private struct ROHEpisodeDetailView: View {
    @EnvironmentObject private var store: ROHContentStore
    let episode: ROHEpisode

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ROHRemoteImage(url: episode.wideImageURL).frame(height: 240).clipShape(RoundedRectangle(cornerRadius: 16))
                    Text(store.showTitle(for: episode).uppercased()).font(.caption.bold()).tracking(1.3).foregroundStyle(rohTeal)
                    Text(episode.title).font(.system(size: 34, weight: .bold, design: .serif)).foregroundStyle(rohInk)
                    Text(rohDate(episode.airDate, style: .long)).foregroundStyle(.secondary)
                    if episode.mediaURL != nil {
                        ROHAudioPlayerView(episode: episode)
                    } else {
                        Label("Audio is unavailable for this episode.", systemImage: "speaker.slash").foregroundStyle(.secondary)
                    }
                    if let description = episode.seoDescription { Text(description).foregroundStyle(.secondary) }
                }
                .frame(width: max(0, geometry.size.width - 40), alignment: .leading)
                .padding(20)
            }
        }
        .background(rohCream).navigationTitle("Episode").navigationBarTitleDisplayMode(.inline)
    }
}

private struct ROHArticlesView: View {
    @EnvironmentObject private var store: ROHContentStore
    var isTabRoot = false

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                if isTabRoot {
                    ROHHeader(title: "Blogs").padding(.horizontal, -20).padding(.top, -20)
                } else {
                    Text("Blogs").font(.system(size: 36, weight: .bold, design: .serif)).foregroundStyle(rohInk)
                }
                Text("Biblical truth for everyday life.").font(.title3).foregroundStyle(.secondary)
                ForEach(store.blogs) { blog in
                    NavigationLink(value: blog) {
                        HStack { ROHRemoteImage(url: blog.image).frame(width: 72, height: 72).clipShape(RoundedRectangle(cornerRadius: 10)); Text(blog.title).font(.headline); Spacer(); Image(systemName: "chevron.right") }
                    }.buttonStyle(.plain)
                }
                if store.blogs.isEmpty { ROHSectionState(group: .blogs, emptyText: "No blogs are available.") }
                Text("Latest articles").font(.title2.bold()).padding(.top, 8)
                ForEach(store.articles) { article in
                    NavigationLink(destination: ROHArticleDetailView(article: article)) { ROHArticleRow(article: article) }
                        .buttonStyle(.plain)
                        .task { await store.loadMoreArticlesIfNeeded(currentItem: article) }
                    Divider()
                }
                if store.articles.isEmpty { ROHSectionState(group: .articles, emptyText: "No recent articles are available.") }
                ROHPaginationState(group: .articles)
            }.padding(20)
        }
        .background(rohCream)
        .navigationTitle(isTabRoot ? "" : "Articles")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(isTabRoot ? .hidden : .visible, for: .navigationBar)
        .refreshable { await store.retry(.articles); await store.retry(.blogs) }
        .navigationDestination(for: ROHBlog.self) { ROHBlogDetailView(blog: $0) }
        .navigationDestination(for: ROHArticle.self) { ROHArticleDetailView(article: $0) }
    }
}

private struct ROHBlogDetailView: View {
    @EnvironmentObject private var store: ROHContentStore
    let blog: ROHBlog

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(store.blogArticles[blog.id] ?? []) { article in
                    NavigationLink(value: article) { ROHArticleRow(article: article) }.buttonStyle(.plain)
                        .task { await store.loadMoreArticles(for: blog, currentItem: article) }
                    Divider()
                }
                if let error = store.blogArticleErrors[blog.id] {
                    ROHInlineRetry(message: error) { await store.loadArticles(for: blog, refresh: true) }
                } else if store.blogArticleLoading.contains(blog.id) && store.blogArticles[blog.id, default: []].isEmpty {
                    ProgressView().padding()
                } else if store.blogArticles[blog.id, default: []].isEmpty {
                    Text("No articles are available for this blog.").foregroundStyle(.secondary).padding()
                }
            }.padding(20)
        }
        .background(rohCream).navigationTitle(blog.title)
        .task { await store.loadArticles(for: blog) }
        .navigationDestination(for: ROHArticle.self) { ROHArticleDetailView(article: $0) }
    }
}

private struct ROHArticleDetailView: View {
    let article: ROHArticle
    @State private var contentHeight: CGFloat = 300

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    ROHRemoteImage(url: article.image).frame(maxWidth: .infinity).frame(height: 220).clipShape(RoundedRectangle(cornerRadius: 14))
                    Text(article.title).font(.system(size: 34, weight: .bold, design: .serif)).foregroundStyle(rohInk)
                    Text([article.authors.joined(separator: ", "), rohDate(article.date, style: .long)].filter { !$0.isEmpty }.joined(separator: " · ")).font(.subheadline).foregroundStyle(.secondary)
                    ROHHTMLContentView(html: article.content, contentHeight: $contentHeight).frame(height: contentHeight)
                }
                .frame(width: max(0, geometry.size.width - 40), alignment: .leading)
                .padding(20)
            }
        }
        .background(rohCream).navigationTitle("Article").navigationBarTitleDisplayMode(.inline)
    }
}

private struct ROHStoreView: View {
    @EnvironmentObject private var store: ROHContentStore
    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        ScrollView {
            if store.products.isEmpty {
                ROHSectionState(group: .products, emptyText: "No store resources are available.").padding(.top, 40)
            } else {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(store.products) { product in
                        NavigationLink(destination: ROHProductDetailView(product: product)) { ROHProductCard(product: product) }.buttonStyle(.plain)
                            .task { await store.loadMoreProductsIfNeeded(currentItem: product) }
                    }
                    ROHPaginationState(group: .products)
                }
                .padding(20)
            }
        }
        .background(rohCream).navigationTitle("Store")
        .refreshable { await store.retry(.products) }
        .navigationDestination(for: ROHProduct.self) { ROHProductDetailView(product: $0) }
    }
}

private struct ROHProductDetailView: View {
    @Environment(\.openURL) private var openURL
    let product: ROHProduct
    @State private var contentHeight: CGFloat = 200

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    ROHRemoteImage(url: product.image ?? product.cardImageURL).frame(maxWidth: .infinity).frame(height: 280).clipShape(RoundedRectangle(cornerRadius: 14))
                    Text(product.type.uppercased()).font(.caption.bold()).foregroundStyle(rohTeal)
                    Text(product.title).font(.system(size: 32, weight: .bold, design: .serif)).foregroundStyle(rohInk)
                    if !product.subtitle.isEmpty { Text(product.subtitle).foregroundStyle(.secondary) }
                    if !product.authors.isEmpty { Text(product.authors.joined(separator: ", ")).font(.subheadline) }
                    if !product.topics.isEmpty {
                        Text(product.topics.joined(separator: " · ")).font(.caption.bold()).foregroundStyle(rohTeal)
                    }
                    ROHHTMLContentView(html: product.description, contentHeight: $contentHeight).frame(height: contentHeight)
                    Button("View in store") { if let url = product.storeURL { openURL(url) } }
                        .buttonStyle(ROHPrimaryButtonStyle())
                }
                .frame(width: max(0, geometry.size.width - 40), alignment: .leading)
                .padding(20)
            }
        }
        .background(rohCream).navigationTitle("Resource").navigationBarTitleDisplayMode(.inline)
    }
}

private struct ROHSearchView: View {
    @EnvironmentObject private var store: ROHContentStore
    @State private var query = ""

    private var normalizedQuery: String { query.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var shows: [ROHShow] { normalizedQuery.isEmpty ? [] : store.shows.filter { $0.title.localizedCaseInsensitiveContains(normalizedQuery) || $0.hosts.contains(where: { $0.localizedCaseInsensitiveContains(normalizedQuery) }) } }
    private var episodes: [ROHEpisode] { normalizedQuery.isEmpty ? [] : store.episodes.filter { $0.title.localizedCaseInsensitiveContains(normalizedQuery) || store.showTitle(for: $0).localizedCaseInsensitiveContains(normalizedQuery) } }
    private var articles: [ROHArticle] { normalizedQuery.isEmpty ? [] : store.articles.filter { $0.title.localizedCaseInsensitiveContains(normalizedQuery) || $0.authors.contains(where: { $0.localizedCaseInsensitiveContains(normalizedQuery) }) } }
    private var products: [ROHProduct] { normalizedQuery.isEmpty ? [] : store.products.filter { [$0.title, $0.subtitle, $0.type].contains(where: { $0.localizedCaseInsensitiveContains(normalizedQuery) }) || ($0.authors + $0.topics).contains(where: { $0.localizedCaseInsensitiveContains(normalizedQuery) }) } }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 14) {
                ROHHeader(title: "Search")
                    .padding(.horizontal, -20)
                TextField("Search loaded content", text: $query)
                    .padding(14).background(.white, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(rohTeal.opacity(0.3)))
                    .accessibilityIdentifier("roh-search-input")
                Text("Search covers content currently loaded in the app.").font(.caption).foregroundStyle(.secondary)
                ROHSearchGroup(title: "Shows", items: shows) { ROHShowCard(show: $0) }
                if !episodes.isEmpty {
                    Text("Episodes").font(.title3.bold()).foregroundStyle(rohInk).padding(.top, 8)
                    ForEach(episodes) { episode in
                        ROHEpisodeLinkRow(episode: episode, showTitle: store.showTitle(for: episode))
                        Divider()
                    }
                }
                ROHSearchGroup(title: "Articles", items: articles) { ROHArticleRow(article: $0) }
                ROHSearchGroup(title: "Resources", items: products) { Text($0.title).font(.headline).foregroundStyle(rohInk).frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 8) }
            }.padding(.horizontal, 20).padding(.bottom, 24)
        }
        .background(rohCream).toolbar(.hidden, for: .navigationBar).rohDestinations()
    }
}

private struct ROHSearchGroup<Item: Identifiable & Hashable, Row: View>: View {
    let title: String
    let items: [Item]
    let row: (Item) -> Row

    var body: some View {
        if !items.isEmpty {
            Text(title).font(.title3.bold()).foregroundStyle(rohInk).padding(.top, 8)
            ForEach(items) { item in NavigationLink(value: item) { row(item) }.buttonStyle(.plain); Divider() }
        }
    }
}

private struct ROHMoreView: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ROHHeader(title: "More")
                    .padding(.horizontal, -20)
                ROHWordmark().frame(maxWidth: .infinity).padding(.top, 8)
                Text("Helping women thrive in Christ.").font(.system(size: 34, weight: .bold, design: .serif)).foregroundStyle(rohInk)
                NavigationLink(destination: ROHSearchView()) { ROHLinkCard(title: "Search", subtitle: "Find podcasts and articles", icon: "magnifyingglass") }
                NavigationLink(destination: ROHPlaceholderView(title: "Languages", message: "Choose the language you want to explore.")) { ROHLinkCard(title: "Languages", subtitle: "Explore Revive Our Hearts in your language", icon: "globe") }
                NavigationLink(destination: ROHPlaceholderView(title: "Downloads", message: "Downloaded episodes will appear here.")) { ROHLinkCard(title: "Downloads", subtitle: "Listen offline", icon: "arrow.down.circle") }
                NavigationLink(destination: ROHPlaceholderView(title: "Notes", message: "Your saved notes will appear here.")) { ROHLinkCard(title: "Notes", subtitle: "Keep what you are learning", icon: "note.text") }
                Button { openURL(URL(string: "https://www.reviveourhearts.com/")!) } label: { ROHLinkCard(title: "Visit Revive Our Hearts", subtitle: "Events, studies, and the resource library", icon: "safari") }
                Button { openURL(URL(string: "https://www.reviveourhearts.com/donate/")!) } label: { ROHLinkCard(title: "Ways to give", subtitle: "Support the ministry", icon: "heart") }
                Link("Privacy", destination: URL(string: "https://www.reviveourhearts.com/privacy-policy/")!)
                Link("Terms", destination: URL(string: "https://www.reviveourhearts.com/terms-of-use/")!)
                Link("Copyright", destination: URL(string: "https://www.reviveourhearts.com/permissions/")!)
            }.padding(.horizontal, 20).padding(.bottom, 24)
        }
        .background(rohCream).toolbar(.hidden, for: .navigationBar)
    }
}

private struct ROHPlaceholderView: View {
    let title: String
    let message: String

    var body: some View {
        ContentUnavailableView(title, systemImage: "heart.text.square", description: Text(message))
            .background(rohCream)
            .navigationTitle(title)
    }
}

private struct ROHSectionState: View {
    @EnvironmentObject private var store: ROHContentStore
    let group: ROHContentStore.Group
    let emptyText: String

    var body: some View {
        Group {
            if store.loadingGroups.contains(group) { ProgressView() }
            else if let error = store.errors[group] {
                VStack(spacing: 8) { Text(error).font(.footnote); Button("Retry") { Task { await store.retry(group) } }.accessibilityIdentifier("roh-retry-button") }
            } else { Text(emptyText).font(.footnote).foregroundStyle(.secondary) }
        }.frame(maxWidth: .infinity).padding(.horizontal, 20)
    }
}

private struct ROHPaginationState: View {
    @EnvironmentObject private var store: ROHContentStore
    let group: ROHContentStore.Group

    var body: some View {
        if store.loadingMoreGroups.contains(group) {
            ProgressView().frame(maxWidth: .infinity).padding()
        } else if let error = store.paginationErrors[group] {
            ROHInlineRetry(message: error) { await store.retryPagination(group) }
        }
    }
}

private struct ROHInlineRetry: View {
    let message: String
    let action: () async -> Void

    var body: some View {
        VStack(spacing: 8) {
            Text(message).font(.footnote).foregroundStyle(.secondary)
            Button("Retry") { Task { await action() } }.accessibilityIdentifier("roh-retry-button")
        }
        .frame(maxWidth: .infinity).padding()
    }
}

private struct ROHFeatureCard: View {
    let feature: ROHFeature
    var body: some View { VStack(alignment: .leading, spacing: 8) { ROHRemoteImage(url: feature.squareImage).frame(width: 180, height: 180).clipShape(RoundedRectangle(cornerRadius: 14)); Text(feature.name).font(.headline).foregroundStyle(rohInk).lineLimit(2) }.frame(width: 180) }
}

private struct ROHEpisodeHero: View {
    let episode: ROHEpisode
    let showTitle: String
    var body: some View { VStack(alignment: .leading, spacing: 0) { ROHRemoteImage(url: episode.wideImageURL).frame(maxWidth: .infinity).frame(height: 190); VStack(alignment: .leading, spacing: 8) { Text("TODAY'S EPISODE").font(.caption2.bold()).tracking(1.4).foregroundStyle(rohTeal); Text(episode.title).font(.system(size: 27, weight: .bold, design: .serif)).foregroundStyle(rohInk); Text(showTitle.uppercased()).font(.caption.bold()).foregroundStyle(rohTeal); Text(rohDate(episode.airDate, style: .medium)).font(.caption).foregroundStyle(.secondary) }.frame(maxWidth: .infinity, alignment: .leading).padding(16).background(.white) }.clipShape(RoundedRectangle(cornerRadius: 14)) }
}

private struct ROHShowCard: View {
    let show: ROHShow
    var width: CGFloat? = nil
    var body: some View { VStack(alignment: .leading, spacing: 6) { ROHRemoteImage(url: show.squareImageURL).aspectRatio(1, contentMode: .fit).clipShape(RoundedRectangle(cornerRadius: 11)); Text(show.title).font(.headline).foregroundStyle(rohInk).lineLimit(2).frame(height: 42, alignment: .topLeading); Text(show.hosts.joined(separator: ", ")).font(.caption).foregroundStyle(.secondary).lineLimit(1) }.frame(width: width, alignment: .leading).accessibilityIdentifier("roh-show-card") }
}

private struct ROHEpisodeRow: View {
    let episode: ROHEpisode
    let showTitle: String
    var body: some View { HStack(spacing: 12) { ROHRemoteImage(url: episode.squareImageURL).frame(width: 72, height: 72).clipShape(RoundedRectangle(cornerRadius: 9)); VStack(alignment: .leading, spacing: 3) { Text(episode.title).font(.subheadline.bold()).foregroundStyle(rohInk).lineLimit(2); Text(showTitle).font(.subheadline).foregroundStyle(rohTeal); Text(rohDate(episode.airDate, style: .medium)).font(.caption).foregroundStyle(.secondary) }; Spacer() }.contentShape(Rectangle()).accessibilityIdentifier("roh-episode-row") }
}

private struct ROHEpisodeLinkRow: View {
    @EnvironmentObject private var player: ROHAudioPlayerModel
    let episode: ROHEpisode
    let showTitle: String

    var body: some View {
        HStack(spacing: 8) {
            NavigationLink(value: episode) {
                ROHEpisodeRow(episode: episode, showTitle: showTitle)
            }
            .buttonStyle(.plain)
            Button { player.play(episode) } label: {
                Image(systemName: player.isCurrent(episode) && player.isPlaying ? "pause.fill" : "play.fill")
                    .foregroundStyle(rohTeal)
                    .frame(width: 40, height: 40)
                    .overlay(Circle().stroke(rohTeal.opacity(0.3)))
            }
            .accessibilityLabel(player.isCurrent(episode) && player.isPlaying ? "Pause episode" : "Play episode")
        }
    }
}

private struct ROHArticleRow: View {
    let article: ROHArticle
    var body: some View { HStack(spacing: 12) { ROHRemoteImage(url: article.image).frame(width: 82, height: 72).clipShape(RoundedRectangle(cornerRadius: 9)); VStack(alignment: .leading, spacing: 4) { Text(article.title).font(.headline).foregroundStyle(rohInk).lineLimit(2); Text(article.authors.joined(separator: ", ")).font(.caption).foregroundStyle(.secondary); Text(rohDate(article.date, style: .medium)).font(.caption2).foregroundStyle(.secondary) }; Spacer() }.accessibilityIdentifier("roh-article-row") }
}

private struct ROHProductCard: View {
    let product: ROHProduct
    var body: some View { VStack(alignment: .leading, spacing: 6) { ROHRemoteImage(url: product.cardImageURL).frame(width: 150, height: 150).clipShape(RoundedRectangle(cornerRadius: 11)); Text(product.title).font(.headline).foregroundStyle(rohInk).lineLimit(2); Text(product.type).font(.caption).foregroundStyle(rohTeal) }.frame(width: 150, alignment: .leading).accessibilityIdentifier("roh-product-card") }
}

private struct ROHHeader: View {
    var title: String?; var tagline: String?
    init(title: String? = nil, tagline: String? = nil) { self.title = title; self.tagline = tagline }
    var body: some View { HStack { ROHWordmark(); Spacer(); Text(title ?? tagline ?? "").font(title == nil ? .caption2.bold() : .title3.bold()).tracking(title == nil ? 1.8 : 0).foregroundStyle(title == nil ? rohTeal : rohInk) }.padding(.horizontal, 20).frame(height: 62).background(rohCream).overlay(alignment: .bottom) { Divider() } }
}

private struct ROHWordmark: View {
    var body: some View { HStack(spacing: 5) { Image(systemName: "heart"); Text("Revive Our Hearts").font(.custom("Snell Roundhand", size: 20).weight(.semibold)).lineLimit(1) }.foregroundStyle(rohInk).accessibilityElement(children: .combine).accessibilityLabel("Revive Our Hearts") }
}

private struct ROHSectionTitle: View {
    let title: String
    init(_ title: String) { self.title = title }
    var body: some View { Text(title).font(.system(size: 25, weight: .bold, design: .serif)).foregroundStyle(rohInk).padding(.horizontal, 20) }
}

private struct ROHLinkCard: View {
    let title: String; let subtitle: String; let icon: String
    var body: some View { HStack(spacing: 14) { Image(systemName: icon).font(.title3).foregroundStyle(rohTeal).frame(width: 28); VStack(alignment: .leading) { Text(title).font(.headline); Text(subtitle).font(.subheadline).foregroundStyle(.secondary) }; Spacer(); Image(systemName: "chevron.right").foregroundStyle(.secondary) }.foregroundStyle(rohInk).padding(16).background(.white, in: RoundedRectangle(cornerRadius: 12)) }
}

private struct ROHRemoteImage: View {
    let url: URL?
    var body: some View {
        GeometryReader { geometry in
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                case .failure:
                    placeholder
                default:
                    ZStack {
                        rohInk.opacity(0.08)
                        ProgressView().tint(rohTeal)
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .clipped()
    }

    private var placeholder: some View {
        ZStack {
            rohInk.opacity(0.12)
            Image(systemName: "photo").foregroundStyle(rohTeal)
        }
    }
}

private struct ROHPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View { configuration.label.font(.headline).frame(maxWidth: .infinity).padding().foregroundStyle(.white).background(rohTeal.opacity(configuration.isPressed ? 0.75 : 1), in: RoundedRectangle(cornerRadius: 10)) }
}

private struct ROHCompactPlayButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(rohTeal.opacity(configuration.isPressed ? 0.75 : 1), in: RoundedRectangle(cornerRadius: 6))
    }
}

private extension View {
    func rohMiniPlayerInset(openPlayer: @escaping () -> Void) -> some View {
        modifier(ROHMiniPlayerInset(openPlayer: openPlayer))
    }

    func rohDestinations() -> some View {
        navigationDestination(for: ROHEpisode.self) { ROHEpisodeDetailView(episode: $0) }
            .navigationDestination(for: ROHShow.self) { ROHShowDetailView(show: $0) }
            .navigationDestination(for: ROHArticle.self) { ROHArticleDetailView(article: $0) }
            .navigationDestination(for: ROHProduct.self) { ROHProductDetailView(product: $0) }
    }
}

private struct ROHMiniPlayerInset: ViewModifier {
    @EnvironmentObject private var player: ROHAudioPlayerModel
    let openPlayer: () -> Void

    func body(content: Content) -> some View {
        content.safeAreaInset(edge: .bottom, spacing: 0) {
            if player.currentEpisode != nil {
                ROHMiniPlayer(openPlayer: openPlayer)
            }
        }
    }
}

private func rohPlainText(from html: String) -> String {
    html
        .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        .replacingOccurrences(of: "&nbsp;", with: " ")
        .replacingOccurrences(of: "&amp;", with: "&")
        .replacingOccurrences(of: "&quot;", with: "\"")
        .replacingOccurrences(of: "&#39;", with: "'")
        .trimmingCharacters(in: .whitespacesAndNewlines)
}

@MainActor
final class ROHAudioPlayerModel: ObservableObject {
    @Published private(set) var currentEpisode: ROHEpisode?
    @Published var isPlaying = false
    @Published var isLoading = false
    @Published var elapsed: Double = 0
    @Published var duration: Double = 0
    @Published var error: String?
    private var player: AVPlayer?
    private var timeObserver: Any?
    private var statusObservation: NSKeyValueObservation?
    private var playbackObservation: NSKeyValueObservation?
    private var endObserver: NSObjectProtocol?

    func play(_ episode: ROHEpisode) {
        guard let url = episode.mediaURL else {
            error = "Audio is unavailable for this episode."
            return
        }
        if isCurrent(episode), player != nil {
            toggle()
            return
        }
        load(episode: episode, url: url)
        player?.play()
    }

    func isCurrent(_ episode: ROHEpisode) -> Bool { currentEpisode?.id == episode.id }

    private func load(episode: ROHEpisode, url: URL) {
        removeObservers()
        currentEpisode = episode
        elapsed = 0
        duration = 0
        error = nil
        let player = AVPlayer(url: url)
        self.player = player
        isLoading = true
        statusObservation = player.currentItem?.observe(\.status, options: [.initial, .new]) { [weak self] item, _ in
            Task { @MainActor in
                self?.isLoading = item.status == .unknown
                if item.status == .failed { self?.error = "This episode could not be played." }
                let seconds = item.duration.seconds
                self?.duration = seconds.isFinite ? seconds : 0
            }
        }
        playbackObservation = player.observe(\.timeControlStatus, options: [.initial, .new]) { [weak self] player, _ in
            Task { @MainActor in
                self?.isPlaying = player.timeControlStatus == .playing
                self?.isLoading = player.timeControlStatus == .waitingToPlayAtSpecifiedRate
            }
        }
        if let item = player.currentItem {
            endObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: item, queue: .main) { [weak self] _ in
                Task { @MainActor in self?.isPlaying = false }
            }
        }
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { [weak self] time in
            Task { @MainActor in self?.elapsed = time.seconds.isFinite ? time.seconds : 0 }
        }
    }

    func toggle() {
        guard let player else { return }
        if isPlaying { player.pause() } else { player.play() }
    }

    func seek(by seconds: Double) { seek(to: elapsed + seconds) }

    func seek(to seconds: Double) {
        guard let player else { return }
        let upperBound = duration > 0 ? duration : seconds
        let target = min(max(0, seconds), upperBound)
        player.seek(to: CMTime(seconds: target, preferredTimescale: 600))
        elapsed = target
    }

    func close() {
        player?.pause()
        removeObservers()
        player = nil
        currentEpisode = nil
        isPlaying = false
        isLoading = false
        elapsed = 0
        duration = 0
        error = nil
    }

    private func removeObservers() {
        if let timeObserver { player?.removeTimeObserver(timeObserver) }
        if let endObserver { NotificationCenter.default.removeObserver(endObserver) }
        timeObserver = nil
        endObserver = nil
        statusObservation = nil
        playbackObservation = nil
    }

    deinit {
        if let timeObserver { player?.removeTimeObserver(timeObserver) }
        if let endObserver { NotificationCenter.default.removeObserver(endObserver) }
    }
}

private struct ROHAudioPlayerView: View {
    @EnvironmentObject private var player: ROHAudioPlayerModel
    let episode: ROHEpisode

    var body: some View {
        VStack(spacing: 12) {
            if player.isCurrent(episode), let error = player.error {
                Text(error).font(.footnote).foregroundStyle(.red)
            }
            HStack(spacing: 24) {
                Button { player.seek(by: -15) } label: { Image(systemName: "gobackward.15") }
                    .disabled(!player.isCurrent(episode))
                Button { player.play(episode) } label: {
                    Image(systemName: player.isCurrent(episode) && player.isPlaying ? "pause.fill" : "play.fill")
                        .frame(width: 52, height: 52).foregroundStyle(.white).background(rohTeal, in: Circle())
                }
                .accessibilityLabel(player.isCurrent(episode) && player.isPlaying ? "Pause episode" : "Play episode")
                Button { player.seek(by: 15) } label: { Image(systemName: "goforward.15") }
                    .disabled(!player.isCurrent(episode))
            }
            .font(.title3).foregroundStyle(rohTeal)
            if player.isCurrent(episode) {
                Slider(value: Binding(get: { player.elapsed }, set: { player.seek(to: $0) }), in: 0...max(player.duration, 1))
                    .tint(rohTeal)
                HStack {
                    Text(rohTime(player.elapsed))
                    Spacer()
                    Text(player.duration > 0 ? "-\(rohTime(max(0, player.duration - player.elapsed)))" : "--:--")
                }
                .font(.caption.monospacedDigit()).foregroundStyle(.secondary)
            } else {
                Text("Tap play to start this episode.").font(.footnote).foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(.white, in: RoundedRectangle(cornerRadius: 14))
        .accessibilityIdentifier("roh-audio-player")
    }
}

private struct ROHMiniPlayer: View {
    @EnvironmentObject private var store: ROHContentStore
    @EnvironmentObject private var player: ROHAudioPlayerModel
    let openPlayer: () -> Void

    var body: some View {
        if let episode = player.currentEpisode {
            VStack(spacing: 0) {
                ProgressView(value: player.elapsed, total: max(player.duration, 1)).tint(rohTeal)
                HStack(spacing: 10) {
                    Button(action: openPlayer) {
                        HStack(spacing: 10) {
                            ROHRemoteImage(url: episode.squareImageURL).frame(width: 48, height: 48).clipShape(RoundedRectangle(cornerRadius: 6))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(episode.title).font(.subheadline.bold()).lineLimit(1)
                                Text(store.showTitle(for: episode)).font(.caption).foregroundStyle(rohTeal).lineLimit(1)
                            }
                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    Button(action: player.toggle) {
                        Image(systemName: player.isPlaying ? "pause.fill" : "play.fill").frame(width: 40, height: 40)
                    }
                    .accessibilityLabel(player.isPlaying ? "Pause episode" : "Play episode")
                    Button(action: player.close) {
                        Image(systemName: "xmark").frame(width: 32, height: 40)
                    }
                    .accessibilityLabel("Close player")
                }
                .padding(.horizontal, 12).padding(.vertical, 8)
            }
            .foregroundStyle(rohInk)
            .background(.regularMaterial)
            .overlay(alignment: .top) { Divider() }
            .accessibilityIdentifier("roh-mini-player")
        }
    }
}

private func rohTime(_ seconds: Double) -> String { let value = max(0, Int(seconds)); return String(format: "%d:%02d", value / 60, value % 60) }

private func rohDate(_ date: Date, style: DateFormatter.Style) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = style
    formatter.timeStyle = .none
    formatter.timeZone = TimeZone(identifier: "America/New_York")
    return formatter.string(from: date)
}

private struct ROHHTMLContentView: UIViewRepresentable {
    let html: String
    @Binding var contentHeight: CGFloat
    @Environment(\.openURL) private var openURL

    func makeCoordinator() -> Coordinator { Coordinator(height: $contentHeight, openURL: openURL) }
    func makeUIView(context: Context) -> WKWebView { let view = WKWebView(); view.navigationDelegate = context.coordinator; view.scrollView.isScrollEnabled = false; view.isOpaque = false; view.backgroundColor = .clear; view.accessibilityIdentifier = "roh-html-content-view"; return view }
    func updateUIView(_ view: WKWebView, context: Context) {
        guard context.coordinator.loadedHTML != html else { return }
        context.coordinator.loadedHTML = html
        let document = """
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>body{font:17px -apple-system;color:#1b3436;background:transparent;line-height:1.55;margin:0}img{max-width:100%;height:auto}a{color:#0f899b}h1,h2,h3{font-family:Georgia,serif}</style>
        \(html)
        """
        view.loadHTMLString(document, baseURL: URL(string: "https://www.reviveourhearts.com"))
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        @Binding var height: CGFloat
        let openURL: OpenURLAction
        var loadedHTML: String?
        init(height: Binding<CGFloat>, openURL: OpenURLAction) { _height = height; self.openURL = openURL }
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation?) {
            measure(webView)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self, weak webView] in
                guard let webView else { return }
                self?.measure(webView)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self, weak webView] in
                guard let webView else { return }
                self?.measure(webView)
            }
        }
        func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation?) { measure(webView) }
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation?) { measure(webView) }
        private func measure(_ webView: WKWebView) {
            webView.evaluateJavaScript("document.documentElement.scrollHeight") { [weak self] result, _ in
                if let value = result as? Double { self?.height = max(1, value) }
            }
        }
        func webView(_ webView: WKWebView, decidePolicyFor action: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) { if action.navigationType == .linkActivated, let url = action.request.url { openURL(url); decisionHandler(.cancel) } else { decisionHandler(.allow) } }
    }
}
