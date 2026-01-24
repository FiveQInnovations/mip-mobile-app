---
status: backlog
area: ios-mip-app
phase: core
created: 2026-01-24
---

# iOS Page Caching

## Context

The iOS app should cache page data to improve performance and provide offline access. Currently, every page navigation triggers a new API call, which is slow and uses unnecessary bandwidth.

## Problem

Page data is fetched fresh on every navigation, causing:
- Slow page loads
- Unnecessary network requests
- Poor offline experience
- Increased server load

## Goals

1. Implement in-memory page cache with TTL
2. Show cached content immediately while refreshing in background
3. Cache invalidation based on time (5 minute default TTL)
4. LRU eviction when cache reaches size limit
5. Thread-safe concurrent access

## Acceptance Criteria

- Cached pages display immediately on subsequent visits
- Background refresh updates cache silently
- Cache expires after 5 minutes (configurable)
- Cache evicts oldest entries when full (max 50 pages)
- Cache is thread-safe for concurrent access
- Cache works across app navigation
- Cache persists across app restarts (optional enhancement)

## Android Reference Implementation

File: `android-mip-app/app/src/main/java/com/fiveq/ffci/data/cache/PageCache.kt`

**Key features:**
- In-memory ConcurrentHashMap for thread safety
- Time-based cache invalidation (5 minute default TTL)
- LRU eviction (max 50 pages)
- Shows cached content immediately
- Background refresh updates cache silently
- Thread-safe synchronized access order tracking

**Cache Strategy:**
1. Check cache first - return immediately if valid
2. If cache miss or expired, fetch from API
3. Update cache with new data
4. Background refresh for stale-but-valid cache entries

## iOS Implementation Notes

### Technology Stack
- **Dictionary** or **NSCache** for in-memory storage
- **DispatchQueue** or **actor** for thread safety
- **Date** for timestamp tracking
- **Timer** or background task for refresh

### Files to Create/Modify

1. **ios-mip-app/FFCI/Data/PageCache.swift** - New cache manager
   - Cache storage (Dictionary or NSCache)
   - TTL management
   - LRU eviction logic
   - Thread-safe access (actor or DispatchQueue)

2. **ios-mip-app/FFCI/API/MipApiClient.swift** - Modify
   - Integrate PageCache in `getPage(uuid:)` method
   - Check cache before API call
   - Update cache after successful API response

3. **ios-mip-app/FFCI/Views/TabPageView.swift** - Modify
   - Use cached data for immediate display
   - Trigger background refresh if cache is stale

### Cache Structure

```swift
struct CachedPage {
    let data: PageData
    let timestamp: Date
    
    func isExpired(ttl: TimeInterval) -> Bool {
        Date().timeIntervalSince(timestamp) > ttl
    }
}
```

### Thread Safety Options

**Option A: Actor (Swift 5.5+)**
```swift
actor PageCache {
    private var cache: [String: CachedPage] = [:]
    // Methods are automatically isolated
}
```

**Option B: DispatchQueue**
```swift
class PageCache {
    private let queue = DispatchQueue(label: "PageCache", attributes: .concurrent)
    private var cache: [String: CachedPage] = [:]
    // Use queue.sync/async for access
}
```

### Cache Strategy

1. **Cache Hit (Valid)**: Return immediately, optionally refresh in background
2. **Cache Hit (Expired)**: Return stale data immediately, refresh in foreground
3. **Cache Miss**: Fetch from API, update cache, return data

### Configuration

- Default TTL: 5 minutes
- Max cache size: 50 pages
- Background refresh: Enabled for stale-but-valid entries

## Related Files

- `android-mip-app/app/src/main/java/com/fiveq/ffci/data/cache/PageCache.kt`
- `ios-mip-app/FFCI/API/MipApiClient.swift`
- `ios-mip-app/FFCI/Views/TabPageView.swift`

---

## Research Findings (Scouted)

### React Native Reference

**File:** `rn-mip-app/lib/pageCache.ts`

**Caching Strategy:**
- **Simple in-memory Map** - `Map<string, CachedPage>` for cache storage
- **5-minute TTL** - `CACHE_TTL = 5 * 60 * 1000` milliseconds
- **No explicit LRU eviction** - relies on JavaScript GC and memory pressure
- **Stale-while-revalidate pattern** - returns stale cache but marks it as such

**Key Functions:**
1. `getCachedPage(uuid)` - Returns cached data if available, logs staleness
2. `hasCachedPage(uuid)` - Checks if cache entry exists (even if stale)
3. `setCachedPage(uuid, data)` - Stores page data with timestamp
4. `isCacheStale(uuid)` - Checks if age > TTL
5. `clearCachedPage(uuid)` - Removes specific entry
6. `clearAllCache()` - Clears entire cache

