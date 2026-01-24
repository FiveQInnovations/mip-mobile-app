---
status: backlog
area: ios-mip-app
phase: core
created: 2026-01-24
---

# iOS Pull-to-Refresh

## Context

Users should be able to manually refresh content by pulling down on scrollable views. This provides a familiar iOS pattern and allows users to force a refresh when needed.

## Problem

There's no way for users to manually refresh content. They must navigate away and back to trigger a refresh, or wait for cache expiration.

## Goals

1. Implement pull-to-refresh on scrollable views
2. Show loading indicator during refresh
3. Refresh current page data from API
4. Update UI with fresh data
5. Handle refresh errors gracefully

## Acceptance Criteria

- Pulling down on scrollable views triggers refresh
- Loading indicator appears during refresh
- Content updates with fresh data from API
- Refresh works on HomeView, TabPageView, and CollectionListView
- Errors during refresh are handled gracefully
- Refresh respects cache invalidation

## iOS Implementation Notes

### SwiftUI Native Support

SwiftUI provides built-in pull-to-refresh via `.refreshable` modifier:

```swift
ScrollView {
    // Content
}
.refreshable {
    await refreshData()
}
```

### Files to Modify

1. **ios-mip-app/FFCI/Views/HomeView.swift**
   - Add `.refreshable` modifier to ScrollView
   - Implement refresh function to reload site data

2. **ios-mip-app/FFCI/Views/TabPageView.swift**
   - Add `.refreshable` modifier to ScrollView
   - Implement refresh function to reload current page
   - Invalidate cache for current page before refresh

3. **ios-mip-app/FFCI/Views/CollectionListView.swift**
   - Add `.refreshable` modifier if using ScrollView
   - Refresh parent page data

### Refresh Strategy

**HomeView:**
- Refresh site data (menu, featured, etc.)
- Reload AppState.siteData

**TabPageView:**
- Refresh current page data
- Invalidate PageCache entry for current UUID
- Reload page from API

**CollectionListView:**
- Refresh parent page (which contains collection children)
- Delegate to TabPageView refresh

### Error Handling

- Show error message if refresh fails
- Allow user to retry
- Don't clear existing content on error
- Log refresh errors for debugging

### Cache Integration

When refresh is triggered:
1. Invalidate cache entry for current page
2. Fetch fresh data from API
3. Update cache with new data
4. Update UI

### Loading State

- Show native iOS refresh indicator (automatic with `.refreshable`)
- Disable refresh while already refreshing
- Show error state if refresh fails

## Related Files

- `ios-mip-app/FFCI/Views/HomeView.swift`
- `ios-mip-app/FFCI/Views/TabPageView.swift`
- `ios-mip-app/FFCI/Views/CollectionListView.swift`
- `ios-mip-app/FFCI/Data/PageCache.swift` (ticket 203)

---

## Research Findings (Scouted)

### Android Implementation Status

**NO pull-to-refresh implemented in Android app**
- Searched for `SwipeRefresh`, `pullRefresh`, and `PullRefresh` patterns - no results
- Android app does not currently have any pull-to-refresh functionality

### React Native Reference

**RN does NOT use native pull-to-refresh (RefreshControl)**

Instead, RN uses a **manual refresh pattern** with visual indicators:

#### TabScreen Implementation (`rn-mip-app/components/TabScreen.tsx`)

**Refresh State Management:**
```
Line 30: const [refreshing, setRefreshing] = React.useState(false);
```

**Manual Refresh Function (Lines 133-137):**
```typescript
const handleManualRefresh = () => {
  console.log(`[TabScreen] Manual refresh triggered for UUID: ${currentUuid}`);
  clearCachedPage(currentUuid);
  loadPage();
};
```

**Cache Integration:**
- Refresh invalidates cache via `clearCachedPage(currentUuid)` from `lib/pageCache.ts`
- After cache clear, calls `loadPage()` which fetches fresh data
- Background refresh happens automatically when cache is available (lines 68-105)

**Visual Indicators:**
1. **Top progress bar** (lines 199-203) - Thin bar at top using primary color
2. **Header spinner** (lines 220-227) - ActivityIndicator in header when `canGoBack`
3. **Title area spinner** (lines 268-276) - ActivityIndicator in title area when not `canGoBack`

**Manual Refresh Button:**
- Lines 229-238: Dev tool refresh button in header
- Uses Ionicons "refresh" icon
- Triggers `handleManualRefresh()` on press

**Error Handling:**
- Lines 143-145: Shows ErrorScreen if error exists
- Passes `loading || refreshing` as `retrying` prop
- ErrorScreen provides retry functionality

#### HomeScreen Implementation (`rn-mip-app/components/HomeScreen.tsx`)

**NO refresh functionality** - Home screen does not implement refresh at all
- HomeScreen only displays cached site data
- Has a "Clear Cache" dev tool button (lines 348-363) but no pull-to-refresh

#### PageScreen Implementation (`rn-mip-app/components/PageScreen.tsx`)

**NO refresh functionality** - Uses simple `getPage()` API call
- No caching layer
- No refresh state management
- Only shows loading on initial load

#### Search Screen (`rn-mip-app/app/search.tsx`)

**NO refresh functionality** - Search uses its own cache
- Uses `searchCache.ts` for caching
- Implements debouncing (500ms) and request cancellation via AbortController
- No pull-to-refresh pattern

