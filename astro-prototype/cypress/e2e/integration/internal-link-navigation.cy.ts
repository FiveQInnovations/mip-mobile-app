/**
 * Integration Test: Internal Link Navigation
 * 
 * Tests that internal links in content pages navigate within the Astro app
 * instead of breaking out to the external Kirby site.
 * 
 * Uses the REAL API from ws-ffci-copy.ddev.site
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

  it('should navigate to About page and click internal link without leaving app', () => {
    // Step 1: Navigate to About page
    // FFCI sites use Action Hub, so navigate via bottom nav
    cy.get('body').then(($body) => {
      const hasActionHub = $body.find('[data-testid="quick-tasks"]').length > 0;
      
      if (hasActionHub) {
        // Use bottom navigation for Action Hub sites
        cy.get('[data-testid="bottom-nav"]').should('be.visible');
        cy.contains('[data-testid="bottom-nav"] a', 'About')
          .should('be.visible')
          .click();
      } else {
        // Fallback to menu-item for navigation type
        cy.contains('[data-testid="menu-item"]', 'About')
          .should('be.visible')
          .click();
      }
    });
    
    // Step 2: Verify we're on the About page
    cy.url().should('include', '/page/xhZj4ejQ65bRhrJg');
    cy.get('main', { timeout: 10000 }).should('be.visible');
    
    // Step 3: Find an internal link in the page content
    cy.get('main', { timeout: 10000 }).should('be.visible');
    
    // Find links - try both transformed and original format
    cy.get('main').within(() => {
      // First try to find transformed links
      cy.get('a').then(($links) => {
        const transformedLinks = Array.from($links).filter((link) => {
          const href = link.getAttribute('href') || '';
          return href.startsWith('/page/') && /^\/page\/[a-zA-Z0-9]+/.test(href);
        });
        
        if (transformedLinks.length > 0) {
          const firstLink = transformedLinks[0];
          const href = firstLink.getAttribute('href') || '';
          cy.log(`Found ${transformedLinks.length} transformed link(s). Clicking: ${href}`);
          
          // Step 4: Click the internal link
          cy.wrap(firstLink).click();
        } else {
          // Fallback: try to find any internal link marked with data-internal-link
          const internalLinks = Array.from($links).filter((link) => {
            return link.hasAttribute('data-internal-link') && 
                   link.getAttribute('target') !== '_blank';
          });
          
          if (internalLinks.length > 0) {
            const firstLink = internalLinks[0];
            const href = firstLink.getAttribute('href') || '';
            cy.log(`Found ${internalLinks.length} internal link(s) (not transformed). Clicking: ${href}`);
            cy.wrap(firstLink).click();
          } else {
            throw new Error('No internal links found on About page');
          }
        }
      });
    });
    
    // Step 5: Verify we stayed in the app (URL should be /page/{uuid} format)
    cy.url({ timeout: 10000 }).should('include', '/page/');
    cy.url().should('not.include', 'ddev.site');
    
    // Step 6: Verify new page content loaded
    cy.get('main', { timeout: 10000 }).should('be.visible');
    cy.get('main').should('not.contain', 'Error Loading Page');
    
    // Verify we're on a different page (URL changed)
    cy.url().should('not.include', 'xhZj4ejQ65bRhrJg');
  });
});
