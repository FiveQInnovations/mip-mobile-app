---
status: qa
area: ios-mip-app
phase: core
created: 2026-01-24
---

# iOS Search Functionality

## Context

The iOS app needs search functionality to allow users to find content within the app. This was deferred during initial implementation but is needed for full feature parity with Android.

## Problem

Users cannot search for content within the iOS app. The search API endpoint exists but there's no UI or integration.

## Goals

1. Implement search UI (search bar, results list)
2. Connect to existing search API endpoint
3. Display search results with navigation to content
4. Implement client-side caching for performance

## Acceptance Criteria

- Search interface accessible from home screen (search icon)
- Users can type search queries
- Results display with title, description, and navigation indicator
- Tapping a result navigates to that content
- Loading and empty states handled appropriately
- Search performs well (results appear quickly)
- Search input is debounced (500ms)
- Minimum 3 character query length before searching
- Search results are cached (2 minute TTL)

## Android Reference Implementation

File: `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/screens/SearchScreen.kt`

**Key features:**
- Full-screen search interface
- Debounced search input (500ms)
- Minimum 3 character query requirement
- In-memory cache with 2 minute TTL
- Request cancellation for in-flight requests
- Three states: initial, loading, results/empty

## React Native Reference Implementation

File: `rn-mip-app/app/search.tsx`

**UI Strategy:**
- Full-screen search with header: back button + search input + clear button
- **500ms debounce** on search input
- **Minimum 3 character query length** before searching
- List for results rendering
- Three states: initial ("Start typing to search"), loading (spinner + "Searching..."), no results
- Results show: title (bold), description (2 lines max), chevron icon

**Client-Side Caching:**
- In-memory cache (use Dictionary/Map in Swift)
- **2 minute TTL** (shorter than page cache)
- **Max 20 cached queries** with LRU eviction
- Query normalization: lowercase + trim before cache key lookup

## iOS Implementation Notes

### API Integration

- Endpoint: `GET /mobile-api/search?q=<encoded_query>`
- Response: Array of `SearchResult` objects
- Add to `MipApiClient.swift`: `func searchSite(query: String) async throws -> [SearchResult]`

### Files to Create/Modify

1. **ios-mip-app/FFCI/API/ApiModels.swift** - Add SearchResult struct:
   ```swift
   struct SearchResult: Codable {
       let uuid: String
       let title: String
       let description: String
       let url: String
   }
   ```

2. **ios-mip-app/FFCI/API/MipApiClient.swift** - Add search method
   - URL encoding for query parameter
   - Error handling

3. **ios-mip-app/FFCI/Views/SearchView.swift** - New component
   - Search bar with debouncing
   - Results list
   - Loading/empty states
   - Navigation to results

4. **ios-mip-app/FFCI/Views/HomeView.swift** - Modify
   - Add search icon button
   - Present SearchView on tap

5. **ios-mip-app/FFCI/Data/SearchCache.swift** - New cache manager
   - In-memory Dictionary cache
   - 2 minute TTL
   - LRU eviction (max 20 queries)
   - Query normalization

### State Management

```swift
@State private var searchQuery = ""
@State private var searchResults: [SearchResult] = []
@State private var isLoading = false
@State private var showEmptyState = false
```

### Debouncing

Use Combine's `debounce` operator or a custom Timer-based solution:

```swift
$searchQuery
    .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
    .sink { query in
        if query.count >= 3 {
            performSearch(query: query)
        }
    }
```

### Request Cancellation

Use `Task` cancellation or URLSession's `cancel()` method to cancel in-flight requests when user types new character.

## Related Files

- `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/screens/SearchScreen.kt`
- `android-mip-app/app/src/main/java/com/fiveq/ffci/data/cache/SearchCache.kt`
- `rn-mip-app/app/search.tsx`
- `rn-mip-app/lib/searchCache.ts`
- `ios-mip-app/FFCI/Views/HomeView.swift`
- `ios-mip-app/FFCI/API/MipApiClient.swift`

---

## Research Findings (Scouted)

### React Native Reference Implementation

**File:** `rn-mip-app/app/search.tsx` (374 lines)

**UI Structure:**
- Full-screen search interface with header containing:
  - Back button (arrow-back icon, line 233)
  - Search input with search icon (line 235-246)
  - Clear button (close-circle icon) when query.length > 0 (line 247-265)
