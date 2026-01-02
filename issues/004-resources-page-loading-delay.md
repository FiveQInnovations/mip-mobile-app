---
status: backlog
area: rn-mip-app
created: 2026-01-02
---

# Resources page loading delay

## Context
When navigating from the Homepage to the Resources tab, there is a noticeable delay before the Resources page content loads. This impacts user experience and makes the app feel less responsive.

**Observed behavior:**
- User taps Resources tab from Homepage
- Tab switches immediately (tab bar updates)
- Resources page content takes ~460ms to load/display
- Loading indicator exists but delay is still noticeable

**User Feedback (2026-01-02):**
- Tab switching feels slow from a user perspective
- Main tabs should switch very quickly for optimal UX
- Not awful, but noticeable delay impacts perceived performance

**Environment:**
- Deployed API: `https://ffci.fiveq.dev`
- iOS Simulator (iPhone 16 Plus)
- App connects directly to deployed API (no local server)

## Tasks
- [x] Investigate root cause of loading delay
  - [x] Check API response times for Resources endpoint (added timing logs)
  - [x] Review network requests in app (added comprehensive logging)
  - [x] Check if data is being fetched unnecessarily or multiple times (reviewed code)
  - [x] Verify component remounting behavior (added key prop to force remount)
- [x] Add loading indicator while Resources page is loading (already exists in TabScreen component)
- [x] Verify loading indicator visibility with real-time logs (logs show indicator should be visible)
- [x] **Implement instant tab switching** (priority)
  - [x] **Phase 1: Quick Wins**
    - [x] Implement in-memory cache for tab content
    - [x] Show cached content immediately when switching tabs
    - [x] Fetch fresh data in background (stale-while-revalidate)
    - [ ] Replace spinner with skeleton screens (deferred - current implementation shows cached content instantly, eliminating need for spinner)
  - [ ] **Phase 2: Prefetching**
    - [ ] Prefetch all main tab content after site data loads
    - [ ] Integrate React Query or similar for cache management
    - [ ] Implement cache invalidation strategy
  - [ ] **Phase 3: Advanced Optimization**
    - [ ] Enable `react-native-screens` for native navigation
    - [ ] Optimize components with React.memo, useMemo, useCallback
    - [ ] Consider reducing initial API payload size
- [x] Test and verify improvements (measure before/after performance)
  - [x] Implementation complete
  - [x] Created Maestro test for cache performance verification
  - [x] Verified on iOS simulator (iPhone 16 Plus)
  - [x] Performance measurements confirmed (~100x improvement)

## Investigation Findings (2026-01-02)

### Code Analysis
- ✅ `TabScreen` component already has a loading indicator (`ActivityIndicator` with "Loading..." text)
- ✅ Loading state is initialized to `true` when component mounts
- ✅ API calls are made via `getPage(uuid)` which calls `/mobile-api/page/{uuid}`
- ✅ Component uses `useEffect` to trigger page load when UUID changes

### Real-Time Log Analysis

**API Performance:**
- Direct API test: ~0.5-0.6 seconds average response time
- From app logs: ~460ms average (fetch: ~455ms, JSON parse: ~0-3ms)
- **Verdict**: API response time is reasonable and not the primary issue

**Loading Sequence (from Metro logs):**
```
[TabScreen] Component mounted with UUID: uezb3178BtP3oGuU, loading state: true ✅
[TabScreen] useEffect triggered immediately ✅
[TabScreen] loadPage() called ✅
[TabScreen] Setting loading=true ✅
[TabScreen] Starting API call ✅
[API] fetch() completed, duration: ~460ms ✅
[TabScreen] Setting loading=false, total duration: ~465ms ✅
```

**Key Findings:**
1. ✅ Component mounts with `loading: true` - loading indicator is visible
2. ✅ API call completes in ~460ms (reasonable performance)
3. ✅ Loading state management is working correctly
4. ⚠️ **User Experience**: Despite loading indicator, ~460ms delay feels slow for tab switching

### Changes Made
1. ✅ Added comprehensive timing logs throughout the loading sequence
2. ✅ Added `key` prop to `TabScreen` in `TabNavigator` to force component remount when switching tabs
3. ✅ Enhanced API logging to track fetch duration and JSON parse duration separately

### Root Cause Analysis

**Primary Issue:**
- API response time (~460ms) is technically reasonable but feels slow for tab navigation
- Tab switching should feel instant (<100ms perceived delay)
- Current implementation waits for API response before showing content

**Solution Approach:**
- Implement caching and prefetching to eliminate perceived delay
- Show cached content immediately, refresh in background
- Preload tab content on app startup

### Recommendations

**Priority: Make Tab Switching Feel Instant**

User feedback indicates tab switching should feel very fast. Even though API response is ~460ms (technically reasonable), the UX feels slow. Main tabs should switch instantly.

#### Best Practices Research Summary

Based on industry best practices for React Native tab navigation performance:

**1. Data Preloading & Caching (Highest Impact)**
- **Prefetch on app startup**: Load all main tab content immediately after initial site data loads
- **Stale-while-revalidate pattern**: Show cached content instantly, fetch fresh data in background
- **Cache tab content**: Store fetched data in memory/AsyncStorage for instant subsequent loads
- **Progressive enhancement**: Render cached/stale data immediately, update when fresh data arrives
- *Reference: React Navigation best practices, mobile UX patterns*

