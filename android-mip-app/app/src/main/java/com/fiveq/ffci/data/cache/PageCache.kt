package com.fiveq.ffci.data.cache

import android.util.Log
import com.fiveq.ffci.data.api.PageData
import java.util.concurrent.ConcurrentHashMap
import kotlin.time.Duration
import kotlin.time.Duration.Companion.minutes

/**
 * In-memory LRU cache for page data with time-based invalidation.
 * 
 * Features:
 * - Shows cached content immediately
 * - Background refresh updates cache silently
 * - Time-based cache invalidation (default: 5 minutes)
 * - Thread-safe for concurrent access
 */
object PageCache {
    private const val TAG = "PageCache"
    
    // Default cache TTL: 5 minutes
    private val DEFAULT_TTL: Duration = 5.minutes
    
    // Maximum cache size (LRU eviction)
    private const val MAX_CACHE_SIZE = 50
    
    data class CachedPage(
        val data: PageData,
        val timestamp: Long = System.currentTimeMillis()
    ) {
        fun isExpired(ttl: Duration): Boolean {
            val age = System.currentTimeMillis() - timestamp
            return age > ttl.inWholeMilliseconds
        }
    }
    
    private val cache = ConcurrentHashMap<String, CachedPage>()
    private val accessOrder = mutableListOf<String>()
    
    /**
     * Get cached page data if available and not expired.
     * Updates access order for LRU eviction.
     */
    fun get(uuid: String, ttl: Duration = DEFAULT_TTL): PageData? {
        synchronized(accessOrder) {
            val cached = cache[uuid]
            
            if (cached == null) {
                Log.d(TAG, "Cache miss: $uuid")
                return null
            }
            
            if (cached.isExpired(ttl)) {
                Log.d(TAG, "Cache expired: $uuid (age: ${System.currentTimeMillis() - cached.timestamp}ms)")
                cache.remove(uuid)
                accessOrder.remove(uuid)
                return null
            }
            
            // Update access order (move to end for LRU)
            accessOrder.remove(uuid)
            accessOrder.add(uuid)
            
            Log.d(TAG, "Cache hit: $uuid (age: ${System.currentTimeMillis() - cached.timestamp}ms)")
            return cached.data
        }
    }
    
    /**
     * Store page data in cache.
     * Evicts oldest entries if cache exceeds MAX_CACHE_SIZE.
     */
    fun put(uuid: String, data: PageData) {
        synchronized(accessOrder) {
            // Remove if already exists to update order
            accessOrder.remove(uuid)
            
            // Add to end (most recently used)
            accessOrder.add(uuid)
            cache[uuid] = CachedPage(data)
            
            // Evict oldest entries if cache is too large
            while (cache.size > MAX_CACHE_SIZE && accessOrder.isNotEmpty()) {
                val oldest = accessOrder.removeFirst()
                cache.remove(oldest)
                Log.d(TAG, "Evicted oldest entry: $oldest")
            }
            
            Log.d(TAG, "Cached page: $uuid (cache size: ${cache.size})")
        }
    }
    
    /**
     * Check if cache contains ANY entry for the given UUID (even if stale).
     * Use this to decide whether to show loading spinner.
     * (Matches RN hasCachedPage pattern)
     */
    fun hasCache(uuid: String): Boolean {
        return cache.containsKey(uuid)
    }
    
    /**
     * Check if cache contains a valid (non-expired) entry for the given UUID.
     */
    fun hasValid(uuid: String, ttl: Duration = DEFAULT_TTL): Boolean {
        return get(uuid, ttl) != null
    }
    
    /**
     * Get cached page data even if stale (stale-while-revalidate pattern).
     * Use this when you want to show ANY cached data immediately.
     */
    fun getAnyCache(uuid: String): PageData? {
        synchronized(accessOrder) {
            val cached = cache[uuid]
            if (cached == null) {
                Log.d(TAG, "No cache entry: $uuid")
                return null
            }
            
            // Update access order (move to end for LRU)
            accessOrder.remove(uuid)
            accessOrder.add(uuid)
            
            val age = System.currentTimeMillis() - cached.timestamp
            val isStale = cached.isExpired(DEFAULT_TTL)
            Log.d(TAG, "Returning ${if (isStale) "STALE" else "fresh"} cache: $uuid (age: ${age}ms)")
            return cached.data
        }
    }
    
    /**
     * Clear all cached data.
     */
    fun clear() {
        synchronized(accessOrder) {
            cache.clear()
            accessOrder.clear()
            Log.d(TAG, "Cache cleared")
        }
    }
    
    /**
     * Remove a specific entry from cache.
     */
    fun remove(uuid: String) {
        synchronized(accessOrder) {
            cache.remove(uuid)
            accessOrder.remove(uuid)
            Log.d(TAG, "Removed from cache: $uuid")
        }
    }
    
    /**
     * Get current cache size.
     */
    fun size(): Int = cache.size
}
