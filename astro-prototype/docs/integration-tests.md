# Integration Tests

Integration tests verify that the Astro prototype works correctly with the **real API** from the DDEV site (`ws-ffci-copy.ddev.site`).

## Overview

Unlike unit tests which use mocked API responses, integration tests:
- Connect to the real API endpoint
- Test actual API responses and data structures
- Verify end-to-end functionality with real data
- Ensure compatibility with the production API

## Prerequisites

1. **DDEV site must be running**:
   ```bash
   cd sites/ws-ffci-copy
   ddev start
   ```

2. **Astro dev server must be running**:
   ```bash
   cd astro-prototype
   npm run dev
   ```

3. **API must be accessible** at `https://ws-ffci-copy.ddev.site`

## Running Integration Tests

```bash
# Run all integration tests
npm run test:integration

# Run specific integration test file
npm run test -- --spec "cypress/e2e/integration/video-playback.cy.ts"
```

## Test Structure

Integration tests are located in `cypress/e2e/integration/`:

- `video-playback.cy.ts` - Tests video player functionality with real API
- `audio-playback.cy.ts` - Tests audio player functionality with real API

## Test Approach

Integration tests:
1. **Make real API requests** using `cy.request()` to verify API accessibility
2. **Navigate to real pages** using actual page UUIDs from the API
3. **Verify component rendering** based on actual API response data
4. **Skip gracefully** when expected content types aren't available

## Example Test Flow

```typescript
it('verifies video player component renders when video data exists', () => {
  // 1. Fetch real API data
  cy.request('GET', 'https://ws-ffci-copy.ddev.site/mobile-api')
    .then((response) => {
      const menu = response.body.menu;
      
      // 2. Check each page for video content
      if (menu && menu.length > 0) {
        const testPageUuid = menu[0].page.uuid;
        
        // 3. Fetch page data
        cy.request('GET', `https://ws-ffci-copy.ddev.site/mobile-api/page/${testPageUuid}`)
          .then((pageResponse) => {
            const pageData = pageResponse.body;
            
            // 4. If video exists, verify player renders
            if (pageData.page_type === 'collection-item' && 
                pageData.type === 'video' && 
                pageData.data?.video) {
              cy.visitPage(testPageUuid);
              cy.get('[data-testid="video-player"]').should('be.visible');
            }
          });
      }
    });
});
```

## Differences from Unit Tests

| Aspect | Unit Tests | Integration Tests |
|--------|-----------|-------------------|
| **API** | Mocked fixtures | Real API |
| **Location** | `cypress/e2e/*.cy.ts` | `cypress/e2e/integration/*.cy.ts` |
| **Intercepts** | Uses `cy.intercept()` | No intercepts |
| **Dependencies** | None | Requires DDEV site running |
| **Speed** | Fast | Slower (network requests) |
| **Reliability** | Stable | May vary with API changes |

## When to Use Integration Tests

Use integration tests to:
- ✅ Verify API compatibility
- ✅ Test with real data structures
- ✅ Validate end-to-end workflows
- ✅ Catch API contract changes

Use unit tests to:
- ✅ Test component logic in isolation
- ✅ Fast feedback during development
- ✅ Test edge cases with custom data
- ✅ CI/CD pipeline (no external dependencies)

## Troubleshooting

### Tests fail with "API not accessible"
- Ensure DDEV site is running: `ddev list`
- Check API URL: `curl https://ws-ffci-copy.ddev.site/mobile-api`
- Verify network connectivity

### Tests skip expected content
- The real API may not have video/audio content on all pages
- Tests are designed to skip gracefully when content isn't available
- Check API response to see what content types exist

### Tests timeout
- Ensure Astro dev server is running: `npm run dev`
- Check that `baseUrl` in `cypress.config.ts` matches dev server port
- Increase timeout if needed: `{ timeout: 15000 }`

## CI/CD Considerations

Integration tests require:
- DDEV site to be running (or accessible)
- Network access to the API endpoint
- Longer execution time

Consider:
- Running integration tests separately from unit tests
- Using a dedicated test environment
- Running integration tests on a schedule rather than every commit
