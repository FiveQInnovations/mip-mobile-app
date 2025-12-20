describe('Video Playback', () => {
  beforeEach(() => {
    // Mock site data for all tests - intercept BEFORE visit for SSR requests
    // Use wildcard pattern to match any domain (including external URLs)
    cy.intercept('GET', '**/mobile-api', { fixture: 'mock-api-responses.json' }).as('siteData');
    // Also intercept the specific external domain used by Astro SSR
    cy.intercept('GET', 'https://ws-ffci-copy.ddev.site/mobile-api', { fixture: 'mock-api-responses.json' }).as('siteDataExternal');
  });

  it('displays video player for video items', () => {
    cy.intercept('GET', '**/mobile-api/page/video-item-uuid', { fixture: 'video-youtube.json' }).as('pageData');
    cy.intercept('GET', 'https://ws-ffci-copy.ddev.site/mobile-api/page/video-item-uuid', { fixture: 'video-youtube.json' }).as('pageDataExternal');
    cy.visitPage('video-item-uuid');
    // Note: SSR requests may not be intercepted, so we check page rendering directly
    cy.get('[data-testid="video-player"]', { timeout: 10000 }).should('be.visible');
  });

  it('handles YouTube URLs with embed', () => {
    cy.intercept('GET', '**/mobile-api/page/youtube-video-uuid', { fixture: 'video-youtube.json' }).as('pageData');
    cy.visitPage('youtube-video-uuid');
    // Note: SSR requests may not be intercepted, so we check page rendering directly
    cy.get('lite-youtube', { timeout: 10000 }).should('be.visible');
    cy.get('lite-youtube').should('have.attr', 'videoid', 'dQw4w9WgXcQ');
  });

  it('handles Vimeo URLs with embed', () => {
    cy.intercept('GET', '**/mobile-api/page/vimeo-video-uuid', { fixture: 'video-vimeo.json' }).as('pageData');
    cy.visitPage('vimeo-video-uuid');
    // Note: SSR requests may not be intercepted, so we check page rendering directly
    cy.get('[data-testid="vimeo-iframe"]', { timeout: 10000 }).should('be.visible');
    cy.get('[data-testid="vimeo-iframe"]').should('have.attr', 'src').and('include', 'vimeo.com/video/123456789');
  });

  it('handles direct video URLs with HTML5 player', () => {
    cy.intercept('GET', '**/mobile-api/page/direct-video-uuid', { fixture: 'video-direct.json' }).as('pageData');
    cy.visitPage('direct-video-uuid');
    // Note: SSR requests may not be intercepted, so we check page rendering directly
    cy.get('[data-testid="video-element"]', { timeout: 10000 }).should('be.visible');
    cy.get('[data-testid="video-element"]').should('have.attr', 'controls');
    cy.get('[data-testid="video-element"] source').should('have.attr', 'src', 'https://example.com/video.mp4');
  });

  it('displays poster image for direct video URLs', () => {
    cy.intercept('GET', '**/mobile-api/page/direct-video-uuid', { fixture: 'video-direct.json' }).as('pageData');
    cy.visitPage('direct-video-uuid');
    // Note: SSR requests may not be intercepted, so we check page rendering directly
    cy.get('[data-testid="video-element"]', { timeout: 10000 }).should('have.attr', 'poster', 'https://example.com/poster.jpg');
  });

  it('displays content below video player', () => {
    cy.intercept('GET', '**/mobile-api/page/video-item-uuid', { fixture: 'video-youtube.json' }).as('pageData');
    cy.visitPage('video-item-uuid');
    // Note: SSR requests may not be intercepted, so we check page rendering directly
    cy.get('[data-testid="video-player"]', { timeout: 10000 }).should('be.visible');
    cy.contains('This is a YouTube video page.').should('be.visible');
  });

  it('displays page title above video player', () => {
    cy.intercept('GET', '**/mobile-api/page/video-item-uuid', { fixture: 'video-youtube.json' }).as('pageData');
    cy.visitPage('video-item-uuid');
    // Note: SSR requests may not be intercepted, so we check page rendering directly
    cy.get('h1', { timeout: 10000 }).should('contain', 'Sample YouTube Video');
    cy.get('[data-testid="video-player"]').should('be.visible');
  });

  it('displays cover image when present', () => {
    cy.intercept('GET', '**/mobile-api/page/video-item-uuid', { fixture: 'video-youtube.json' }).as('pageData');
    cy.visitPage('video-item-uuid');
    // Note: SSR requests may not be intercepted, so we check page rendering directly
    cy.get('img[alt="Sample YouTube Video"]', { timeout: 10000 }).should('be.visible');
    cy.get('img[alt="Sample YouTube Video"]').should('have.attr', 'src', 'https://example.com/cover.jpg');
  });
});
