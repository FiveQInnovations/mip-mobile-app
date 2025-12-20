# Mobile API Prototype

A lightweight Astro frontend to validate the `wsp-mobile` API endpoints before building the React Native mobile app.

## Purpose

This prototype proves out:
- API endpoint responses and data structures
- Menu navigation flow
- Content page rendering
- Collection displays
- Video/audio playback
- Error handling

## Prerequisites

- Node.js 18+
- `ws-ffci-copy` DDEV site running (or update `PUBLIC_API_BASE` in `.env`)

## Setup

```bash
npm install
```

## Development

```bash
npm run dev
```

Opens at `http://localhost:4321`

## API Endpoints Tested

- `GET /mobile-api` - Site data and menu
- `GET /mobile-api/menu` - Menu items
- `GET /mobile-api/page/{uuid}` - Page content (content/collection/collection-item)

## Project Structure

```
src/
├── layouts/
│   └── MobileLayout.astro    # App shell with header/nav
├── pages/
│   ├── index.astro           # Home page
│   └── page/
│       └── [uuid].astro      # Dynamic page router
├── components/
│   ├── Navigation.astro     # Bottom nav bar
│   ├── ContentView.astro     # HTML content renderer
│   ├── CollectionGrid.astro  # Collection grid view
│   ├── VideoPlayer.astro     # Video player
│   └── AudioPlayer.astro     # Audio player
└── lib/
    └── api.ts                # API client functions
```

## Configuration

Set `PUBLIC_API_BASE` in `.env` to point to your Kirby site:

```
PUBLIC_API_BASE=https://ws-ffci-copy.ddev.site
```

## Testing

This project uses Cypress for end-to-end testing. Tests are organized into unit tests (mocked API) and integration tests (real API).

### Prerequisites

- Astro dev server running: `npm run dev`
- For integration tests: DDEV site `ws-ffci-copy` must be running

### Running Tests

```bash
# Run all tests (unit + integration)
npm run test

# Run tests with browser visible
npm run test:headed

# Open Cypress UI for interactive testing
npm run test:open

# Run only integration tests (requires DDEV site)
npm run test:integration

# Run only unit tests (mocked API, no DDEV required)
npm run test:unit
```

### Test Structure

- **Unit Tests**: `cypress/e2e/*.cy.ts` - Use mocked API responses
- **Integration Tests**: `cypress/e2e/integration/*.cy.ts` - Use real API from DDEV site

See [integration-tests.md](./docs/integration-tests.md) for more details on integration testing.

## Limitations

This is a proof of concept. Mobile-specific features not included:
- Native video/audio players (uses browser HTML5)
- Firebase Analytics (console.log events)
- Offline support
- Native navigation transitions