**API Integration Pattern (rn-mip-app/lib/api.ts:194-221):**
```typescript
export async function getPageWithCache(uuid: string): Promise<{ 
  data: PageData; 
  fromCache: boolean;
  refreshPromise?: Promise<PageData>;
}>
```

- Check cache first (line 199)
- If fresh cache exists: return immediately + background refresh (lines 204-207)
- If stale cache exists: return immediately + background refresh (lines 211-214)
- If no cache: fetch fresh data (lines 218-220)

**UI Usage Pattern (rn-mip-app/components/TabScreen.tsx:55-116):**
1. **Check cache synchronously** before async work (lines 59-60: `hasCachedPage()`)
2. **Set loading state conditionally** - only show spinner if no cache (lines 63-71)
3. **Call `getPageWithCache()`** which returns instantly if cached (line 75)
4. **Update UI immediately** with cached data (line 81)
5. **Set refreshing state** for background updates (line 89)
6. **Handle refresh promise** to update UI when fresh data arrives (lines 92-105)

**Key Pattern:** Cache check happens in `useState` initialization, NOT in effect - provides instant display.

### Android Implementation Analysis

**File:** `android-mip-app/app/src/main/java/com/fiveq/ffci/data/cache/PageCache.kt`

**Architecture:**
- **Singleton object** - `object PageCache` (line 18)
- **Thread-safe storage** - `ConcurrentHashMap<String, CachedPage>` (line 37)
- **LRU tracking** - `mutableListOf<String>` for access order (line 38)
- **Synchronized access** - `synchronized(accessOrder)` blocks protect LRU list (lines 45, 74, 98, 114, 136, 146)

**Data Structure (lines 27-35):**
```kotlin
data class CachedPage(
    val data: PageData,
    val timestamp: Long = System.currentTimeMillis()
) {
    fun isExpired(ttl: Duration): Boolean {
        val age = System.currentTimeMillis() - timestamp
        return age > ttl.inWholeMilliseconds
    }
}
```

**Constants:**
- `DEFAULT_TTL = 5.minutes` (line 22) - Kotlin Duration type
- `MAX_CACHE_SIZE = 50` (line 25) - LRU eviction threshold

**Core Methods:**

1. **`get(uuid, ttl)` (lines 44-67):**
   - Returns `PageData?` (null if expired or missing)
   - Automatically removes expired entries
   - Updates LRU order (moves to end)
   - Thread-safe via `synchronized(accessOrder)`

2. **`put(uuid, data)` (lines 73-91):**
   - Stores new entry with current timestamp
   - Updates LRU order (moves to end)
   - Evicts oldest entries when size > MAX_CACHE_SIZE
   - Thread-safe via `synchronized(accessOrder)`

3. **`hasCache(uuid)` (lines 98-100):**
   - Checks if ANY entry exists (even stale)
   - Used to decide whether to show loading spinner

4. **`hasValid(uuid, ttl)` (lines 105-107):**
   - Checks if valid (non-expired) entry exists
   - Wraps `get()` with null check

5. **`getAnyCache(uuid)` (lines 113-130):**
   - Returns cached data even if expired (stale-while-revalidate)
   - Updates LRU order
   - Logs staleness status
   - Critical for instant display pattern

**UI Integration Pattern (android-mip-app/app/src/main/java/com/fiveq/ffci/ui/screens/TabScreen.kt:59-115):**

1. **Synchronous cache check** in `remember(currentUuid)` (lines 61-67):
   ```kotlin
   val initialCachedData = remember(currentUuid) {
       if (PageCache.hasCache(currentUuid)) {
           PageCache.getAnyCache(currentUuid)
       } else {
           null
       }
   }
   ```

2. **Initialize state with cached data** (line 69):
   ```kotlin
   var pageData by remember(currentUuid) { mutableStateOf<PageData?>(initialCachedData) }
   ```

3. **Conditional loading state** (lines 70-72):
   ```kotlin
   var isLoading by remember(currentUuid) { 
       mutableStateOf(initialCachedData == null) // Only show loading if no cache
   }
   ```

4. **Background refresh in LaunchedEffect** (lines 79-115):
   - If cache exists: silent background refresh (lines 82-85)
   - If no cache: blocking fetch with loading indicator (lines 86-88)
   - Fetch fresh data from API (lines 92-93)
   - Update cache (line 97)
   - Update UI with fresh data (line 100)
   - Handle errors gracefully (keep cached data if refresh fails) (lines 102-110)

