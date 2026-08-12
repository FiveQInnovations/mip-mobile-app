import Foundation
import os.log

private let rohAPILogger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.fiveq.roh", category: "ROHAPI")

enum ROHAPIError: LocalizedError {
    case invalidRequest
    case transport(Error)
    case invalidResponse
    case http(statusCode: Int, url: URL)
    case decoding(Error)

    var errorDescription: String? {
        switch self {
        case .invalidRequest:
            return "The content request could not be created."
        case .transport:
            return "Revive Our Hearts content could not be reached."
        case .invalidResponse:
            return "The content service returned an invalid response."
        case .http:
            return "Revive Our Hearts content is temporarily unavailable."
        case .decoding:
            return "The content response could not be read."
        }
    }
}

protocol ROHAPIClientProtocol {
    func fetchShows() async throws -> [ROHShow]
    func fetchEpisodes(page: URL?) async throws -> ROHPage<ROHEpisode>
    func fetchEpisodes(showID: Int, page: URL?) async throws -> ROHPage<ROHEpisode>
    func fetchBlogs() async throws -> [ROHBlog]
    func fetchArticles(blogID: Int?, page: URL?) async throws -> ROHPage<ROHArticle>
    func fetchFeatures() async throws -> [ROHFeature]
    func fetchProducts(page: URL?) async throws -> ROHPage<ROHProduct>
}

struct ROHAPIClient: ROHAPIClientProtocol {
    private let session: URLSession
    private let baseURL: URL

    init(session: URLSession = .shared, language: ROHContentLanguage = .english) {
        self.session = session
        self.baseURL = language.baseURL
    }

    init(session: URLSession = .shared, baseURL: URL) {
        self.session = session
        self.baseURL = baseURL
    }

    func fetchShows() async throws -> [ROHShow] {
        let page: ROHPaginatedResponse<ROHShow> = try await fetch(path: "/podcast/_api/podcastsapi/")
        return page.results
    }

    func fetchEpisodes(page: URL?) async throws -> ROHPage<ROHEpisode> {
        let response: ROHPaginatedResponse<ROHEpisode> = try await fetch(url: page, path: "/podcast/_api/episodesapi/")
        return ROHPage(items: response.results, nextPage: response.next)
    }

    func fetchEpisodes(showID: Int, page: URL?) async throws -> ROHPage<ROHEpisode> {
        let response: ROHPaginatedResponse<ROHEpisode> = try await fetch(
            url: page,
            path: "/podcast/_api/episodesapi/",
            queryItems: [URLQueryItem(name: "podcast_id", value: String(showID))]
        )
        return ROHPage(items: response.results, nextPage: response.next)
    }

    func fetchBlogs() async throws -> [ROHBlog] {
        let page: ROHPaginatedResponse<ROHBlog> = try await fetch(path: "/blog/_api/blogsapi/")
        return page.results
            .filter { $0.enabled && !$0.feedOnly }
            .sorted { ($0.order, $0.title) < ($1.order, $1.title) }
    }

    func fetchArticles(blogID: Int?, page: URL?) async throws -> ROHPage<ROHArticle> {
        let queryItems = blogID.map { [URLQueryItem(name: "blog_id", value: String($0))] } ?? []
        let response: ROHPaginatedResponse<ROHArticle> = try await fetch(
            url: page,
            path: "/blog/_api/postsapi/",
            queryItems: queryItems
        )
        return ROHPage(items: response.results, nextPage: response.next)
    }

    func fetchFeatures() async throws -> [ROHFeature] {
        let page: ROHPaginatedResponse<ROHFeature> = try await fetch(path: "/feature/_api/featuresapi/")
        return page.results.sorted { ($0.order, $0.name) < ($1.order, $1.name) }
    }

    func fetchProducts(page: URL?) async throws -> ROHPage<ROHProduct> {
        let response: ROHPaginatedResponse<ROHProduct> = try await fetch(url: page, path: "/store/_api/products/")
        return ROHPage(items: response.results, nextPage: response.next)
    }

    private func fetch<Response: Decodable>(
        url: URL? = nil,
        path: String,
        queryItems: [URLQueryItem] = []
    ) async throws -> Response {
        let requestURL: URL
        if let url {
            requestURL = url
        } else {
            guard var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
                throw ROHAPIError.invalidRequest
            }
            components.queryItems = queryItems.isEmpty ? nil : queryItems
            guard let url = components.url else { throw ROHAPIError.invalidRequest }
            requestURL = url
        }

        var request = URLRequest(url: requestURL, timeoutInterval: 30)
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw ROHAPIError.transport(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ROHAPIError.invalidResponse
        }
        rohAPILogger.notice("GET \(requestURL.path, privacy: .public) -> \(httpResponse.statusCode)")
        guard (200...299).contains(httpResponse.statusCode) else {
            throw ROHAPIError.http(statusCode: httpResponse.statusCode, url: requestURL)
        }

        do {
            return try JSONDecoder.roh.decode(Response.self, from: data)
        } catch {
            throw ROHAPIError.decoding(error)
        }
    }
}
