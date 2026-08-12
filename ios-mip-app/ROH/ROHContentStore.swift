import Foundation

@MainActor
final class ROHContentStore: ObservableObject {
    @Published private(set) var shows: [ROHShow] = []
    @Published private(set) var episodes: [ROHEpisode] = []
    @Published private(set) var blogs: [ROHBlog] = []
    @Published private(set) var articles: [ROHArticle] = []
    @Published private(set) var features: [ROHFeature] = []
    @Published private(set) var products: [ROHProduct] = []
    @Published private(set) var showEpisodes: [Int: [ROHEpisode]] = [:]
    @Published private(set) var blogArticles: [Int: [ROHArticle]] = [:]

    @Published private(set) var loadingGroups: Set<Group> = []
    @Published private(set) var errors: [Group: String] = [:]
    @Published private(set) var paginationErrors: [Group: String] = [:]
    @Published private(set) var loadingMoreGroups: Set<Group> = []
    @Published private(set) var showEpisodeLoading: Set<Int> = []
    @Published private(set) var showEpisodeErrors: [Int: String] = [:]
    @Published private(set) var blogArticleLoading: Set<Int> = []
    @Published private(set) var blogArticleErrors: [Int: String] = [:]

    private let client: ROHAPIClientProtocol
    private var nextEpisodePage: URL?
    private var nextArticlePage: URL?
    private var nextProductPage: URL?
    private var nextShowEpisodePages: [Int: URL] = [:]
    private var nextBlogArticlePages: [Int: URL] = [:]
    private var loadedShowEpisodeIDs: Set<Int> = []
    private var loadedBlogArticleIDs: Set<Int> = []
    private var didStartInitialLoad = false

    enum Group: String, Hashable {
        case shows, episodes, blogs, articles, features, products
    }

    init(client: ROHAPIClientProtocol = ROHAPIClient()) {
        self.client = client
    }

    func loadInitialContent() async {
        guard !didStartInitialLoad else { return }
        didStartInitialLoad = true
        async let shows: Void = loadShows()
        async let episodes: Void = loadEpisodes(refresh: true)
        async let blogs: Void = loadBlogs()
        async let articles: Void = loadArticles(refresh: true)
        async let features: Void = loadFeatures()
        async let products: Void = loadProducts(refresh: true)
        _ = await (shows, episodes, blogs, articles, features, products)
    }

    func refreshHome() async {
        async let shows: Void = loadShows()
        async let episodes: Void = loadEpisodes(refresh: true)
        async let blogs: Void = loadBlogs()
        async let articles: Void = loadArticles(refresh: true)
        async let features: Void = loadFeatures()
        async let products: Void = loadProducts(refresh: true)
        _ = await (shows, episodes, blogs, articles, features, products)
    }

    func retry(_ group: Group) async {
        switch group {
        case .shows: await loadShows()
        case .episodes: await loadEpisodes(refresh: true)
        case .blogs: await loadBlogs()
        case .articles: await loadArticles(refresh: true)
        case .features: await loadFeatures()
        case .products: await loadProducts(refresh: true)
        }
    }

    func loadMoreEpisodesIfNeeded(currentItem: ROHEpisode) async {
        guard currentItem.id == episodes.last?.id, nextEpisodePage != nil else { return }
        await loadEpisodes(refresh: false)
    }

    func loadMoreArticlesIfNeeded(currentItem: ROHArticle) async {
        guard currentItem.id == articles.last?.id, nextArticlePage != nil else { return }
        await loadArticles(refresh: false)
    }

    func loadMoreProductsIfNeeded(currentItem: ROHProduct) async {
        guard currentItem.id == products.last?.id, nextProductPage != nil else { return }
        await loadProducts(refresh: false)
    }

    func loadEpisodes(for show: ROHShow, refresh: Bool = false) async {
        guard !loadedShowEpisodeIDs.contains(show.id) || refresh else { return }
        loadedShowEpisodeIDs.insert(show.id)
        showEpisodeLoading.insert(show.id)
        showEpisodeErrors[show.id] = nil
        defer { showEpisodeLoading.remove(show.id) }
        do {
            let page = try await client.fetchEpisodes(showID: show.id, page: refresh ? nil : nextShowEpisodePages[show.id])
            showEpisodes[show.id] = refresh
                ? page.items
                : deduplicating((showEpisodes[show.id] ?? []) + page.items)
            nextShowEpisodePages[show.id] = page.nextPage
        } catch {
            loadedShowEpisodeIDs.remove(show.id)
            showEpisodeErrors[show.id] = error.localizedDescription
        }
    }