- FlatList for rendering results (line 270-276)
- Three empty states (line 192-223):
  - **Initial state:** "Start typing to search" + subtext (when !hasSearched)
  - **Loading state:** ActivityIndicator + "Searching..." (when isLoading)
  - **No results:** "No results found" + "Try a different search term" (when hasSearched && results.length === 0)

**Debouncing Strategy:**
- Implemented with `useEffect` hook + `setTimeout` (line 32-44)
- 500ms delay after user stops typing
- Automatically clears timer on query change (cleanup function line 43)
- Minimum 3 character requirement enforced before debounce timer starts

**Request Cancellation:**
- Uses `AbortController` via `useRef` (line 29)
- Cancels previous request before starting new one (line 59-62)
- Passes `abortController.signal` to API call (line 104)
- Handles AbortError gracefully in catch block (line 146-152)

**Caching Strategy:**
- Checks cache before API call (line 65-85)
- On cache hit: returns results immediately with no loading state
- On cache miss: sets loading state, calls API, stores result (line 115-119)
- Cache key: normalized query (lowercase + trim)
- Cache implementation: `rn-mip-app/lib/searchCache.ts`

**Performance Logging:**
- Extensive performance metrics (lines 53-144)
- Tracks: cache check time, API duration, render time, total time
- Useful for debugging but could be removed for production iOS version

**Navigation:**
- Result tap: dismisses keyboard, navigates to `/page/${result.uuid}` using Expo Router (line 169-172)

**API Integration:**
- Function: `searchSite(query: string, signal?: AbortSignal)` from `lib/api.ts:308`
- Endpoint: `GET ${config.apiBaseUrl}/mobile-api/search?q=${encodedQuery}`
- Query encoding: `encodeURIComponent(query.trim())` (line 313)
- Returns: `Promise<SearchResult[]>`

**SearchResult Interface** (`rn-mip-app/lib/api.ts:66-71`):
```typescript
export interface SearchResult {
  uuid: string;
  title: string;
  description: string;
  url: string;
}
```

### React Native Cache Implementation

**File:** `rn-mip-app/lib/searchCache.ts` (168 lines)

**Cache Storage:**
- In-memory Map: `Map<string, CachedSearch>` (line 9)
- TTL: 2 minutes (120,000ms) - line 12
- Max size: 20 queries (line 15)
- Thread-safe: No (JavaScript is single-threaded)

**Cache Entry Structure** (line 3-6):
```typescript
interface CachedSearch {
  data: SearchResult[];
  timestamp: number;
}
```

**Query Normalization** (line 20-22):
```typescript
function normalizeQuery(query: string): string {
  return query.trim().toLowerCase();
}
```

**LRU Eviction** (line 27-47):
- Finds oldest entry by timestamp (not access order)
- Evicts when cache.size >= MAX_CACHE_SIZE
- Logs eviction to console

**Cache Operations:**
- `getCachedSearch(query)` - line 52: Returns results if fresh, null if stale/missing
- `setCachedSearch(query, data)` - line 84: Stores with timestamp, evicts old if needed
- `clearCachedSearch(query)` - line 113: Removes specific entry
- `clearAllCache()` - line 122: Clears entire cache

### Android Reference Implementation

**File:** `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/screens/SearchScreen.kt` (331 lines)

**UI Structure (Jetpack Compose):**
- Composable function `SearchScreen` (line 55-285)
- Header Row with back button, OutlinedTextField, clear button (line 133-191)
- LazyColumn for results when results.isNotEmpty() (line 195-212)
- Empty state Box with three states (line 215-283)

**State Management:**
- `var query by remember { mutableStateOf("") }` (line 60)
- `var results by remember { mutableStateOf<List<SearchResult>>(emptyList()) }` (line 61)
- `var isLoading by remember { mutableStateOf(false) }` (line 62)
- `var hasSearched by remember { mutableStateOf(false) }` (line 63)
- `var searchJob by remember { mutableStateOf<Job?>(null) }` (line 64)

**Debouncing with Kotlin Coroutines:**
- `LaunchedEffect(query)` block (line 70-125)
- Cancels previous job: `searchJob?.cancel()` (line 72)
- 500ms delay: `delay(500)` (line 93)
- Launches in coroutineScope

**Cache Integration:**
- First check before debounce: `SearchCache.get(trimmedQuery)` (line 83-89)
- Second check after debounce delay (line 96-102)
- Store result after API call: `SearchCache.put(trimmedQuery, searchResults)` (line 112)

