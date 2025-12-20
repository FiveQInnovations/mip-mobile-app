describe('Video Playback', () => {
  beforeEach(() => {
    // Mock site data for all tests
    cy.fixture('mock-api-responses.json').then((siteData) => {
      cy.intercept('GET', '**/mobile-api', siteData);
    });
  });

  it('displays video player for video items', () => {
    cy.fixture('video-youtube.json').then((pageData) => {
      cy.intercept('GET', '**/mobile-api/page/*', pageData);
      cy.visit('/page/video-item-uuid');
      cy.get('[data-testid="video-player"]').should('be.visible');
    });
  });

  it('handles YouTube URLs with embed', () => {
    cy.fixture('video-youtube.json').then((pageData) => {
      cy.intercept('GET', '**/mobile-api/page/*', pageData);
      cy.visit('/page/youtube-video-uuid');
      
      // Check for lite-youtube web component
      cy.get('lite-youtube').should('be.visible');
      cy.get('lite-youtube').should('have.attr', 'videoid', 'dQw4w9WgXcQ');
    });
  });

  it('handles Vimeo URLs with embed', () => {
    cy.fixture('video-vimeo.json').then((pageData) => {
      cy.intercept('GET', '**/mobile-api/page/*', pageData);
      cy.visit('/page/vimeo-video-uuid');
      
      cy.get('[data-testid="vimeo-iframe"]').should('be.visible');
      cy.get('[data-testid="vimeo-iframe"]').should('have.attr', 'src').and('include', 'vimeo.com/video/123456789');
    });
  });

  it('handles direct video URLs with HTML5 player', () => {
    cy.fixture('video-direct.json').then((pageData) => {
      cy.intercept('GET', '**/mobile-api/page/*', pageData);
      cy.visit('/page/direct-video-uuid');
      
      cy.get('[data-testid="video-element"]').should('be.visible');
      cy.get('[data-testid="video-element"]').should('have.attr', 'controls');
      cy.get('[data-testid="video-element"] source').should('have.attr', 'src', 'https://example.com/video.mp4');
    });
  });

  it('displays poster image for direct video URLs', () => {
    cy.fixture('video-direct.json').then((pageData) => {
      cy.intercept('GET', '**/mobile-api/page/*', pageData);
      cy.visit('/page/direct-video-uuid');
      
      cy.get('[data-testid="video-element"]').should('have.attr', 'poster', 'https://example.com/poster.jpg');
    });
  });

  it('displays content below video player', () => {
    cy.fixture('video-youtube.json').then((pageData) => {
      cy.intercept('GET', '**/mobile-api/page/*', pageData);
      cy.visit('/page/video-item-uuid');
      
      cy.get('[data-testid="video-player"]').should('be.visible');
      cy.contains('This is a YouTube video page.').should('be.visible');
    });
  });

  it('displays page title above video player', () => {
    cy.fixture('video-youtube.json').then((pageData) => {
      cy.intercept('GET', '**/mobile-api/page/*', pageData);
      cy.visit('/page/video-item-uuid');
      
      cy.get('h1').should('contain', 'Sample YouTube Video');
      cy.get('[data-testid="video-player"]').should('be.visible');
    });
  });

  it('displays cover image when present', () => {
    cy.fixture('video-youtube.json').then((pageData) => {
      cy.intercept('GET', '**/mobile-api/page/*', pageData);
      cy.visit('/page/video-item-uuid');
      
      cy.get('img[alt="Sample YouTube Video"]').should('be.visible');
      cy.get('img[alt="Sample YouTube Video"]').should('have.attr', 'src', 'https://example.com/cover.jpg');
    });
  });
});
