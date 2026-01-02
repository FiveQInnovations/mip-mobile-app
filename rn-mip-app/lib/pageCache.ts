import { PageData } from './api';

interface CachedPage {
  data: PageData;
  timestamp: number;
}

// In-memory cache for page data
const cache = new Map<string, CachedPage>();

// Cache TTL: 5 minutes (300000ms)
const CACHE_TTL = 5 * 60 * 1000;

/**
 * Get cached page data if available and not stale
 */
export function getCachedPage(uuid: string): PageData | null {
  const cached = cache.get(uuid);
  if (!cached) {
    console.log(`[PageCache] No cache entry for UUID: ${uuid}`);
    return null;
  }

  const age = Date.now() - cached.timestamp;
  if (age > CACHE_TTL) {
    console.log(`[PageCache] Cache entry for UUID: ${uuid} is stale (age: ${age}ms, TTL: ${CACHE_TTL}ms)`);
    // Don't delete stale cache - we'll use it for stale-while-revalidate
    return cached.data;
  }

  console.log(`[PageCache] Cache hit for UUID: ${uuid} (age: ${age}ms)`);
  return cached.data;
}

/**
 * Check if cached page exists (even if stale)
 */
export function hasCachedPage(uuid: string): boolean {
  return cache.has(uuid);
}

/**
 * Store page data in cache
 */
export function setCachedPage(uuid: string, data: PageData): void {
  const timestamp = Date.now();
  cache.set(uuid, { data, timestamp });
  console.log(`[PageCache] Cached page data for UUID: ${uuid} at ${timestamp}`);
}

/**
 * Check if cached data is stale (older than TTL)
 */
export function isCacheStale(uuid: string): boolean {
  const cached = cache.get(uuid);
  if (!cached) {
    return true;
  }
  const age = Date.now() - cached.timestamp;
  return age > CACHE_TTL;
}

/**
 * Clear cache for a specific page
 */
export function clearCachedPage(uuid: string): void {
  cache.delete(uuid);
  console.log(`[PageCache] Cleared cache for UUID: ${uuid}`);
}

/**
 * Clear all cached pages
 */
export function clearAllCache(): void {
  cache.clear();
  console.log('[PageCache] Cleared all cached pages');
}

