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
- `about-navigation.cy.ts` - Tests navigation from Home to Resources page
- `chapters-navigation.cy.ts` - Tests navigation from Home to Chapters page
- `internal-link-navigation.cy.ts` - Tests internal link navigation within content pages

### Test Cases by File

#### `video-playback.cy.ts`
- `can access the real API` - Verifies API endpoint is accessible
- `can navigate to pages from API` - Tests navigation using real page UUIDs
- `can navigate to menu pages` - Tests navigation from menu items
- `verifies video player component renders when video data exists` - Verifies VideoPlayer component renders for pages with video content

#### `audio-playback.cy.ts`
- `can access the real API` - Verifies API endpoint is accessible
- `can navigate to pages from API` - Tests navigation using real page UUIDs
- `verifies audio player component renders when audio data exists` - Verifies AudioPlayer component renders for pages with audio content
- `verifies audio metadata displays correctly when available` - Tests audio title, artwork, and duration display

#### `about-navigation.cy.ts`
- `should navigate from Home to Resources page and verify content loads` - Tests bottom navigation and verifies page content structure

#### `chapters-navigation.cy.ts`
- `should navigate from Home to Chapters page and verify content loads` - Tests navigation to Chapters page and verifies content loads

#### `internal-link-navigation.cy.ts`
- `should navigate to Resources page and click internal link without leaving app` - Tests that internal links navigate within the app (not to external Kirby site)

## Test Approach

Integration tests:
1. **Make real API requests** using `cy.request()` with `failOnStatusCode: false` to gracefully handle API unavailability
2. **Navigate to real pages** using actual page UUIDs from the API
3. **Verify component rendering** based on actual API response data
4. **Skip gracefully** when:
   - API is unavailable (logs status and skips test)
   - Expected content types aren't available (logs and continues)
5. **Test navigation flows** including bottom navigation, menu navigation, and internal link navigation
6. **Verify content structure** matches API response data (titles, content, metadata)

## Example Test Flow

### Video Player Test

```typescript
it('verifies video player component renders when video data exists', () => {
  // 1. Fetch real API data with graceful error handling
  cy.request({
    url: 'https://ws-ffci-copy.ddev.site/mobile-api',
    failOnStatusCode: false
  }).then((response) => {
    if (response.status !== 200) {
      cy.log('DDEV API unavailable, skipping test');
      return;
    }
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
            cy.get('[data-testid="video-player"]', { timeout: 10000 }).should('be.visible');
          } else {
            cy.log('No video content found on this page, skipping video player test');
          }
        });
    }
  });
});
```

### Navigation Test

```typescript
it('should navigate from Home to Resources page and verify content loads', () => {
  // 1. Verify we're on the Home page
  cy.url().should('eq', Cypress.config().baseUrl + '/');
  
  // 2. Navigate via bottom navigation (Action Hub sites)
  cy.get('[data-testid="bottom-nav"]').should('be.visible');
  cy.contains('[data-testid="bottom-nav"] a', 'Resources')
    .should('be.visible')
    .click();
  
  // 3. Verify URL changed and content loaded
  cy.url().should('include', '/page/uezb3178BtP3oGuU');
  cy.get('main', { timeout: 10000 }).should('be.visible');
  cy.get('h1').should('contain', 'Resources');
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
- Tests use `failOnStatusCode: false` and should skip gracefully when API is unavailable
- If tests fail instead of skipping, ensure DDEV site is running: `ddev list`
- Check API URL: `curl https://ws-ffci-copy.ddev.site/mobile-api`
- Verify network connectivity
- Check test logs for skip messages: `cy.log('DDEV API unavailable, skipping test')`

### Tests skip expected content
- The real API may not have video/audio content on all pages
- Tests are designed to skip gracefully when content isn't available
- Check API response to see what content types exist

### Tests timeout
- Ensure Astro dev server is running: `npm run dev`
- Check that `baseUrl` in `cypress.config.ts` matches dev server port (default: `http://localhost:4321`)
- Tests use `{ timeout: 10000 }` for most assertions - increase if needed
- Verify page UUIDs in tests match actual API responses if navigation tests fail

## CI/CD Considerations

Integration tests require:
- DDEV site to be running (or accessible)
- Network access to the API endpoint
- Longer execution time

Consider:
- Running integration tests separately from unit tests
- Using a dedicated test environment
- Running integration tests on a schedule rather than every commit
