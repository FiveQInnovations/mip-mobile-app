/**
 * Integration Test: Chapters Navigation
 * 
 * High-level test that verifies navigation from Home page to Chapters page
 * Uses the REAL API from ws-ffci-copy.ddev.site
 * 
 * Prerequisites:
 * - DDEV site ws-ffci-copy must be running
 * - Astro dev server must be running on localhost:4321
 * - API must be accessible at https://ws-ffci-copy.ddev.site
 */

describe('Chapters Navigation - Integration Test', () => {
  beforeEach(() => {
    // No intercepts - we're using the real API
    cy.visit('/');
  });

  it('should navigate from Home to Chapters page and verify content loads', () => {
    // Step 1: Verify we're on the Home page
    cy.url().should('eq', Cypress.config().baseUrl + '/');
    
    // Step 2: Find and click the 'Chapters' menu item
    cy.contains('[data-testid="menu-item"]', 'Chapter')
      .should('be.visible')
      .click();
    
    // Step 3: Verify URL changed to Chapters page
    cy.url().should('include', '/page/pik8ysClOFGyllBY');
    
    // Step 4: Verify the page loads with real text content
    // Look for actual text content from the API response
    cy.get('main', { timeout: 10000 }).should('be.visible');
    
    // Verify there's actual text content (not just error messages)
    cy.get('main').should('not.contain', 'Error Loading Page');
    cy.get('main').should('not.contain', 'not a function');
    
    // Verify there's some real content text visible
    // This should contain actual page content from the API
    cy.get('main').within(() => {
      // Look for headings or paragraphs with actual content
      cy.get('h1, h2, h3, p').should('exist');
      // Verify at least one element has non-empty text
      cy.get('h1, h2, h3, p').first().should('not.be.empty');
    });
  });
});
