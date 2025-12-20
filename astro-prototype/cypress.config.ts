import { defineConfig } from 'cypress';

export default defineConfig({
  e2e: {
    baseUrl: 'http://localhost:4321',
    supportFile: 'cypress/support/e2e.ts',
    fixturesFolder: 'cypress/fixtures',
  },
  viewportWidth: 375,
  viewportHeight: 812,
  video: false,
  screenshotOnRunFailure: true,
});
