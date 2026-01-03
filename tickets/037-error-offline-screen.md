---
status: backlog
area: rn-mip-app
phase: core
created: 2026-01-02
---

# Error/Offline Screen Design

## Context
The spec requires a friendly error/offline screen with retry functionality. The current implementation shows basic error text, but needs a polished, user-friendly design.

## Tasks
- [ ] Create reusable `ErrorScreen` component in `components/ErrorScreen.tsx`
- [ ] Design friendly error screen UI (icon, message, retry button)
- [ ] Implement different messages for different error types (network, 404, server, etc.)
- [ ] Style consistently with app theme colors
- [ ] Add retry button with loading state
- [ ] Replace existing error UI in TabNavigator, TabScreen, and PageScreen
- [ ] Test on iOS and Android

## Notes
- Per spec: "Friendly error message, Retry button"
- Current implementation has basic error text in TabScreen and PageScreen
- Should feel polished and "app-like" not just developer error text

---

## Research Findings

### Current Error Handling (3 locations with duplicate UI)

**1. TabNavigator.tsx (lines 70-78)** - Site data loading errors
```tsx
if (error) {
  return (
    <View style={styles.container}>
      <Text style={styles.errorText}>API Error: {error}</Text>
      <Text style={styles.retryText} onPress={loadData}>
        Tap to retry
      </Text>
    </View>
  );
}
```

**2. TabScreen.tsx (lines 128-136)** - Page loading errors
```tsx
if (error) {
  return (
    <View style={styles.container}>
      <Text style={styles.errorText}>Error: {error}</Text>
      <Text style={styles.retryText} onPress={loadPage}>
        Tap to retry
      </Text>
    </View>
  );
}
```

**3. PageScreen.tsx (lines 44-52)** - Same as TabScreen

### Error Types to Handle

The app can encounter these error types:

| Error Type | Source | Current Message | Friendly Message |
|------------|--------|-----------------|------------------|
| Network offline | `TypeError: Network request failed` | Raw error | "No internet connection" |
| API unavailable | `ApiError` with status 5xx | "Failed to fetch (500)" | "Something went wrong on our end" |
| Page not found | `ApiError` with status 404 | "Failed to fetch (404)" | "Page not found" |
| Unauthorized | `ApiError` with status 401/403 | "Failed to fetch (401)" | "Unable to access content" |
| Unknown error | Any other error | Raw error message | "Something went wrong" |

### ApiError Class (lib/api.ts lines 51-61)
```typescript
export class ApiError extends Error {
  status: number;
  url: string;
  constructor(message: string, status: number, url: string) {
    super(message);
    this.name = 'ApiError';
    this.status = status;
    this.url = url;
  }
}
```

### App Theme Colors (configs/ffci.json)
```json
{
  "primaryColor": "#D9232A",    // Red - for emphasis/CTAs
  "secondaryColor": "#024D91",  // Blue - links, accents
  "textColor": "#0f172a",       // Dark - body text
  "backgroundColor": "#f8fafc"  // Light gray - backgrounds
}
```

### Recommended Component API

```typescript
// components/ErrorScreen.tsx
interface ErrorScreenProps {
  error: Error | string;
  onRetry: () => void;
  retrying?: boolean;
}

// Helper function to classify errors
function getErrorType(error: Error | string): 'network' | 'not-found' | 'server' | 'generic' {
  if (error instanceof ApiError) {
    if (error.status === 404) return 'not-found';
    if (error.status >= 500) return 'server';
  }
  if (typeof error === 'string' && error.includes('Network request failed')) {
    return 'network';
  }
  if (error instanceof TypeError && error.message.includes('Network')) {
    return 'network';
  }
  return 'generic';
}
```

### UI Design Recommendations

**Layout Structure:**
```
┌─────────────────────────────────────┐
│                                     │
│           [Icon - 64px]             │
│                                     │
│        "Primary Message"            │
│         (20px, bold)                │
│                                     │
│   "Secondary description text"      │
│      (16px, gray, center)           │
│                                     │
│      ┌──────────────────┐           │
│      │   Retry Button   │           │
│      │   (with loader)  │           │
│      └──────────────────┘           │
│                                     │
└─────────────────────────────────────┘
```

**Error-specific content:**

| Type | Icon | Title | Description |
|------|------|-------|-------------|
| network | 📡 | "No Connection" | "Please check your internet connection and try again." |
| not-found | 🔍 | "Page Not Found" | "The page you're looking for doesn't exist or has been moved." |
| server | ⚠️ | "Something Went Wrong" | "We're having trouble connecting. Please try again in a moment." |
| generic | ❌ | "Unable to Load" | "There was a problem loading this content." |

### Optional: Network Detection with expo-network

Could add `expo-network` for proactive offline detection:
```bash
npx expo install expo-network
```

```typescript
import * as Network from 'expo-network';

// Check network state
const networkState = await Network.getNetworkStateAsync();
if (!networkState.isConnected) {
  // Show offline banner or screen
}

// Listen for changes
Network.addNetworkStateListener(({ isConnected }) => {
  // Update UI when connectivity changes
});
```

**Note:** This is optional for v1. The current approach of detecting offline via API errors is sufficient. `expo-network` would enable showing a banner *before* the user tries an action.

### Integration Points

After creating `ErrorScreen`, update these files:

1. **TabNavigator.tsx** - Replace lines 70-78
2. **TabScreen.tsx** - Replace lines 128-136  
3. **PageScreen.tsx** - Replace lines 44-52

Each location just needs:
```tsx
import { ErrorScreen } from './ErrorScreen';

// In the component:
if (error) {
  return <ErrorScreen error={error} onRetry={loadData} retrying={loading} />;
}
```

### Testing Considerations

1. **Simulate offline:** iOS Simulator → Features → Toggle Off "Allow Cellular Data" and disable WiFi
2. **Simulate 404:** Navigate to invalid UUID
3. **Simulate server error:** Temporarily modify apiBaseUrl to invalid host
4. **Maestro test:** Add `error-handling.yaml` flow per spec structure