**Request Cancellation:**
- Uses Kotlin coroutine Job cancellation
- `searchJob?.cancel()` cancels entire coroutine
- Catches `CancellationException` (line 119)

**Navigation:**
- Result click: `onResultClick(result.uuid)` (line 56)
- Back click: `onBackClick()` (line 57)
- Handled by NavGraph: `android-mip-app/app/src/main/java/com/fiveq/ffci/ui/navigation/NavGraph.kt:74-82`

**Result Item Component** (line 288-330):
- `SearchResultItem` composable
- Row with Column (title + description) + ChevronRight icon
- Title: fontWeight SemiBold, maxLines 1
- Description: maxLines 2, nullable

### Android Cache Implementation

**File:** `android-mip-app/app/src/main/java/com/fiveq/ffci/data/cache/SearchCache.kt` (166 lines)

**Cache Storage:**
- `object SearchCache` - Singleton pattern (line 18)
- `ConcurrentHashMap<String, CachedSearch>` for thread-safety (line 37)
- `mutableListOf<String>()` for access order tracking (line 38)

**Cache Entry** (line 27-35):
```kotlin
data class CachedSearch(
    val data: List<SearchResult>,
    val timestamp: Long = System.currentTimeMillis()
) {
    fun isExpired(): Boolean {
        val age = System.currentTimeMillis() - timestamp
        return age > CACHE_TTL.inWholeMilliseconds
    }
}
```

**LRU Strategy:**
- True LRU: maintains `accessOrder` list (line 38)
- Updates access order on cache hit (line 98-99)
- Evicts by oldest timestamp, not access order (line 50-72)

**Thread Safety:**
- Uses `synchronized(accessOrder)` blocks
- Safe for concurrent access from multiple coroutines

### iOS Current State Analysis

**SearchResult Model - ALREADY EXISTS** (`ios-mip-app/FFCI/API/ApiModels.swift:189-194`):
```swift
struct SearchResult: Codable {
    let uuid: String
    let title: String
    let description: String?
    let url: String
}
```
✅ Already defined and matches API response structure.

**API Client - ALREADY HAS searchSite METHOD** (`ios-mip-app/FFCI/API/MipApiClient.swift:130-167`):
```swift
func searchSite(query: String) async throws -> [SearchResult] {
    guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
        throw ApiError.networkError(NSError(domain: "Invalid query", code: -1))
    }
    
    let url = URL(string: "\(baseURL)/mobile-api/search?q=\(encodedQuery)")!
    // ... request handling ...
    let results = try decoder.decode([SearchResult].self, from: data)
    return results
}
```
✅ API method exists and is fully functional. No modifications needed.

**HomeView - No Search Button** (`ios-mip-app/FFCI/Views/HomeView.swift:1-277`):
- Currently has logo header (line 19-41)
- No search icon button in top-right
- Missing: Search icon button + navigation to SearchView

**Navigation Structure** (`ios-mip-app/FFCI/ContentView.swift:62-133`):
- Uses `TabView` for bottom navigation (line 72)
- No NavigationStack/NavigationView for push navigation
- Current navigation is tab-only (no modal or push presentations)

### Implementation Plan for iOS

#### 1. Create SearchCache.swift (NEW FILE)
**Location:** `ios-mip-app/FFCI/Data/SearchCache.swift`

**Implementation Strategy:**
- Use Swift `class` (not `struct`) for reference semantics
- Use `NSCache<NSString, CachedSearchEntry>` or custom Dictionary-based cache
- Thread-safety: Use `DispatchQueue` or `actor` (Swift 5.5+)
- Query normalization: `query.trimmingCharacters(in: .whitespaces).lowercased()`

**Key Features to Implement:**
- 2 minute TTL: `let cacheTTL: TimeInterval = 120`
- Max 20 queries: `private let maxCacheSize = 20`
- LRU eviction: Track access order with array
- Methods:
  - `func get(query: String) -> [SearchResult]?`
  - `func set(query: String, results: [SearchResult])`
  - `func clear(query: String)`
  - `func clearAll()`

**Swift Equivalent Patterns:**
- Map<String, T> → Dictionary<String, T>
- timestamp → TimeInterval (Date().timeIntervalSince1970)
- synchronized → DispatchQueue.sync or actor