    func loadMoreEpisodes(for show: ROHShow, currentItem: ROHEpisode) async {
        guard currentItem.id == showEpisodes[show.id]?.last?.id,
              nextShowEpisodePages[show.id] != nil else { return }
        loadedShowEpisodeIDs.remove(show.id)
        await loadEpisodes(for: show)
    }

    func loadArticles(for blog: ROHBlog, refresh: Bool = false) async {
        guard !loadedBlogArticleIDs.contains(blog.id) || refresh else { return }
        loadedBlogArticleIDs.insert(blog.id)
        blogArticleLoading.insert(blog.id)
        blogArticleErrors[blog.id] = nil
        defer { blogArticleLoading.remove(blog.id) }
        do {
            let page = try await client.fetchArticles(blogID: blog.id, page: refresh ? nil : nextBlogArticlePages[blog.id])
            blogArticles[blog.id] = refresh
                ? page.items
                : deduplicating((blogArticles[blog.id] ?? []) + page.items)
            nextBlogArticlePages[blog.id] = page.nextPage
        } catch {
            loadedBlogArticleIDs.remove(blog.id)
            blogArticleErrors[blog.id] = error.localizedDescription
        }
    }

    func loadMoreArticles(for blog: ROHBlog, currentItem: ROHArticle) async {
        guard currentItem.id == blogArticles[blog.id]?.last?.id,
              nextBlogArticlePages[blog.id] != nil else { return }
        loadedBlogArticleIDs.remove(blog.id)
        await loadArticles(for: blog)
    }

    func showTitle(for episode: ROHEpisode) -> String {
        shows.first(where: { $0.id == episode.podcastID })?.title ?? "Revive Our Hearts"
    }

    func retryPagination(_ group: Group) async {
        switch group {
        case .episodes: await loadEpisodes(refresh: false)
        case .articles: await loadArticles(refresh: false)
        case .products: await loadProducts(refresh: false)
        default: break
        }
    }

    private func loadShows() async {
        await load(.shows) { shows = try await client.fetchShows() }
    }

    private func loadBlogs() async {
        await load(.blogs) { blogs = try await client.fetchBlogs() }
    }

    private func loadFeatures() async {
        await load(.features) { features = try await client.fetchFeatures() }
    }

    private func loadEpisodes(refresh: Bool) async {
        await load(.episodes, isPagination: !refresh) {
            let page = try await client.fetchEpisodes(page: refresh ? nil : nextEpisodePage)
            episodes = refresh ? page.items : deduplicating(episodes + page.items)
            nextEpisodePage = page.nextPage
        }
    }

    private func loadArticles(refresh: Bool) async {
        await load(.articles, isPagination: !refresh) {
            let page = try await client.fetchArticles(blogID: nil, page: refresh ? nil : nextArticlePage)
            articles = refresh ? page.items : deduplicating(articles + page.items)
            nextArticlePage = page.nextPage
        }
    }

    private func loadProducts(refresh: Bool) async {
        await load(.products, isPagination: !refresh) {
            let page = try await client.fetchProducts(page: refresh ? nil : nextProductPage)
            products = refresh ? page.items : deduplicating(products + page.items)
            nextProductPage = page.nextPage
        }
    }

    private func load(_ group: Group, isPagination: Bool = false, operation: () async throws -> Void) async {
        guard !loadingGroups.contains(group), !loadingMoreGroups.contains(group) else { return }
        if isPagination {
            loadingMoreGroups.insert(group)
            paginationErrors[group] = nil
        } else {
            loadingGroups.insert(group)
            errors[group] = nil
        }
        defer {
            if isPagination { loadingMoreGroups.remove(group) } else { loadingGroups.remove(group) }
        }
        do {
            try await operation()
        } catch is CancellationError {
            return
        } catch {
            if isPagination {
                paginationErrors[group] = error.localizedDescription
            } else {
                errors[group] = error.localizedDescription
            }
        }
    }

    private func deduplicating<Item: Identifiable>(_ items: [Item]) -> [Item] where Item.ID: Hashable {
        var seen: Set<Item.ID> = []
        return items.filter { seen.insert($0.id).inserted }
    }
}
