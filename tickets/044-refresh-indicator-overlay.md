---
status: in-progress
area: rn-mip-app
phase: nice-to-have
created: 2026-01-02
---

# Add Refresh Indicator During Background Refresh

## Context
The app uses a stale-while-revalidate caching pattern where cached content is shown immediately while fresh data loads in the background. Users should see a subtle indicator that content is being refreshed.

## Tasks
- [ ] Design subtle refresh indicator (small spinner, progress bar, etc.)
- [ ] Show indicator in TabScreen when `refreshing` state is true
- [ ] Position indicator unobtrusively (header, bottom, etc.)
- [ ] Hide indicator when background refresh completes
- [ ] Test indicator visibility without being distracting
- [ ] **Create HomeScreen skeleton loader** - Replace spinner with skeleton for initial load
- [ ] **Add testing mechanism** - Dev tool or manual trigger to test refresh functionality

## Notes
- TabScreen already has `refreshing` state that tracks background refresh
- Should be subtle - not block content or feel like loading
- Could be a small spinner in the header or a thin progress bar

## Research Findings

### Current Implementation

**TabScreen (`components/TabScreen.tsx`):**
- Has `refreshing` state (line 94) that tracks background refresh
- Uses `SkeletonLoader` component for initial loading (when `loading` is true)
- `refreshing` state is set to `true` when cached data is shown and background refresh starts (line 153)
- `refreshing` state is set to `false` when background refresh completes (line 163)
- Currently **no UI indicator** is shown when `refreshing` is true
- Background refresh happens via `refreshPromise` from `getPageWithCache()` API call

**HomeScreen (`components/HomeScreen.tsx`):**
- Receives `siteData` as props from `TabNavigator` - does not have its own refresh mechanism
- No loading state management - data is passed down from parent
- User mentioned seeing a spinner for ~0.5s on initial load - this is likely from `TabNavigator`'s `ActivityIndicator` (line 116)

**TabNavigator (`components/TabNavigator.tsx`):**
- Shows `ActivityIndicator` during initial `siteData` load (lines 113-119)
- This is the spinner the user sees on home screen load
- Once `siteData` loads, it's passed to `HomeScreen` as props
- No refresh mechanism for `siteData` after initial load

### User Requirements
1. **Loading skeleton for home screen** - Replace spinner with skeleton loader (at least for home screen)
2. **Testing mechanism** - Need a way to test refresh functionality since there's not much to refresh in the app

### Refresh Mechanism Details

**API Caching (`lib/api.ts`):**
- `getPageWithCache()` implements stale-while-revalidate pattern
- Returns cached data immediately if available, then fetches fresh data in background
- Returns `refreshPromise` when background refresh is happening (lines 194-221)
- Cache TTL is 5 minutes (`lib/pageCache.ts`, line 12)

**Testing Refresh:**
- Dev tool button exists in `HomeScreen` to clear cache (`clearAllCache()`)
- Located at bottom of homepage in "🔧 Dev Tools (Temp)" section (lines 236-253)
- Can use this to clear cache and trigger refresh on next navigation
- Cache can also be cleared via Metro console: `require('./lib/pageCache').clearAllCache()`

### Implementation Considerations

**For TabScreen:**
- `refreshing` state already exists and is properly managed
- Need to add UI indicator when `refreshing === true`
- Options:
  - Small spinner in header (unobtrusive)
  - Thin progress bar at top of screen
  - Subtle overlay indicator
- Should not block content or feel like loading (user can see cached content)

**For HomeScreen:**
- Currently no refresh mechanism - receives static props
- User wants skeleton loader instead of spinner for initial load
- Options:
  - Replace `TabNavigator`'s `ActivityIndicator` with skeleton loader
  - Create `HomeScreenSkeleton` component similar to `TabScreen`'s `SkeletonLoader`
  - Show skeleton while `TabNavigator` is loading `siteData`

**Testing Refresh Functionality:**
- Use existing dev tool button to clear cache
- Navigate to a tab that was previously cached
- Should see refresh indicator while background refresh happens
- Could add a dev tool button to manually trigger refresh for testing
- Could add a way to force refresh of `siteData` in `TabNavigator`

### Related Components

**SkeletonLoader (`components/TabScreen.tsx`, lines 10-84):**
- Already exists for `TabScreen` initial loading
- Uses animated opacity for shimmer effect
- Could be adapted for `HomeScreen` skeleton
- Shows header accent bar, title skeleton, and content line skeletons

**ActivityIndicator Usage:**
- Used in: `TabNavigator`, `ErrorScreen`, `SplashScreen`, `PageScreen`, `search.tsx`
- All use `size="large"` except `ErrorScreen` which uses `size="small"`
- Could replace with skeleton loaders for better UX

### Recommendations

1. **HomeScreen Skeleton Loader:**
   - Create `HomeScreenSkeleton` component similar to `TabScreen`'s `SkeletonLoader`
   - Replace `TabNavigator`'s `ActivityIndicator` with skeleton when loading `siteData`
   - Show skeleton that matches HomeScreen layout (logo area, cards, featured section)

2. **TabScreen Refresh Indicator:**
   - Add subtle indicator when `refreshing === true`
   - Position in header (small spinner icon) or as thin progress bar at top
   - Use config primary color for consistency
   - Ensure it doesn't block content or feel intrusive

3. **Testing Refresh:**
   - Keep existing dev tool button for cache clearing
   - Add dev tool button to manually trigger refresh of current tab
   - Document testing workflow: clear cache → navigate to tab → observe refresh indicator
   - Consider adding refresh button to dev tools section

4. **Future Enhancement:**
   - Consider adding pull-to-refresh (`RefreshControl`) for manual refresh
   - Could trigger refresh of `siteData` in `TabNavigator` when user pulls down on home screen
