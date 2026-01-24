---
status: backlog
area: android-mip-app
phase: core
created: 2026-01-24
---

# Android Search Functionality

## Context

The home screen has a search icon in the header, but search functionality is not yet implemented. Users need to be able to search for content within the app.

## Goals

1. Implement search UI (search bar, results list)
2. Connect to existing search API endpoint
3. Display search results with navigation to content

## Acceptance Criteria

- Tapping search icon opens search interface
- Users can type search queries
- Results display with title, description, and chevron indicator
- Tapping a result navigates to that content
- Loading and empty states handled appropriately
- Search performs well (results appear quickly)

## Notes

- Search API endpoint already exists in `wsp-mobile` plugin
- Previous RN implementation had performance optimizations (ticket 065)
- Consider debouncing search input

## React Native Search Implementation (Reference)

The RN app has a working search implementation with Maestro test coverage. Use this as the reference for Android:

### UI Strategy (`rn-mip-app/app/search.tsx`)
- Full-screen search with header: back button + search input + clear button
- **500ms debounce** on search input (wait for user to stop typing)
- **Minimum 3 character query length** before searching
- FlatList for results rendering (use LazyColumn on Android)
- Three states: initial ("Start typing to search"), loading (spinner + "Searching..."), no results
- Results show: title (bold), description (2 lines max), chevron icon
- `keyboardShouldPersistTaps="handled"` to allow tapping results while keyboard visible

### Client-Side Caching (`rn-mip-app/lib/searchCache.ts`)
- In-memory Map-based cache (use equivalent in Kotlin)
- **2 minute TTL** (shorter than page cache since search results change)
- **Max 20 cached queries** with LRU eviction (oldest removed when full)
- Query normalization: lowercase + trim before cache key lookup
- Check cache before making API call

### Request Cancellation
- AbortController cancels in-flight request when user types new character
- Prevents request pile-up and stale results
- On Android: use OkHttp's `Call.cancel()` or Kotlin coroutine cancellation

### API Integration
- Endpoint: `GET /mobile-api/search?q=<encoded_query>`
- Response: Array of `SearchResult` objects
- Interface: `{uuid: string, title: string, description: string, url: string}`

### Maestro Test
- Located at: `rn-mip-app/maestro/flows/search-result-descriptions-ios.yaml`
- Tests: tap search icon, type query, verify results appear, verify no "No results found"

## Android-Specific Implementation Notes

### Files to Modify/Create

1. **ApiModels.kt** - Add SearchResult data class:
   ```kotlin
   @JsonClass(generateAdapter = true)
   data class SearchResult(
       val uuid: String,
       val title: String,
       val description: String,
       val url: String
   )
   ```

2. **MipApiClient.kt** - Add search function:
   ```kotlin
   suspend fun searchSite(query: String): List<SearchResult> {
       val encodedQuery = URLEncoder.encode(query, "UTF-8")
       val adapter = moshi.adapter<List<SearchResult>>(...)
       return fetchJson("$BASE_URL/mobile-api/search?q=$encodedQuery", adapter)
   }
   ```

3. **NavGraph.kt** - Add search route:
   ```kotlin
   sealed class Screen(...) {
       data object Search : Screen("search")
   }
   ```

4. **SearchScreen.kt** (new file) - Compose UI:
   - TopAppBar with back button and TextField
   - LazyColumn for results
   - Remember debounce with `LaunchedEffect` and `delay(500)`
   - Loading/empty state Composables

5. **HomeScreen.kt** - Wire up search icon click:
   - Currently has: `onClick = { /* TODO: Navigate to search */ }`
   - Need to pass `onSearchClick: () -> Unit` and navigate to Search route

### Performance Considerations
- Server-side caching is already implemented in wsp-mobile (Kirby cache)
- Client-side caching recommended for instant repeated searches
- Debouncing is critical to avoid spamming API during typing
- Consider using `rememberSaveable` to preserve search state across config changes

## References

- `wsp-mobile/index.php` (lines 166-277) - Search API endpoint with caching
- `rn-mip-app/app/search.tsx` - RN search UI implementation
- `rn-mip-app/lib/searchCache.ts` - RN client-side cache
- `rn-mip-app/lib/api.ts` (lines 308-317) - RN API call
- Previous tickets: 063 (slow search), 065 (performance optimization), 067 (descriptions)
