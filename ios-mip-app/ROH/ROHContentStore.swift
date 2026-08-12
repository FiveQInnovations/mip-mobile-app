import Foundation

@MainActor
final class ROHContentStore: ObservableObject {
    @Published private(set) var language: ROHContentLanguage
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

    private var client: ROHAPIClientProtocol
    private let makeClient: (ROHContentLanguage) -> ROHAPIClientProtocol
    private var nextEpisodePage: URL?
    private var nextArticlePage: URL?
    private var nextProductPage: URL?
    private var nextShowEpisodePages: [Int: URL] = [:]
    private var nextBlogArticlePages: [Int: URL] = [:]
    private var loadedShowEpisodeIDs: Set<Int> = []
    private var loadedBlogArticleIDs: Set<Int> = []
    private var didStartInitialLoad = false
    private var contentGeneration = 0

    enum Group: String, Hashable {
        case shows, episodes, blogs, articles, features, products
    }

    init(
        language: ROHContentLanguage = .english,
        clientFactory: @escaping (ROHContentLanguage) -> ROHAPIClientProtocol = { ROHAPIClient(language: $0) }
    ) {
        self.language = language
        makeClient = clientFactory
        client = clientFactory(language)
    }

    func setLanguage(_ language: ROHContentLanguage) async {
        guard language != self.language else { return }
        contentGeneration += 1
        self.language = language
        UserDefaults.standard.set(language.rawValue, forKey: ROHContentLanguage.preferenceKey)
        client = makeClient(language)
        resetContent()
        await loadInitialContent()
    }

    func selectInitialLanguage(_ language: ROHContentLanguage) async {
        UserDefaults.standard.set(language.rawValue, forKey: ROHContentLanguage.preferenceKey)
        if language == self.language {
            await loadInitialContent()
        } else {
            await setLanguage(language)
        }
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
        let generation = contentGeneration
        let client = client
        defer {
            if generation == contentGeneration {
                showEpisodeLoading.remove(show.id)
            }
        }
        do {
            let page = try await client.fetchEpisodes(showID: show.id, page: refresh ? nil : nextShowEpisodePages[show.id])
            guard generation == contentGeneration else { return }
            showEpisodes[show.id] = refresh
                ? page.items
                : deduplicating((showEpisodes[show.id] ?? []) + page.items)
            nextShowEpisodePages[show.id] = page.nextPage
        } catch {
            guard generation == contentGeneration else { return }
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
        let generation = contentGeneration
        let client = client
        defer {
            if generation == contentGeneration {
                blogArticleLoading.remove(blog.id)
            }
        }
        do {
            let page = try await client.fetchArticles(blogID: blog.id, page: refresh ? nil : nextBlogArticlePages[blog.id])
            guard generation == contentGeneration else { return }
            blogArticles[blog.id] = refresh
                ? page.items
                : deduplicating((blogArticles[blog.id] ?? []) + page.items)
            nextBlogArticlePages[blog.id] = page.nextPage
        } catch {
            guard generation == contentGeneration else { return }
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
        shows.first(where: { $0.id == episode.podcastID })?.title
            ?? (language == .spanish ? "Aviva Nuestros Corazones" : "Revive Our Hearts")
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
        let generation = contentGeneration
        let client = client
        await load(.shows, generation: generation) {
            let result = try await client.fetchShows()
            guard generation == contentGeneration else { return }
            shows = result
        }
    }

    private func loadBlogs() async {
        let generation = contentGeneration
        let client = client
        await load(.blogs, generation: generation) {
            let result = try await client.fetchBlogs()
            guard generation == contentGeneration else { return }
            blogs = result
        }
    }

    private func loadFeatures() async {
        let generation = contentGeneration
        let client = client
        await load(.features, generation: generation) {
            let result = try await client.fetchFeatures()
            guard generation == contentGeneration else { return }
            features = result
        }
    }

    private func loadEpisodes(refresh: Bool) async {
        let generation = contentGeneration
        let client = client
        await load(.episodes, isPagination: !refresh, generation: generation) {
            let page = try await client.fetchEpisodes(page: refresh ? nil : nextEpisodePage)
            guard generation == contentGeneration else { return }
            episodes = refresh ? page.items : deduplicating(episodes + page.items)
            nextEpisodePage = page.nextPage
        }
    }

    private func loadArticles(refresh: Bool) async {
        let generation = contentGeneration
        let client = client
        await load(.articles, isPagination: !refresh, generation: generation) {
            let page = try await client.fetchArticles(blogID: nil, page: refresh ? nil : nextArticlePage)
            guard generation == contentGeneration else { return }
            articles = refresh ? page.items : deduplicating(articles + page.items)
            nextArticlePage = page.nextPage
        }
    }

    private func loadProducts(refresh: Bool) async {
        let generation = contentGeneration
        let client = client
        await load(.products, isPagination: !refresh, generation: generation) {
            let page = try await client.fetchProducts(page: refresh ? nil : nextProductPage)
            guard generation == contentGeneration else { return }
            products = refresh ? page.items : deduplicating(products + page.items)
            nextProductPage = page.nextPage
        }
    }

    private func load(_ group: Group, isPagination: Bool = false, generation: Int, operation: () async throws -> Void) async {
        guard generation == contentGeneration else { return }
        guard !loadingGroups.contains(group), !loadingMoreGroups.contains(group) else { return }
        if isPagination {
            loadingMoreGroups.insert(group)
            paginationErrors[group] = nil
        } else {
            loadingGroups.insert(group)
            errors[group] = nil
        }
        defer {
            if generation == contentGeneration {
                if isPagination { loadingMoreGroups.remove(group) } else { loadingGroups.remove(group) }
            }
        }
        do {
            try await operation()
        } catch is CancellationError {
            return
        } catch {
            guard generation == contentGeneration else { return }
            if isPagination {
                paginationErrors[group] = error.localizedDescription
            } else {
                errors[group] = error.localizedDescription
            }
        }
    }

    private func resetContent() {
        shows = []
        episodes = []
        blogs = []
        articles = []
        features = []
        products = []
        showEpisodes = [:]
        blogArticles = [:]
        loadingGroups = []
        errors = [:]
        paginationErrors = [:]
        loadingMoreGroups = []
        showEpisodeLoading = []
        showEpisodeErrors = [:]
        blogArticleLoading = []
        blogArticleErrors = [:]
        nextEpisodePage = nil
        nextArticlePage = nil
        nextProductPage = nil
        nextShowEpisodePages = [:]
        nextBlogArticlePages = [:]
        loadedShowEpisodeIDs = []
        loadedBlogArticleIDs = []
        didStartInitialLoad = false
    }

    private func deduplicating<Item: Identifiable>(_ items: [Item]) -> [Item] where Item.ID: Hashable {
        var seen: Set<Item.ID> = []
        return items.filter { seen.insert($0.id).inserted }
    }
}