### iOS Implementation Requirements

Based on RN's manual refresh pattern, iOS should implement **native pull-to-refresh** using SwiftUI's `.refreshable` modifier, which provides a superior UX compared to RN's manual button approach.

#### Target Views

**1. TabPageView.swift (Lines 38-73)**

Current ScrollView location:
```swift
Line 38: ScrollView {
Line 39:   VStack(alignment: .leading, spacing: 16) {
...
Line 73: }
```

**Changes needed:**
- Add `.refreshable { await refreshPage() }` modifier to ScrollView (after line 73)
- Create `refreshPage()` async function that:
  1. Clears cache for `currentUuid` (requires PageCache from ticket 203)
  2. Calls `loadPage(uuid: currentUuid)`
  3. Shows native iOS refresh indicator automatically

**2. HomeView.swift (Lines 16-113)**

Current ScrollView location:
```swift
Line 16: ScrollView {
Line 17:   VStack(spacing: 0) {
...
Line 113: }
```

**Changes needed:**
- Add `.refreshable { await refreshSiteData() }` modifier to ScrollView (after line 113)
- Create `refreshSiteData()` async function that:
  1. Reloads site data (menu, featured, quick tasks)
  2. Updates AppState.siteData (or equivalent state management)

**3. CollectionListView.swift**

**NO changes needed** - This is a list component, not a screen
- CollectionListView is used inside TabPageView's ScrollView
- Refresh at TabPageView level will refresh parent page data, which includes collection children

### Cache Integration Strategy

**Depends on ticket 203 (iOS Page Caching)**

Once PageCache is implemented, refresh flow:
1. User pulls down on ScrollView
2. iOS shows native refresh indicator
3. Refresh function:
   - Invalidates cache entry for current UUID
   - Fetches fresh data from API via `MipApiClient.shared.getPage()`
   - Updates view state with fresh data
   - Cache is updated with new data
4. Native refresh indicator dismisses automatically

**Cache invalidation function needed:**
```swift
// In PageCache.swift
func clearCachedPage(uuid: String) {
  // Remove entry from cache dictionary
}
```

### Error Handling Strategy

**SwiftUI `.refreshable` benefits:**
- Native iOS pull-to-refresh gesture (no custom UI needed)
- Automatic loading indicator
- Automatic dismissal on completion or error

**Error handling approach:**
```swift
.refreshable {
  do {
    await refreshPage()
  } catch {
    // Show error alert or toast
    // Don't clear existing content - keep stale data visible
    print("Refresh error: \(error.localizedDescription)")
  }
}
```

### Implementation Complexity

**Low-Medium** complexity:
- ✅ SwiftUI provides native `.refreshable` modifier (very simple)
- ⚠️ **Depends on ticket 203** (PageCache implementation)
- ✅ API client already exists (`MipApiClient.shared.getPage()`)
- ✅ View structure already uses ScrollView with proper state management
- ✅ Error handling already exists in TabPageView (lines 34-36)

**Estimated effort:** 
- 1-2 hours if PageCache exists (ticket 203)
- Cannot implement until ticket 203 is complete

### Code Locations Summary

| File | Lines | Changes Needed |
|------|-------|----------------|
| `ios-mip-app/FFCI/Views/TabPageView.swift` | 38-73, 102-122 | Add `.refreshable` to ScrollView, create `refreshPage()` function |
| `ios-mip-app/FFCI/Views/HomeView.swift` | 16-113 | Add `.refreshable` to ScrollView, create `refreshSiteData()` function |
| `ios-mip-app/FFCI/Views/CollectionListView.swift` | N/A | **No changes needed** - inherits refresh from parent |
| `ios-mip-app/FFCI/Data/PageCache.swift` | TBD | Needs `clearCachedPage(uuid:)` function (ticket 203) |

### Key Variables & Data Flow

**TabPageView:**
- `currentUuid: String` - Current page being displayed (line 20-22)
- `pageData: PageData?` - Current page data (line 16)
- `isLoading: Bool` - Loading state (line 17)
- `error: String?` - Error state (line 18)
- `loadPage(uuid: String)` - Loads page from API (lines 102-122)

**HomeView:**
- `siteMeta: SiteMeta` - Site metadata (line 11)
- No refresh state currently - will need to add

**Data flow on refresh:**
```
User pulls down
  → .refreshable closure triggered
  → clearCachedPage(uuid)
  → loadPage(uuid)
  → MipApiClient.shared.getPage(uuid)
  → Fresh PageData returned
  → View updates automatically
  → Native indicator dismisses
```

### Dependencies

**Blockers:**
- ⚠️ **Ticket 203 (iOS Page Caching)** - Must be completed first
  - Needs `PageCache` class with cache storage
  - Needs `clearCachedPage(uuid:)` function

**Nice-to-have:**
- Toast/Alert component for error messaging (currently uses ErrorView full-screen)

### Testing Considerations

**Manual testing needed:**
1. Pull-to-refresh on TabPageView with cached data
2. Pull-to-refresh on TabPageView with no cache
3. Pull-to-refresh during network error
4. Pull-to-refresh on HomeView
5. Verify cache invalidation works
6. Verify fresh data displays after refresh
7. Verify refresh indicator shows and dismisses correctly

**No Maestro tests needed initially** - This is a native iOS gesture that's difficult to automate
