package com.fiveq.ffci.data.cache

import android.util.Log
import com.fiveq.ffci.data.api.SearchResult
import java.util.concurrent.ConcurrentHashMap
import kotlin.time.Duration
import kotlin.time.Duration.Companion.minutes

/**
 * In-memory LRU cache for search results with time-based invalidation.
 * 
 * Features:
 * - 2 minute TTL (shorter than page cache since search results can change)
 * - Maximum 20 cached queries with LRU eviction
 * - Query normalization (lowercase + trim) for cache key lookup
 * - Thread-safe for concurrent access
 */
object SearchCache {
    private const val TAG = "SearchCache"
    
    // Cache TTL: 2 minutes (shorter than page cache since search results can change)
    private val CACHE_TTL: Duration = 2.minutes
    
    // Maximum number of cached queries to limit memory usage
    private const val MAX_CACHE_SIZE = 20
    
    data class CachedSearch(
        val data: List<SearchResult>,
        val timestamp: Long = System.currentTimeMillis()
    ) {
        fun isExpired(): Boolean {
            val age = System.currentTimeMillis() - timestamp
            return age > CACHE_TTL.inWholeMilliseconds
        }
    }
    
    private val cache = ConcurrentHashMap<String, CachedSearch>()
    private val accessOrder = mutableListOf<String>()
    
    /**
     * Normalize search query for cache key (lowercase, trim)
     */
    private fun normalizeQuery(query: String): String {
        return query.trim().lowercase()
    }
    
    /**
     * Evict oldest cache entries if we exceed MAX_CACHE_SIZE
     */
    private fun evictOldestIfNeeded() {
        synchronized(accessOrder) {
            if (cache.size < MAX_CACHE_SIZE) {
                return
            }
            
            // Find oldest entry by timestamp
            var oldestKey: String? = null
            var oldestTimestamp = Long.MAX_VALUE
            
            cache.forEach { (key, cached) ->
                if (cached.timestamp < oldestTimestamp) {
                    oldestTimestamp = cached.timestamp
                    oldestKey = key
                }
            }
            
            if (oldestKey != null) {
                cache.remove(oldestKey)
                accessOrder.remove(oldestKey)
                Log.d(TAG, "Evicted oldest cache entry: $oldestKey")
            }
        }
    }
    
    /**
     * Get cached search results if available and not stale.
     * Updates access order for LRU eviction.
     */
    fun get(query: String): List<SearchResult>? {
        synchronized(accessOrder) {
            val normalizedQuery = normalizeQuery(query)
            val cached = cache[normalizedQuery]
            
            if (cached == null) {
                Log.d(TAG, "No cache entry for query: \"$normalizedQuery\"")
                return null
            }
            
            if (cached.isExpired()) {
                val age = System.currentTimeMillis() - cached.timestamp
                Log.d(TAG, "Cache entry for query \"$normalizedQuery\" is stale (age: ${age}ms, TTL: ${CACHE_TTL.inWholeMilliseconds}ms)")
                cache.remove(normalizedQuery)
                accessOrder.remove(normalizedQuery)
                return null
            }
            
            // Update access order (move to end for LRU)
            accessOrder.remove(normalizedQuery)
            accessOrder.add(normalizedQuery)
            
            val age = System.currentTimeMillis() - cached.timestamp
            Log.d(TAG, "Cache hit for query \"$normalizedQuery\" (age: ${age}ms, ${cached.data.size} results)")
            return cached.data
        }
    }
    
    /**
     * Check if cached search exists (even if stale)
     */
    fun hasCache(query: String): Boolean {
        val normalizedQuery = normalizeQuery(query)
        return cache.containsKey(normalizedQuery)
    }
    
    /**
     * Store search results in cache.
     * Evicts oldest entries if cache exceeds MAX_CACHE_SIZE.
     */
    fun put(query: String, data: List<SearchResult>) {
        synchronized(accessOrder) {
            val normalizedQuery = normalizeQuery(query)
            val timestamp = System.currentTimeMillis()
            
            // Evict oldest entries if needed before adding new one
            evictOldestIfNeeded()
            
            // Remove if already exists to update order
            accessOrder.remove(normalizedQuery)
            
            // Add to end (most recently used)
            accessOrder.add(normalizedQuery)
            cache[normalizedQuery] = CachedSearch(data, timestamp)
            
            Log.d(TAG, "Cached search results for query \"$normalizedQuery\" at $timestamp (${data.size} results, cache size: ${cache.size})")
        }
    }
    
    /**
     * Clear cache for a specific query
     */
    fun clear(query: String) {
        synchronized(accessOrder) {
            val normalizedQuery = normalizeQuery(query)
            cache.remove(normalizedQuery)
            accessOrder.remove(normalizedQuery)
            Log.d(TAG, "Cleared cache for query: \"$normalizedQuery\"")
        }
    }
    
    /**
     * Clear all cached searches
     */
    fun clearAll() {
        synchronized(accessOrder) {
            cache.clear()
            accessOrder.clear()
            Log.d(TAG, "Cleared all cached searches")
        }
    }
    
    /**
     * Get current cache size
     */
    fun size(): Int = cache.size
}
