import { SearchResult } from './api';

interface CachedSearch {
  data: SearchResult[];
  timestamp: number;
}

// In-memory cache for search results
const cache = new Map<string, CachedSearch>();

// Cache TTL: 2 minutes (120000ms) - shorter than page cache since search results can change
const CACHE_TTL = 2 * 60 * 1000;

// Maximum number of cached queries to limit memory usage
const MAX_CACHE_SIZE = 20;

/**
 * Normalize search query for cache key (lowercase, trim)
 */
function normalizeQuery(query: string): string {
  return query.trim().toLowerCase();
}

/**
 * Evict oldest cache entries if we exceed MAX_CACHE_SIZE
 */
function evictOldestIfNeeded(): void {
  if (cache.size < MAX_CACHE_SIZE) {
    return;
  }

  // Find oldest entry by timestamp
  let oldestKey: string | null = null;
  let oldestTimestamp = Infinity;

  cache.forEach((cached, key) => {
    if (cached.timestamp < oldestTimestamp) {
      oldestTimestamp = cached.timestamp;
      oldestKey = key;
    }
  });

  if (oldestKey) {
    cache.delete(oldestKey);
    console.log(`[SearchCache] Evicted oldest cache entry: ${oldestKey}`);
  }
}

/**
 * Get cached search results if available and not stale
 */
export function getCachedSearch(query: string): SearchResult[] | null {
  const normalizedQuery = normalizeQuery(query);
  const cached = cache.get(normalizedQuery);
  
  if (!cached) {
    console.log(`[SearchCache] No cache entry for query: "${normalizedQuery}"`);
    return null;
  }

  const age = Date.now() - cached.timestamp;
  if (age > CACHE_TTL) {
    console.log(`[SearchCache] Cache entry for query "${normalizedQuery}" is stale (age: ${age}ms, TTL: ${CACHE_TTL}ms)`);
    // Delete stale cache entries
    cache.delete(normalizedQuery);
    return null;
  }

  console.log(`[SearchCache] Cache hit for query "${normalizedQuery}" (age: ${age}ms, ${cached.data.length} results)`);
  return cached.data;
}

/**
 * Check if cached search exists (even if stale)
 */
export function hasCachedSearch(query: string): boolean {
  const normalizedQuery = normalizeQuery(query);
  return cache.has(normalizedQuery);
}

/**
 * Store search results in cache
 */
export function setCachedSearch(query: string, data: SearchResult[]): void {
  const normalizedQuery = normalizeQuery(query);
  const timestamp = Date.now();
  
  // Evict oldest entries if needed before adding new one
  evictOldestIfNeeded();
  
  cache.set(normalizedQuery, { data, timestamp });
  console.log(`[SearchCache] Cached search results for query "${normalizedQuery}" at ${timestamp} (${data.length} results)`);
}

/**
 * Check if cached search data is stale (older than TTL)
 */
export function isCacheStale(query: string): boolean {
  const normalizedQuery = normalizeQuery(query);
  const cached = cache.get(normalizedQuery);
  
  if (!cached) {
    return true;
  }
  
  const age = Date.now() - cached.timestamp;
  return age > CACHE_TTL;
}

/**
 * Clear cache for a specific query
 */
export function clearCachedSearch(query: string): void {
  const normalizedQuery = normalizeQuery(query);
  cache.delete(normalizedQuery);
  console.log(`[SearchCache] Cleared cache for query: "${normalizedQuery}"`);
}

/**
 * Clear all cached searches
 */
export function clearAllCache(): void {
  cache.clear();
  console.log('[SearchCache] Cleared all cached searches');
}

/**
 * Get cache status for all cached searches
 * Returns an object with query as key and cache info as value
 */
export function getCacheStatus(): Record<string, { age: number; stale: boolean; resultCount: number }> {
  const status: Record<string, { age: number; stale: boolean; resultCount: number }> = {};
  const now = Date.now();
  
  cache.forEach((cached, query) => {
    const age = now - cached.timestamp;
    const stale = age > CACHE_TTL;
    status[query] = {
      age,
      stale,
      resultCount: cached.data.length,
    };
  });
  
  return status;
}

/**
 * Log cache status to console (useful for debugging)
 */
export function logCacheStatus(): void {
  const status = getCacheStatus();
  const entries = Object.keys(status);
  
  if (entries.length === 0) {
    console.log('[SearchCache] Cache is empty');
    return;
  }
  
  console.log(`[SearchCache] Cache status (${entries.length} entries):`);
  entries.forEach(query => {
    const info = status[query];
    const ageSeconds = Math.round(info.age / 1000);
    const staleText = info.stale ? 'STALE' : 'FRESH';
    console.log(`  - "${query}": ${info.resultCount} results (age: ${ageSeconds}s, ${staleText})`);
  });
}