**Key Differences from React Native:**
- ✅ **LRU eviction** - Android explicitly manages cache size (RN doesn't)
- ✅ **Kotlin Duration types** - more type-safe than milliseconds
- ✅ **Explicit thread safety** - ConcurrentHashMap + synchronized blocks
- ✅ **Separate methods** - `hasCache()` vs `hasValid()` for different use cases

### Current iOS Implementation

**File:** `ios-mip-app/FFCI/Views/TabPageView.swift`

**Current Pattern (lines 102-122):**
```swift
private func loadPage(uuid: String) {
    isLoading = true  // Always shows loading spinner
    error = nil
    
    Task {
        do {
            let data = try await MipApiClient.shared.getPage(uuid: uuid)
            await MainActor.run {
                self.pageData = data
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}
```

**Problems:**
- ❌ **No caching** - every navigation triggers fresh API call
- ❌ **Always shows loading spinner** - even for revisited pages
- ❌ **No offline support** - network error = blank screen
- ❌ **Slow navigation** - user waits for network on every click

**File:** `ios-mip-app/FFCI/API/MipApiClient.swift`

**Current API Method (lines 92-128):**
```swift
func getPage(uuid: String) async throws -> PageData {
    // Direct API call - no caching
    let (data, response) = try await session.data(for: request)
    // ... decode and return
}
```

**No Cache Infrastructure:**
- ❌ No Data/ directory for cache classes
- ❌ No cache layer between UI and API
- ❌ No cache invalidation logic

### Implementation Plan

**Step 1: Create PageCache.swift (NEW FILE)**
- Location: `ios-mip-app/FFCI/Data/PageCache.swift`
- Need to create `Data/` directory first
- Use **Actor** for thread safety (modern Swift concurrency)
- Implement cache storage with timestamp tracking
- Implement LRU eviction (max 50 pages)
- Add TTL checking (5 minutes default)

**Step 2: Add Cache Methods**

Methods to implement (mirror Android pattern):
1. `get(_ uuid: String, ttl: TimeInterval) -> PageData?` - Get valid cache
2. `put(_ uuid: String, data: PageData)` - Store in cache
3. `hasCache(_ uuid: String) -> Bool` - Check if any cache exists
4. `hasValid(_ uuid: String, ttl: TimeInterval) -> Bool` - Check if valid cache exists
5. `getAnyCache(_ uuid: String) -> PageData?` - Get cache even if stale
6. `clear()` - Clear all cache
7. `remove(_ uuid: String)` - Remove specific entry
8. `size() -> Int` - Get cache size

**Step 3: Modify MipApiClient.swift**
- Keep existing `getPage(uuid:)` for direct API calls
- Add new `getPageWithCache(uuid:)` method that:
  1. Checks cache first with `PageCache.shared.getAnyCache()`
  2. Returns cached data immediately if available
  3. Fetches fresh data in background
  4. Updates cache after successful fetch
  5. Returns tuple: `(data: PageData, fromCache: Bool)`

**Step 4: Modify TabPageView.swift**
- Change initialization to check cache synchronously
- Update `@State private var pageData` initialization to use cached data
- Update `@State private var isLoading` to be `false` if cache exists
- Add `@State private var isRefreshing` for background refresh indicator
- Modify `loadPage()` to use `getPageWithCache()`
- Add visual indicator for background refresh (subtle, non-intrusive)

**Step 5: Update Project File**
- Add `Data` group in Xcode project
- Add `PageCache.swift` to target membership
- Ensure proper file organization

### Code Locations

| File | Purpose | Changes Needed |
|------|---------|----------------|
| `ios-mip-app/FFCI/Data/PageCache.swift` | **NEW FILE** - Cache manager | Create actor with cache storage, LRU, TTL |
| `ios-mip-app/FFCI/API/MipApiClient.swift` | API client | Add `getPageWithCache()` method (lines 92-128) |
| `ios-mip-app/FFCI/Views/TabPageView.swift` | Page view | Modify `loadPage()` (lines 102-122), add cache check in init |
| `ios-mip-app/FFCI.xcodeproj/project.pbxproj` | Xcode project | Add Data/ group and PageCache.swift file reference |
| `android-mip-app/app/src/main/java/com/fiveq/ffci/data/cache/PageCache.kt` | **REFERENCE ONLY** | Study for implementation patterns |
| `rn-mip-app/lib/pageCache.ts` | **REFERENCE ONLY** | Study for API patterns |

### Variables/Data Reference

**Cache Entry Structure:**
```swift
struct CachedPage {
    let data: PageData
    let timestamp: Date
    
    func isExpired(ttl: TimeInterval) -> Bool {
        Date().timeIntervalSince(timestamp) > ttl
    }
}
```

**PageCache Actor Properties:**
```swift
actor PageCache {
    static let shared = PageCache()
    
    private var cache: [String: CachedPage] = [:]  // UUID -> CachedPage
    private var accessOrder: [String] = []          // LRU tracking
    
    private let defaultTTL: TimeInterval = 5 * 60  // 5 minutes in seconds
    private let maxCacheSize: Int = 50              // Max entries before eviction
}
```

**MipApiClient Return Type (new method):**
```swift
func getPageWithCache(uuid: String) async throws -> (data: PageData, fromCache: Bool)
```

**TabPageView State Variables:**
```swift
@State private var pageData: PageData?      // Current page data
@State private var isLoading = true         // Blocking loading (no cache)
@State private var isRefreshing = false     // Background refresh (has cache)
@State private var error: String?           // Error message
```

**Key Types (from ApiModels.swift):**
- `PageData` - Existing struct for page content
- `String` (UUID) - Cache key (e.g., "abc123-def456")

### Thread Safety Implementation

**Use Swift Actor (Recommended):**
```swift
actor PageCache {
    static let shared = PageCache()
    
    private var cache: [String: CachedPage] = [:]
    private var accessOrder: [String] = []
    
    // Methods are automatically isolated to actor's executor
    func get(_ uuid: String) -> PageData? { ... }
    func put(_ uuid: String, data: PageData) { ... }
}
```

**Benefits:**
- Automatic thread safety (no manual locks)
- Modern Swift concurrency (async/await compatible)
- Compiler-enforced isolation
- Same pattern as Android's synchronized blocks

**Alternative (DispatchQueue):**
- Only if targeting iOS < 15.0
- Use `DispatchQueue(label:, attributes: .concurrent)` with read/write barriers
- More complex, error-prone

### Cache Invalidation Strategy

**Time-Based (Primary):**
- 5-minute TTL (configurable via parameter)
- Checked on every `get()` call
- Expired entries removed automatically

**Size-Based (LRU):**
- Max 50 pages in cache
- Evict oldest (least recently used) when full
- Access updates order (move to end)

**Manual (Optional):**
- `clear()` - Clear all cache (e.g., on logout)
- `remove(uuid)` - Clear specific page (e.g., after edit)

**No Background Sweep:**
- Lazy eviction on access (same as Android/RN)
- Simpler implementation
- Memory efficient (only grows to max size)

### Performance Expectations

**Cache Hit (Fresh):**
- **Android pattern:** 0-5ms to return cached data
- **RN pattern:** Instant (synchronous Map lookup)
- **iOS target:** <10ms (actor isolation overhead)

**Cache Hit (Stale):**
- Show stale data instantly (<10ms)
- Background refresh: 100-500ms depending on network
- UI updates silently when fresh data arrives

**Cache Miss:**
- Show loading spinner
- Network fetch: 100-500ms (same as current)
- User experience: Same as today for first visit

**Memory Usage:**
- ~50 pages * ~20KB average = ~1MB max
- Acceptable for in-memory cache
- No persistence needed (fresh on app restart)

### Testing Strategy

**Manual Testing (Required):**
1. Navigate to page A → verify loading spinner
2. Navigate to page B, then back to A → verify instant display (no spinner)
3. Wait 5+ minutes → navigate back to A → verify background refresh
4. Navigate to 51+ unique pages → verify oldest pages evicted
5. Test with airplane mode → verify cached pages still work

**Maestro Tests (Optional Enhancement):**
- Could add performance assertions (instant display on cache hit)
- Could verify no loading spinner on second visit
- Not required for initial implementation

### Estimated Complexity

**Medium Complexity**

**Justification:**
- ✅ **Well-defined pattern** - Android and RN implementations to reference
- ✅ **Single new file** - Most code is isolated to PageCache.swift
- ✅ **Modern Swift features** - Actor makes thread safety simple
- ⚠️ **UI state changes** - Need to carefully manage loading vs refreshing states
- ⚠️ **Xcode project changes** - Adding Data/ group requires project file edits
- ✅ **No persistence** - In-memory only simplifies implementation

**Time Estimate:**
- PageCache.swift implementation: 1-2 hours
- MipApiClient integration: 30 minutes
- TabPageView modifications: 1 hour
- Testing and debugging: 1-2 hours
- **Total: 3-5 hours** for experienced Swift/iOS developer

**Risk Areas:**
1. **Actor usage** - If not familiar with Swift actors, might take longer
2. **UI state management** - Loading vs refreshing states must be clear
3. **Xcode project file** - Manual edits can break if not careful (use Xcode GUI instead)
