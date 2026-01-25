//
//  SearchCache.swift
//  FFCI
//
//  In-memory cache for search results with TTL and LRU eviction
//

import Foundation
import os.log

private let logger = Logger(subsystem: "com.fiveq.ffci", category: "SearchCache")

actor SearchCache {
    static let shared = SearchCache()
    
    private let cacheTTL: TimeInterval = 120
    private let maxCacheSize = 20
    
    private struct CacheEntry {
        let data: [SearchResult]
        let timestamp: TimeInterval
    }
    
    private var cache: [String: CacheEntry] = [:]
    private var accessOrder: [String] = []
    
    func get(query: String) -> [SearchResult]? {
        let normalized = normalize(query)
        guard !normalized.isEmpty else { return nil }
        
        guard let entry = cache[normalized] else { return nil }
        
        let now = Date().timeIntervalSince1970
        if now - entry.timestamp > cacheTTL {
            remove(normalized)
            logger.notice("Search cache expired for query: \(normalized, privacy: .public)")
            return nil
        }
        
        touch(normalized)
        return entry.data
    }
    
    func set(query: String, results: [SearchResult]) {
        let normalized = normalize(query)
        guard !normalized.isEmpty else { return }
        
        purgeExpired()
        cache[normalized] = CacheEntry(data: results, timestamp: Date().timeIntervalSince1970)
        touch(normalized)
        evictIfNeeded()
    }
    
    func clear(query: String) {
        let normalized = normalize(query)
        guard !normalized.isEmpty else { return }
        remove(normalized)
    }
    
    func clearAll() {
        cache.removeAll()
        accessOrder.removeAll()
    }
    
    private func normalize(_ query: String) -> String {
        query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
    
    private func touch(_ key: String) {
        accessOrder.removeAll { $0 == key }
        accessOrder.append(key)
    }
    
    private func evictIfNeeded() {
        while cache.count > maxCacheSize, let oldestKey = accessOrder.first {
            remove(oldestKey)
        }
    }
    
    private func purgeExpired() {
        let now = Date().timeIntervalSince1970
        let expiredKeys = accessOrder.filter { key in
            guard let entry = cache[key] else { return true }
            return now - entry.timestamp > cacheTTL
        }
        
        for key in expiredKeys {
            remove(key)
        }
    }
    
    private func remove(_ key: String) {
        cache.removeValue(forKey: key)
        accessOrder.removeAll { $0 == key }
    }
}