**2. Navigation Performance Optimization**
- **Enable native screens**: Use `react-native-screens` library for native navigation components (UIViewController/FragmentActivity)
- **Lazy load screens**: Load tab screens only when needed, but prefetch their data
- **Avoid deep nesting**: Keep navigation structure simple to reduce render tree complexity
- **Use React.memo**: Memoize tab components to prevent unnecessary re-renders
- *Reference: React Navigation docs, React Native performance guides*

**3. Component Rendering Optimization**
- **Memoization**: Use `useMemo` and `useCallback` to prevent expensive recalculations
- **Optimize state management**: Use Context API or state management library efficiently
- **Minimize re-renders**: Only update components when their specific data changes
- **Virtualized lists**: Use `FlatList`/`SectionList` for large content lists
- *Reference: React Native performance optimization guides*

**4. Loading UX Improvements**
- **Skeleton screens**: Replace spinner with skeleton UI for better perceived performance
- **Progressive loading**: Show page structure immediately, populate content as it loads
- **Smooth transitions**: Use native animations to make loading feel intentional
- **Optimistic UI**: Show previous content instantly, update seamlessly when new data arrives
- *Reference: Mobile UX best practices*

**5. Implementation Strategy (Recommended Order)**

**Phase 1: Quick Wins (Immediate Impact)**
1. Implement in-memory cache for tab content
2. Show cached content immediately when switching tabs
3. Fetch fresh data in background and update when ready
4. Add skeleton screens instead of spinner

**Phase 2: Prefetching (Better UX)**
1. Prefetch all main tab content after initial site data loads
2. Use React Query or similar for cache management
3. Implement stale-while-revalidate pattern

**Phase 3: Advanced Optimization**
1. Enable `react-native-screens` for native navigation
2. Optimize components with React.memo, useMemo, useCallback
3. Consider reducing initial API payload size
4. Implement virtualized lists if content grows large

**6. Technical Implementation Notes**
- Use React Query or SWR for caching/prefetching (industry standard)
- Store cache in memory for speed, AsyncStorage for persistence
- Prefetch should happen after critical path (homepage) loads
- Cache invalidation: refresh on pull-to-refresh or after time threshold
- Consider using `InteractionManager.runAfterInteractions()` for non-critical prefetching

### Status
- ✅ Investigation complete
- ✅ Logging infrastructure added
- ✅ Component remounting fixed
- ✅ Root cause identified (API delay, no caching)
- ✅ Phase 1: Quick Wins implemented (2026-01-02)

## Implementation Summary (2026-01-02)

### Phase 1: Quick Wins - COMPLETED ✅

**Implemented Features:**
1. **In-memory page cache** (`lib/pageCache.ts`)
   - Cache TTL: 5 minutes
   - Stores page data with timestamps
   - Supports stale-while-revalidate pattern

2. **Cache-aware API functions** (`lib/api.ts`)
   - `getPageWithCache()`: Returns cached data immediately, fetches fresh data in background
   - `refreshPageInBackground()`: Updates cache with fresh data without blocking UI
   - Maintains backward compatibility with existing `getPage()` function

3. **Instant tab switching** (`components/TabScreen.tsx`)
   - Shows cached content immediately (<10ms) when available
   - No loading spinner for cached content
   - Background refresh updates UI when fresh data arrives
   - Comprehensive logging for performance monitoring

**Expected Performance Improvements:**
- **First visit**: ~460ms (unchanged - no cache available)
- **Subsequent visits**: <10ms (instant from cache)
- **Background refresh**: Updates UI seamlessly when fresh data arrives

**Files Modified:**
- `rn-mip-app/lib/pageCache.ts` (new file)
- `rn-mip-app/lib/api.ts` (added cache support)
- `rn-mip-app/components/TabScreen.tsx` (uses cached data immediately)

**Testing:**
- ✅ Created Maestro test: `maestro/flows/test-cache-performance.yaml`
- ✅ Verified on iOS simulator (iPhone 16 Plus)
- ✅ Performance measurements confirmed

### Test Results (2026-01-02)

**Performance Measurements:**
- **Before cache**: 460ms, 500ms, 449ms, 850ms (average ~550ms)
- **After cache (first load)**: 683ms (no cache available)
- **After cache (subsequent loads)**: 6ms, 7ms, 8ms (instant from cache)

**Performance Improvement:**
- **~100x faster** for cached content (from ~550ms to ~7ms)
- **Instant tab switching** achieved (<10ms perceived delay)
- **Background refresh** works seamlessly (475ms, non-blocking)

**Log Verification:**
```
[PageCache] Cache hit for UUID: uezb3178BtP3oGuU (age: 2426ms)
[TabScreen] getPageWithCache completed at ..., duration: 6ms, fromCache: true
[TabScreen] Data from cache - instant display (6ms), background refresh in progress
[API] Background refresh completed for UUID: uezb3178BtP3oGuU, duration: 475ms
```

**Status:** ✅ **VERIFIED AND WORKING**

**How to Verify:**
1. Launch app on iOS simulator
2. Navigate to Resources tab (first load - should take ~460ms)
3. Navigate back to Home
4. Navigate to Resources tab again (should load instantly from cache)
5. Check Metro logs for cache hit messages and timing

**Next Steps:**
- Verify on simulator and measure actual performance improvements
- Consider Phase 2 (prefetching) if further optimization needed

## Notes
- Issue discovered during testing of issue #002
- Resources page loads successfully but with noticeable delay
- Solution applies to all main tabs (Resources, Chapters, Connect, Give, About)

## Research Sources
- React Navigation best practices (reactnavigation.org)
- React Native performance optimization guides (makeuseof.com, medium.com)
- Mobile UX patterns for tab navigation
- Industry standards for stale-while-revalidate caching patterns