#### 2. Create SearchView.swift (NEW FILE)
**Location:** `ios-mip-app/FFCI/Views/SearchView.swift`

**UI Structure (SwiftUI):**
```swift
struct SearchView: View {
    @State private var query: String = ""
    @State private var results: [SearchResult] = []
    @State private var isLoading: Bool = false
    @State private var hasSearched: Bool = false
    @State private var searchTask: Task<Void, Never>?
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with back button + search input
            // Results list or empty state
        }
    }
}
```

**Debouncing Implementation:**
- Option 1: Combine framework with `.debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)`
- Option 2: Custom Timer-based approach
- Option 3 (RECOMMENDED): Task cancellation with `Task.sleep`

**Recommended Approach (Task-based debouncing):**
```swift
.onChange(of: query) { newQuery in
    // Cancel previous search task
    searchTask?.cancel()
    
    guard newQuery.count >= 3 else {
        results = []
        hasSearched = false
        return
    }
    
    // Start new search task with debounce
    searchTask = Task {
        try? await Task.sleep(nanoseconds: 500_000_000) // 500ms
        guard !Task.isCancelled else { return }
        await performSearch(query: newQuery)
    }
}
```

**Request Cancellation:**
- Use `Task.isCancelled` checks
- Store `Task<Void, Never>?` in @State
- Cancel previous task before starting new one

**Empty States:**
1. Initial: SF Symbol "magnifyingglass" + "Start typing to search"
2. Loading: ProgressView() + "Searching..."
3. No results: SF Symbol "magnifyingglass" + "No results found"

**Result List:**
- `List(results, id: \.uuid) { result in ... }`
- NavigationLink to page view with UUID
- Title: `.font(.headline).fontWeight(.semibold)`
- Description: `.font(.subheadline).foregroundColor(.secondary).lineLimit(2)`
- Chevron: System chevron or SF Symbol "chevron.right"

#### 3. Modify HomeView.swift
**File:** `ios-mip-app/FFCI/Views/HomeView.swift`

**Changes Required:**

**Add State for Search Sheet:**
```swift
@State private var showSearch: Bool = false
```

**Modify Header Section (line 18-41):**
```swift
VStack(spacing: 8) {
    HStack {
        // Logo (existing code, left-aligned)
        if let logo = siteMeta.logo { ... }
        
        Spacer()
        
        // Search button (NEW)
        Button(action: { showSearch = true }) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 20))
                .foregroundColor(Color(red: 0.059, green: 0.090, blue: 0.161)) // #0F172A
                .frame(width: 44, height: 44)
        }
    }
    .padding(.horizontal, 16)
}
```

**Add Sheet Modifier (after body):**
```swift
.sheet(isPresented: $showSearch) {
    SearchView()
}
```

**Alternative: NavigationStack Approach**
If using NavigationStack (iOS 16+):
```swift
NavigationStack {
    // HomeView content
}
.fullScreenCover(isPresented: $showSearch) {
    SearchView()
}
```

#### 4. Update ContentView.swift (IF NEEDED)
**File:** `ios-mip-app/FFCI/ContentView.swift`

**Current Structure:**
- TabView at line 72 (no NavigationStack wrapper)

**Potential Modification (if search needs push navigation):**
Wrap TabView in NavigationStack:
```swift
NavigationStack {
    TabView(selection: $selectedTab) {
        // ... existing tabs
    }
}
```

However, **sheet presentation is simpler** and matches RN's modal behavior better.

### Code Locations

| File | Purpose | Status |
|------|---------|--------|
| `ios-mip-app/FFCI/API/ApiModels.swift:189-194` | SearchResult struct | ✅ EXISTS - No changes needed |
| `ios-mip-app/FFCI/API/MipApiClient.swift:130-167` | searchSite() method | ✅ EXISTS - No changes needed |
| `ios-mip-app/FFCI/Data/SearchCache.swift` | Cache manager | ❌ CREATE NEW |
| `ios-mip-app/FFCI/Views/SearchView.swift` | Search UI | ❌ CREATE NEW |
| `ios-mip-app/FFCI/Views/HomeView.swift:18-41` | Add search button | ⚠️ MODIFY - Add button in header |
| `ios-mip-app/FFCI/Views/HomeView.swift` (body) | Add sheet modifier | ⚠️ MODIFY - Add .sheet() |

### Key Implementation Details

**Debouncing Comparison:**

