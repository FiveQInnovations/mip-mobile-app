/**
 * Integration Test: Internal Link Navigation
 * 
 * Tests that internal links in content pages navigate within the Astro app
 * instead of breaking out to the external Kirby site.
 * 
 * Uses the REAL API from ws-ffci-copy.ddev.site
 * Tests navigation from Resources page which has Related Pages with internal links.
 * 
 * Prerequisites:
 * - DDEV site ws-ffci-copy must be running
 * - Astro dev server must be running on localhost:4321
 * - API must be accessible at https://ws-ffci-copy.ddev.site
 */

describe('Internal Link Navigation - Integration Test', () => {
  beforeEach(() => {
    // No intercepts - we're using the real API
    cy.visit('/');
  });

  it('should navigate to Resources page and click internal link without leaving app', () => {
    // Step 1: Navigate to Resources page
    // FFCI sites use Action Hub, so navigate via bottom nav
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
    
    // Step 2: Verify we're on the Resources page
    cy.url().should('include', '/page/uezb3178BtP3oGuU');
    cy.get('main', { timeout: 10000 }).should('be.visible');
    
    // Step 3: Find and click the "FFC Media Ministry" internal link
    // Resources page has "Related Pages" section with internal links
    cy.get('main', { timeout: 10000 }).should('be.visible');
    
    // Find the specific "FFC Media Ministry" link
    cy.get('main').within(() => {
      // Look for the link containing "FFC Media Ministry" text
      cy.contains('a', 'FFC Media Ministry')
        .scrollIntoView()
        .should('exist')
        .then(($link) => {
          const href = $link.attr('href') || '';
          cy.log(`Found FFC Media Ministry link: ${href}`);
          
          // Verify it's an internal link (starts with /page/)
          expect(href).to.match(/^\/page\/[a-zA-Z0-9]+/);
          
          // Step 4: Click the internal link (use force if needed due to clipping)
          cy.wrap($link).click({ force: true });
        });
    });
    
    // Step 5: Verify we stayed in the app (URL should be /page/{uuid} format)
    cy.url({ timeout: 10000 }).should('include', '/page/');
    cy.url().should('not.include', 'ddev.site');
    
    // Step 6: Verify new page content loaded
    cy.get('main', { timeout: 10000 }).should('be.visible');
    cy.get('main').should('not.contain', 'Error Loading Page');
    
    // Verify we're on a different page (URL changed from Resources page)
    cy.url().should('not.include', 'uezb3178BtP3oGuU');
  });
});
