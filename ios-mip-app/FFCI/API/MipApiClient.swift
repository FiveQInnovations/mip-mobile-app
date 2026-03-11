//
//  MipApiClient.swift
//  FFCI
//
//  Firefighters for Christ International - API Client
//

import Foundation
import os.log

private let logger = Logger(subsystem: "com.fiveq.ffci", category: "API")

enum ApiError: Error {
    case invalidResponse
    case httpError(statusCode: Int, url: String)
    case decodingError(Error)
    case networkError(Error)
}

class MipApiClient {
    static let shared = MipApiClient()
    
    private let baseURL = "https://ffci.fiveq.dev"
    private let apiKey = "777359235aecc10fdfb144041dfdacfc80ca0751c7bed7b14c96f935456fc4ce"
    private let username = "fiveq"
    private let password = "demo"
    
    private let session: URLSession
    private var resolvedPathCache: [String: String] = [:]
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: configuration)
    }
    
    private func createRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        
        // Basic Auth
        let credentials = "\(username):\(password)"
        if let credentialsData = credentials.data(using: .utf8) {
            let base64Credentials = credentialsData.base64EncodedString()
            request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        }
        
        // API Key
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return request
    }
    
    func getSiteData() async throws -> SiteData {
        let url = URL(string: "\(baseURL)/mobile-api")!
        logger.notice("Fetching site data from: \(url.absoluteString)")
        
        let request = createRequest(url: url)
        let startTime = Date()
        
        do {
            let (data, response) = try await session.data(for: request)
            let duration = Date().timeIntervalSince(startTime)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ApiError.invalidResponse
            }
            
            logger.notice("Response: \(httpResponse.statusCode) in \(String(format: "%.0f", duration * 1000))ms")
            
            guard httpResponse.statusCode == 200 else {
                throw ApiError.httpError(statusCode: httpResponse.statusCode, url: url.absoluteString)
            }
            
            do {
                let decoder = JSONDecoder()
                let siteData = try decoder.decode(SiteData.self, from: data)
                logger.notice("Site data loaded: \(siteData.menu.count) menu items")
                return siteData
            } catch {
                logger.error("Failed to decode site data: \(error.localizedDescription)")
                throw ApiError.decodingError(error)
            }
        } catch let error as ApiError {
            throw error
        } catch {
            logger.error("Network error: \(error.localizedDescription)")
            throw ApiError.networkError(error)
        }
    }
    
    func getPage(uuid: String) async throws -> PageData {
        let url = URL(string: "\(baseURL)/mobile-api/page/\(uuid)")!
        logger.notice("Fetching page: \(uuid)")
        
        let request = createRequest(url: url)
        let startTime = Date()
        
        do {
            let (data, response) = try await session.data(for: request)
            let duration = Date().timeIntervalSince(startTime)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ApiError.invalidResponse
            }
            
            logger.notice("Response: \(httpResponse.statusCode) in \(String(format: "%.0f", duration * 1000))ms")
            
            guard httpResponse.statusCode == 200 else {
                throw ApiError.httpError(statusCode: httpResponse.statusCode, url: url.absoluteString)
            }
            
            do {
                let decoder = JSONDecoder()
                let pageData = try decoder.decode(PageData.self, from: data)
                logger.notice("Page loaded: \(pageData.title), type: \(pageData.effectivePageType)")
                return pageData
            } catch {
                logger.error("Failed to decode page data: \(error.localizedDescription)")
                throw ApiError.decodingError(error)
            }
        } catch let error as ApiError {
            throw error
        } catch {
            logger.error("Network error: \(error.localizedDescription)")
            throw ApiError.networkError(error)
        }
    }
    
    func getPageWithCache(
        uuid: String,
        ttl: TimeInterval = PageCache.defaultTTL
    ) async throws -> (data: PageData, fromCache: Bool, isStale: Bool) {
        if let cached = await PageCache.shared.getAnyCache(uuid) {
            let isStale = await PageCache.shared.isExpired(uuid, ttl: ttl)
            logger.notice("Returning cached page: \(uuid, privacy: .public)")
            return (data: cached, fromCache: true, isStale: isStale)
        }
        
        let fresh = try await getPage(uuid: uuid)
        await PageCache.shared.put(uuid, data: fresh)
        return (data: fresh, fromCache: false, isStale: false)
    }
    
    func searchSite(query: String) async throws -> [SearchResult] {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw ApiError.networkError(NSError(domain: "Invalid query", code: -1))
        }
        
        let url = URL(string: "\(baseURL)/mobile-api/search?q=\(encodedQuery)")!
        logger.notice("Searching: \(query)")
        
        let request = createRequest(url: url)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ApiError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw ApiError.httpError(statusCode: httpResponse.statusCode, url: url.absoluteString)
            }
            
            do {
                let decoder = JSONDecoder()
                let results = try decoder.decode([SearchResult].self, from: data)
                logger.notice("Search returned \(results.count) results")
                return results
            } catch {
                logger.error("Failed to decode search results: \(error.localizedDescription)")
                throw ApiError.decodingError(error)
            }
        } catch let error as ApiError {
            throw error
        } catch {
            logger.error("Network error: \(error.localizedDescription)")
            throw ApiError.networkError(error)
        }
    }
    
    // Issue 2: Internal Non-UUID Links Resolution
    func resolvePageUuidByUrl(_ url: URL) async -> String? {
        guard let normalizedPath = normalizePath(url.absoluteString) else {
            return nil
        }

        if let cached = resolvedPathCache[normalizedPath] {
            return cached
        }

        let candidateQueries = buildResolutionQueries(normalizedPath)
        if candidateQueries.isEmpty {
            return nil
        }

        logger.notice("Resolving UUID for path: \(normalizedPath, privacy: .public)")

        for query in candidateQueries {
            guard let results = try? await searchSite(query: query) else { continue }
            if let exactMatch = results.first(where: { normalizePath($0.url) == normalizedPath }) {
                resolvedPathCache[normalizedPath] = exactMatch.uuid
                return exactMatch.uuid
            }
        }

        return nil
    }
    
    private func normalizePath(_ urlOrPath: String) -> String? {
        let rawPath: String
        if let parsedPath = URLComponents(string: urlOrPath)?.path, !parsedPath.isEmpty {
            rawPath = parsedPath
        } else if urlOrPath.hasPrefix("/") {
            rawPath = urlOrPath
        } else {
            return nil
        }

        let trimmed = rawPath.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty || trimmed == "/" {
            return nil
        }

        var normalized = trimmed.lowercased()
        while normalized.hasSuffix("/") && normalized.count > 1 {
            normalized.removeLast()
        }

        if !normalized.hasPrefix("/") {
            normalized = "/" + normalized
        }

        return normalized
    }

    private func buildResolutionQueries(_ normalizedPath: String) -> [String] {
        let segments = normalizedPath
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            .split(separator: "/")
            .map(String.init)
            .filter { !$0.isEmpty }

        if segments.isEmpty {
            return []
        }

        var queries: [String] = []

        let lastSegment = segments.last?
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "_", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if lastSegment.count >= 3 {
            queries.append(lastSegment)
        }

        let joined = segments
            .joined(separator: " ")
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "_", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if joined.count >= 3, !queries.contains(joined) {
            queries.append(joined)
        }

        return queries
    }
}
