/**
 * Integration Tests for Audio Playback
 * 
 * These tests use the REAL API from ws-ffci-copy.ddev.site
 * They verify that audio players work correctly with actual API responses.
 * 
 * Prerequisites:
 * - DDEV site ws-ffci-copy must be running
 * - API must be accessible at https://ws-ffci-copy.ddev.site
 */

describe('Audio Playback - Integration Tests', () => {
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

  it('displays page content from real API', () => {
    // Use a real page UUID from the API
    const realPageUuid = 'xhZj4ejQ65bRhrJg';
    
    cy.visitPage(realPageUuid);
    
    // Verify page loads and displays content
    cy.get('h1', { timeout: 10000 }).should('be.visible');
    // The page title might be in the h1 or elsewhere, just verify it's visible
    cy.get('main', { timeout: 10000 }).should('be.visible');
  });

  it('verifies audio player component renders when audio data exists', () => {
    // This test verifies the AudioPlayer component works
    // It will check if a page has audio data and verify the player renders
    cy.request('GET', 'https://ws-ffci-copy.ddev.site/mobile-api').then((response) => {
      const menu = response.body.menu;
      
      // Check each menu item for audio content
      if (menu && menu.length > 0) {
        const testPageUuid = menu[0].page.uuid;
        
        cy.request('GET', `https://ws-ffci-copy.ddev.site/mobile-api/page/${testPageUuid}`).then((pageResponse) => {
          const pageData = pageResponse.body;
          
          // If page has audio data, verify audio player renders
          if (pageData.page_type === 'collection-item' && pageData.type === 'audio' && pageData.data?.audio) {
            cy.visitPage(testPageUuid);
            cy.get('[data-testid="audio-player"]', { timeout: 10000 }).should('be.visible');
            cy.get('[data-testid="audio-element"]').should('be.visible');
            cy.get('[data-testid="audio-element"]').should('have.attr', 'controls');
          } else {
            // Skip test if no audio content
            cy.log('No audio content found on this page, skipping audio player test');
          }
        });
      }
    });
  });

  it('verifies audio metadata displays correctly when available', () => {
    cy.request('GET', 'https://ws-ffci-copy.ddev.site/mobile-api').then((response) => {
      const menu = response.body.menu;
      
      if (menu && menu.length > 0) {
        const testPageUuid = menu[0].page.uuid;
        
        cy.request('GET', `https://ws-ffci-copy.ddev.site/mobile-api/page/${testPageUuid}`).then((pageResponse) => {
          const pageData = pageResponse.body;
          
          if (pageData.page_type === 'collection-item' && pageData.type === 'audio' && pageData.data?.audio) {
            cy.visitPage(testPageUuid);
            
            // Check for audio metadata
            if (pageData.data.audio.title) {
              cy.get('[data-testid="audio-title"]', { timeout: 10000 }).should('be.visible');
              cy.get('[data-testid="audio-title"]').should('contain', pageData.data.audio.title);
            }
            
            if (pageData.data.audio.artwork) {
              cy.get('[data-testid="audio-artwork"]', { timeout: 10000 }).should('be.visible');
            }
            
            if (pageData.data.audio.duration) {
              cy.get('[data-testid="audio-duration"]', { timeout: 10000 }).should('be.visible');
            }
          } else {
            cy.log('No audio content found on this page, skipping metadata test');
          }
        });
      }
    });
  });
});
