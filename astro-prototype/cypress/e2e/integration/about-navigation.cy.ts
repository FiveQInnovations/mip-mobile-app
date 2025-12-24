/**
 * Integration Test: Navigation
 * 
 * High-level test that verifies navigation from Home page to a menu page
 * Uses the REAL API from ws-ffci-copy.ddev.site
 * 
 * Prerequisites:
 * - DDEV site ws-ffci-copy must be running
 * - Astro dev server must be running on localhost:4321
 * - API must be accessible at https://ws-ffci-copy.ddev.site
 */

describe('Navigation - Integration Test', () => {
  beforeEach(() => {
    // No intercepts - we're using the real API
    cy.visit('/');
  });

  it('should navigate from Home to Resources page and verify content loads', () => {
    // Step 1: Verify we're on the Home page
    cy.url().should('eq', Cypress.config().baseUrl + '/');
    
    // Step 2: Navigate to Resources page
    // FFCI sites use Action Hub, so navigate via bottom nav
    // Expected nav items: Home, Resources, Chapters, Connect, Give
    cy.get('body').then(($body) => {
      const hasActionHub = $body.find('[data-testid="quick-tasks"]').length > 0;
      
      if (hasActionHub) {
        // Use bottom navigation for Action Hub sites
        cy.get('[data-testid="bottom-nav"]').should('be.visible');
        cy.contains('[data-testid="bottom-nav"] a', 'Resources')
          .should('be.visible')
          .click();
      } else {
        // Fallback to menu-item for navigation type
        cy.contains('[data-testid="menu-item"]', 'Resources')
          .should('be.visible')
          .click();
      }
    });
    
    // Step 3: Verify URL changed to Resources page
    cy.url().should('include', '/page/uezb3178BtP3oGuU');
    
    // Step 4: Verify the page loads with real text content
    // Look for actual text content from the API response
    cy.get('main', { timeout: 10000 }).should('be.visible');
    
    // Verify the page title contains "Resources"
    cy.get('main').within(() => {
      cy.get('h1').should('contain', 'Resources');
    });
    
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
    
    // Step 5: Verify that related pages show proper titles (not just "default")
    // Pages with children should display with proper titles
    cy.get('main').then(($main) => {
      // Check if "Related Pages" section exists
      if ($main.find('h2:contains("Related Pages")').length > 0) {
        // Verify that related page links have meaningful text, not just "default"
        cy.get('main').within(() => {
          cy.get('a[href*="/page/"]').each(($link) => {
            const linkText = $link.text().trim();
            // Links should not just say "default" - they should have titles or meaningful text
            expect(linkText).to.not.equal('default');
            expect(linkText).to.not.equal('');
          });
        });
      }
    });
  });
});
