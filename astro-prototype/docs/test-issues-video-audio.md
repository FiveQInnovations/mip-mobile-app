# Video and Audio Player Test Issues

## Goal

The goal is to verify that the VideoPlayer and AudioPlayer components work correctly with:
- **VideoPlayer**: YouTube embeds (using lite-youtube-embed), Vimeo embeds, and direct video URLs
- **AudioPlayer**: Full playback controls with artwork, title, and duration display

## What Was Implemented

### Components
- ✅ **VideoPlayer.astro**: Enhanced to support YouTube (lite-youtube-embed), Vimeo (iframe), and direct video URLs (HTML5 player)
- ✅ **AudioPlayer.astro**: Enhanced with artwork display, title, duration formatting, and improved layout
- ✅ Both components include `data-testid` attributes for Cypress testing

### Test Fixtures
Created test fixtures in `cypress/fixtures/`:
- `video-youtube.json` - YouTube video page data
- `video-vimeo.json` - Vimeo video page data  
- `video-direct.json` - Direct video URL page data
- `audio-item.json` - Audio page with full metadata

### Test Files
- `cypress/e2e/video-playback.cy.ts` - 8 tests for video playback
- `cypress/e2e/audio-playback.cy.ts` - 8 tests for audio playback

## Current Issue - RESOLVED

The tests were failing because Cypress intercepts cannot intercept server-side requests to external domains. Astro SSR requests happen on the Node.js server (not in the browser), so Cypress cannot intercept them when they go to external URLs like `https://ws-ffci-copy.ddev.site`.

### Solution Applied

1. **Removed `cy.wait()` calls**: Since SSR requests can't be intercepted, we removed the `cy.wait()` calls that were timing out.

2. **Direct element verification**: Tests now verify that the page renders correctly by checking for elements with appropriate timeouts, rather than waiting for network intercepts.

3. **Intercepts still set up**: Intercepts are still configured before `cy.visit()` in case they can catch any client-side requests, but we don't wait for them.

### Note on SSR Testing

- Cypress intercepts work for browser requests but not for server-side requests to external domains
- The tests verify rendered output rather than network requests
- Intercepts are set up as a best-effort attempt to mock API responses

## What Needs to Be Done

### Investigation Steps

1. **Verify Intercept Pattern**: Check if the URL pattern `**/mobile-api/page/*` matches the actual requests. Look at:
   - Network tab in Cypress during test runs
   - Screenshots from failed tests
   - Console logs

2. **Check API Call Timing**: Determine when API calls are made:
   - During SSR (server-side)
   - On page load (client-side)
   - Both

3. **Compare with Working Tests**: Review how `content-page.cy.ts` and `navigation.cy.ts` successfully intercept API calls and replicate that pattern.

### Potential Solutions

1. **Use `cy.intercept()` before `cy.visit()`**: Ensure intercepts are registered before navigation
   ```typescript
   beforeEach(() => {
     cy.intercept('GET', '**/mobile-api', { fixture: 'mock-api-responses.json' }).as('siteData');
   });
   
   it('test', () => {
     cy.intercept('GET', '**/mobile-api/page/*', { fixture: 'video-youtube.json' }).as('pageData');
     cy.visit('/page/video-item-uuid');
     // Wait for intercepts...
   });
   ```

2. **Handle SSR Requests**: If API calls happen during SSR, intercepts may need to be set up differently or tests may need to wait for client-side hydration.

3. **Add Explicit Waits**: After `cy.visit()`, wait for specific elements or network requests before asserting.

4. **Check Element Rendering**: Verify that components are actually rendering by checking:
   - Page HTML structure
   - Whether web components are registered
   - If CSS is loading properly

### Test Structure Reference

Working test example (`content-page.cy.ts`):
```typescript
beforeEach(() => {
  cy.intercept('GET', '**/mobile-api', { fixture: 'homepage-navigation.json' }).as('siteData');
});

it('displays page title', () => {
  cy.intercept('GET', '**/mobile-api/page/valid-content-uuid', { fixture: 'page-content.json' }).as('pageData');
  cy.visitPage('valid-content-uuid');
  cy.wait('@siteData');
  cy.wait('@pageData');
  cy.get('h1').should('be.visible');
});
```

## Files to Review

- `cypress/e2e/video-playback.cy.ts` - Video player tests
- `cypress/e2e/audio-playback.cy.ts` - Audio player tests
- `cypress/e2e/content-page.cy.ts` - Working reference test
- `cypress/fixtures/video-*.json` - Video test data
- `cypress/fixtures/audio-item.json` - Audio test data
- `src/components/VideoPlayer.astro` - Video component implementation
- `src/components/AudioPlayer.astro` - Audio component implementation
- `src/pages/page/[uuid].astro` - Page component that renders players

## Running Tests

```bash
cd astro-prototype
npm run test              # Run all tests headless
npm run test:open        # Open Cypress UI
npm run test:headed      # Run with browser visible
```

## Expected Outcome

Once fixed, all tests should:
- ✅ Successfully intercept API calls
- ✅ Find and verify video/audio player elements
- ✅ Verify YouTube/Vimeo embeds render correctly
- ✅ Verify audio metadata displays properly
- ✅ Pass consistently in CI/CD

## Notes

- The component implementations are complete and working
- The test fixtures match the expected API response structure
- The issue is primarily with test setup/timing, not component functionality
- Consider checking Cypress screenshots in `cypress/screenshots/` to see what's actually rendered during failures

## Integration Tests Solution

**✅ Solution Implemented**: Created integration tests that use the real API instead of mocked responses.

Integration tests are located in `cypress/e2e/integration/` and can be run with:
```bash
npm run test:integration
```

These tests:
- Use the real API from `ws-ffci-copy.ddev.site`
- Don't require intercepts (no SSR interception issues)
- Verify actual API responses and component rendering
- Pass successfully with real data

See [integration-tests.md](./integration-tests.md) for full documentation.

**Status**: Integration tests are passing ✅