| Platform | Strategy | Code Location |
|----------|----------|---------------|
| React Native | useEffect + setTimeout | `rn-mip-app/app/search.tsx:32-44` |
| Android | LaunchedEffect + delay(500) | `android-mip-app/.../SearchScreen.kt:70-125` |
| iOS (Recommended) | Task + Task.sleep | Use .onChange(of: query) |

**Request Cancellation Comparison:**

| Platform | Strategy | Implementation |
|----------|----------|----------------|
| React Native | AbortController | `abortControllerRef.current.abort()` |
| Android | Coroutine Job | `searchJob?.cancel()` |
| iOS (Recommended) | Task cancellation | `searchTask?.cancel()` + `Task.isCancelled` |

**Navigation Comparison:**

| Platform | Presentation | Dismissal |
|----------|--------------|-----------|
| React Native | router.push('/search') | router.back() |
| Android | navController.navigate() | navController.popBackStack() |
| iOS (Recommended) | .sheet(isPresented:) | dismiss() environment |

**Cache Structure Comparison:**

| Platform | Storage | Thread-Safety | LRU Strategy |
|----------|---------|---------------|--------------|
| React Native | Map<string, T> | Single-threaded (JS) | Timestamp-based eviction |
| Android | ConcurrentHashMap<String, T> | synchronized blocks | accessOrder list + timestamp |
| iOS (Recommended) | Dictionary<String, T> | actor or DispatchQueue | accessOrder array + timestamp |

### Variables/Data Reference

**SearchResult (iOS - Already Defined):**
```swift
struct SearchResult: Codable {
    let uuid: String           // Page identifier for navigation
    let title: String          // Primary display text (bold)
    let description: String?   // Secondary text (2 lines max, optional)
    let url: String            // Not used in mobile app navigation
}
```

**SearchView State Variables (To Create):**
- `@State private var query: String = ""`
- `@State private var results: [SearchResult] = []`
- `@State private var isLoading: Bool = false`
- `@State private var hasSearched: Bool = false`
- `@State private var searchTask: Task<Void, Never>?`

**SearchCache Properties (To Create):**
- `private let cacheTTL: TimeInterval = 120` (2 minutes)
- `private let maxCacheSize = 20`
- `private var cache: [String: CachedSearchEntry] = [:]`
- `private var accessOrder: [String] = []`

**HomeView New State (To Add):**
- `@State private var showSearch: Bool = false`

### API Endpoint Details

**Endpoint:** `GET https://ffci.fiveq.dev/mobile-api/search?q=<encoded_query>`

**Request Headers (from MipApiClient.swift:37-49):**
- Authorization: Basic (username:password base64 encoded)
- X-API-Key: API key string
- Content-Type: application/json

**Query Encoding:**
- Swift: `query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)`
- Already handled in MipApiClient.searchSite() method

**Response Format:**
```json
[
  {
    "uuid": "abc123",
    "title": "Page Title",
    "description": "Page description text",
    "url": "/path/to/page"
  }
]
```

**Error Handling (from MipApiClient.swift):**
- HTTP status != 200: throws `ApiError.httpError(statusCode:url:)`
- Decoding failure: throws `ApiError.decodingError(Error)`
- Network error: throws `ApiError.networkError(Error)`

### Estimated Complexity

**Level: MEDIUM**

**Justification:**
1. **API integration: TRIVIAL** - searchSite() method already exists and works
2. **SearchResult model: TRIVIAL** - Already defined in ApiModels.swift
3. **SearchCache creation: MEDIUM** - Need to implement LRU cache with TTL
4. **SearchView UI: MEDIUM** - Debouncing, state management, empty states
5. **HomeView modification: LOW** - Simple button + sheet presentation
6. **Navigation: LOW** - Sheet presentation is straightforward

**Time Estimate:**
- SearchCache.swift: 1-2 hours (LRU logic, thread-safety)
- SearchView.swift: 2-3 hours (UI, debouncing, state management)
- HomeView.swift: 30 minutes (button + sheet)
- Testing: 1 hour (verify caching, debouncing, navigation)
- **Total: ~5-7 hours**

**Risk Factors:**
- SwiftUI debouncing may need Combine framework knowledge
- Thread-safety for cache could be tricky without actor pattern
- Sheet presentation might need NavigationStack wrapper for proper dismissal

**Confidence: HIGH** - Clear reference implementations exist in both Android and RN versions.
