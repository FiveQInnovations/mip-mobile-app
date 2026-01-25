//
//  PageCache.swift
//  FFCI
//
//  In-memory cache for page data with TTL and LRU eviction
//

import Foundation
import os.log

private let logger = Logger(subsystem: "com.fiveq.ffci", category: "PageCache")

actor PageCache {
    nonisolated static let defaultTTL: TimeInterval = 5 * 60
    static let shared = PageCache()
    
    private let maxCacheSize = 50
    
    private struct CachedPage {
        let data: PageData
        let timestamp: TimeInterval
    }
    
    private var cache: [String: CachedPage] = [:]
    private var accessOrder: [String] = []
    
    func get(_ uuid: String, ttl: TimeInterval = PageCache.defaultTTL) -> PageData? {
        guard let entry = cache[uuid] else { return nil }
        if isExpired(entry, ttl: ttl) {
            remove(uuid)
            return nil
        }
        
        touch(uuid)
        return entry.data
    }
    
    func getAnyCache(_ uuid: String) -> PageData? {
        guard let entry = cache[uuid] else { return nil }
        touch(uuid)
        return entry.data
    }
    
    func hasCache(_ uuid: String) -> Bool {
        cache[uuid] != nil
    }
    
    func hasValid(_ uuid: String, ttl: TimeInterval = PageCache.defaultTTL) -> Bool {
        guard let entry = cache[uuid] else { return false }
        if isExpired(entry, ttl: ttl) {
            remove(uuid)
            return false
        }
        return true
    }
    
    func isExpired(_ uuid: String, ttl: TimeInterval = PageCache.defaultTTL) -> Bool {
        guard let entry = cache[uuid] else { return true }
        return isExpired(entry, ttl: ttl)
    }
    
    func put(_ uuid: String, data: PageData) {
        purgeExpired()
        cache[uuid] = CachedPage(data: data, timestamp: Date().timeIntervalSince1970)
        touch(uuid)
        evictIfNeeded()
    }
    
    func remove(_ uuid: String) {
        cache.removeValue(forKey: uuid)
        accessOrder.removeAll { $0 == uuid }
    }
    
    func clear() {
        cache.removeAll()
        accessOrder.removeAll()
    }
    
    func size() -> Int {
        cache.count
    }
    
    private func isExpired(_ entry: CachedPage, ttl: TimeInterval) -> Bool {
        let age = Date().timeIntervalSince1970 - entry.timestamp
        return age > ttl
    }
    
    private func touch(_ uuid: String) {
        accessOrder.removeAll { $0 == uuid }
        accessOrder.append(uuid)
    }
    
    private func evictIfNeeded() {
        while cache.count > maxCacheSize, let oldest = accessOrder.first {
            remove(oldest)
            logger.notice("Evicted cached page: \(oldest, privacy: .public)")
        }
    }
    
    private func purgeExpired() {
        let expiredKeys = accessOrder.filter { uuid in
            guard let entry = cache[uuid] else { return true }
            return isExpired(entry, ttl: PageCache.defaultTTL)
        }
        
        for uuid in expiredKeys {
            remove(uuid)
        }
    }
}
