---
status: backlog
area: rn-mip-app
phase: core
created: 2026-01-02
---

# Prayer Request Form Handling

## Context
The Prayer Request quick task on the home screen currently does nothing when tapped. The button calls `handleNavigate('Prayer Request')` but there's no matching menu item, and even if there were, forms built with Vue.js require JavaScript to render and submit.

Per the spec, forms can be handled via:
- **Option A**: Full page WebView — load the actual website URL instead of just HTML content
- **Option B**: Link out — prompt user to open form in Safari/Chrome

## Research Findings

### Prayer Request Page Details
- **Page URL**: `https://ffci.fiveq.dev/prayer-request`
- **Page UUID**: `LP0WESdsu4tWpbGA`
- **Form UUID**: `iTQ9ZV8UId5Chxew` (referenced in content as `page://iTQ9ZV8UId5Chxew`)
- **Form location in content**: `content/forms/2_prayer-request/form.txt`

### Form Fields (Prayer Request)
The form includes:
1. First Name (required)
2. Last Name (optional)
3. Email Address (required)
4. Your Prayer Request (textarea, required)
5. International prayer team opt-in (select, required)

### How wsp-forms Works
1. **Rendering**: Forms are Vue.js components that fetch field definitions via `.json` endpoint
   - Example: `https://ffci.fiveq.dev/forms/prayer-request.json`
2. **Client-side**: `window.connectForm(formUrl, formId, returnUrl)` initializes the Vue app
3. **Submission**: Standard POST to the form page URL with:
   - CSRF token (required)
   - Honeypot field (spam protection)
   - All form field values
4. **Response**: Redirects to `return_url?success=true&fid=<form-uid>`

### Why Native HTML Won't Work
- The page content includes a `type: "form"` block, but renders as empty HTML since:
  - Form fields are loaded via JavaScript fetch to `.json` endpoint
  - Vue.js renders the form fields dynamically
  - CSRF token is generated server-side and must match session
  - Honeypot randomization happens at page load

### Recommended Approach: Option B (Link Out)
**Reasoning:**
1. **Simpler to implement** - Just use `Linking.openURL()` which is already working in the app
2. **Form works perfectly** - Full website experience with all styles, validation, CSRF
3. **Consistent UX** - Similar pattern already used for "Donate" button (opens external URL)
4. **No authentication complexity** - WebView would need to handle cookies/sessions
5. **Faster delivery** - No need to create WebView screen, handle navigation, loading states

**Alternative (Option A - WebView) considerations:**
- Would keep user in-app (better UX in theory)
- But requires: WebView component, back navigation, loading states, error handling
- Potential issues: Cookie handling, viewport sizing, form POST behavior
- Forms feel "webby" anyway per spec doc

### Implementation Details

**Current code in HomeScreen.tsx:**
```typescript
const handleNavigate = (label: string, fallbackUrl?: string) => {
  const target = findMenuItemByLabel(label);
  // ... menu item logic ...
  if (fallbackUrl) {
    Linking.openURL(fallbackUrl);
  }
};

// Quick task button:
{
  key: 'prayer',
  label: 'Prayer Request',
  onPress: () => handleNavigate('Prayer Request'), // No fallback URL!
}
```

**Fix needed:**
```typescript
{
  key: 'prayer',
  label: 'Prayer Request',
  onPress: () => handleNavigate('Prayer Request', 'https://ffci.fiveq.dev/prayer-request'),
}
```

### API Flag Status
- `PageData` interface already has `has_form?: boolean` (line 48 in api.ts)
- **NOT implemented** in wsp-mobile plugin - would need ticket 019 to add
- For this ticket, hardcoded fallback URL is simplest

### Related URLs (for ticket 018)
- **Chaplain Request Page**: `https://ffci.fiveq.dev/chaplain-request`
- **Chaplain Request UUID**: `M9GmWmqtvlpMuoLP`
- **Chaplain Request Form UUID**: `IPEdk3YSkRMj8sYw`

## Tasks
- [x] Review the Kirby site code and the wsp-forms plugin to understand how forms are structured and handled
- [x] Determine which form handling approach to use (WebView vs link out)
- [x] Identify the Prayer Request form URL on the FFCI website
- [ ] Add fallback URL to Prayer Request quick task button
- [ ] Test form opens correctly in Safari/Chrome
- [ ] Verify form submission works from external browser
- [ ] Ensure user can return to app after submission

## Implementation Notes
- The fix is a one-line change: add fallback URL to the onPress handler
- `react-native-webview` is already installed if we later want Option A
- Config has `apiBaseUrl: "https://ffci.fiveq.dev"` - could use this instead of hardcoding

## Notes
- Related to ticket 018 (Chaplain Request) - same pattern applies
- Related to ticket 019 (Form detection API flag) - nice-to-have for auto-detection
- Related to ticket 020 (WebView fallback for forms) - alternative approach if link-out is insufficient
