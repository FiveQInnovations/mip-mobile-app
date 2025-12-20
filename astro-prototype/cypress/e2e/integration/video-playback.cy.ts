/**
 * Integration Tests for Video Playback
 * 
 * These tests use the REAL API from ws-ffci-copy.ddev.site
 * They verify that video players work correctly with actual API responses.
 * 
 * Prerequisites:
 * - DDEV site ws-ffci-copy must be running
 * - API must be accessible at https://ws-ffci-copy.ddev.site
 */

describe('Video Playback - Integration Tests', () => {
  beforeEach(() => {
    // No intercepts - we're using the real API
    // Just ensure the dev server is running
    cy.visit('/');
  });

  it('can access the real API', () => {
    // Verify the API is accessible
    cy.request('GET', 'https://ws-ffci-copy.ddev.site/mobile-api').then((response) => {
      expect(response.status).to.eq(200);
      expect(response.body).to.have.property('menu');
      expect(response.body).to.have.property('site_data');
    });
  });

  it('can navigate to pages from API', () => {
    // Use a real page UUID from the API
    // This is the "About" page UUID from the menu
    const realPageUuid = 'xhZj4ejQ65bRhrJg';
    
    cy.visitPage(realPageUuid);
    
    // Verify page loads and displays basic structure
    cy.get('h1', { timeout: 10000 }).should('be.visible');
    cy.get('main', { timeout: 10000 }).should('be.visible');
    
    // TODO: Verify that page content actually matches API response
    // TODO: Verify that page title matches API response title
    // TODO: Verify that page content structure matches API data structure
  });

  it('can navigate to menu pages', () => {
    // Verify we can navigate to pages from the menu
    cy.request('GET', 'https://ws-ffci-copy.ddev.site/mobile-api').then((response) => {
      const menu = response.body.menu;
      
      if (menu && menu.length > 0) {
        const firstPageUuid = menu[0].page.uuid;
        cy.visitPage(firstPageUuid);
        cy.get('h1', { timeout: 10000 }).should('be.visible');
      }
    });
    
    // TODO: Test that pages with video content render video players
    // TODO: Test YouTube video embeds when real YouTube content exists
    // TODO: Test Vimeo video embeds when real Vimeo content exists
    // TODO: Test direct video URLs when real direct video content exists
    // TODO: Verify video player attributes match API response (poster, source, etc.)
  });

  it('verifies video player component renders when video data exists', () => {
    // This test verifies the VideoPlayer component works
    // It will check if a page has video data and verify the player renders
    cy.request('GET', 'https://ws-ffci-copy.ddev.site/mobile-api').then((response) => {
      const menu = response.body.menu;
      
      // Check each menu item for video content
      if (menu && menu.length > 0) {
        const testPageUuid = menu[0].page.uuid;
        
        cy.request('GET', `https://ws-ffci-copy.ddev.site/mobile-api/page/${testPageUuid}`).then((pageResponse) => {
          const pageData = pageResponse.body;
          
          // If page has video data, verify video player renders
          if (pageData.page_type === 'collection-item' && pageData.type === 'video' && pageData.data?.video) {
            cy.visitPage(testPageUuid);
            cy.get('[data-testid="video-player"]', { timeout: 10000 }).should('be.visible');
            
            // TODO: Verify video player type matches API response (YouTube/Vimeo/direct URL)
            // TODO: Verify YouTube video ID matches API response when source is YouTube
            // TODO: Verify Vimeo video ID matches API response when source is Vimeo
            // TODO: Verify direct video URL matches API response when source is URL
            // TODO: Verify poster image displays when present in API response
            // TODO: Verify cover image displays when present in API response
          } else {
            // Skip test if no video content
            cy.log('No video content found on this page, skipping video player test');
          }
        });
      }
    });
  });
});
