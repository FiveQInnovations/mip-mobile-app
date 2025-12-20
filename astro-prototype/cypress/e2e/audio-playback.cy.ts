describe('Audio Playback', () => {
  beforeEach(() => {
    // Mock site data for all tests
    cy.intercept('GET', '**/mobile-api', { fixture: 'mock-api-responses.json' }).as('siteData');
  });

  it('displays audio player for audio items', () => {
    cy.intercept('GET', '**/mobile-api/page/audio-item-uuid', { fixture: 'audio-item.json' }).as('pageData');
    cy.visit('/page/audio-item-uuid');
    cy.wait(['@siteData', '@pageData'], { timeout: 10000 });
    cy.get('[data-testid="audio-player"]', { timeout: 10000 }).should('be.visible');
  });

  it('audio player has playback controls', () => {
    cy.intercept('GET', '**/mobile-api/page/audio-item-uuid', { fixture: 'audio-item.json' }).as('pageData');
    cy.visit('/page/audio-item-uuid');
    cy.wait(['@siteData', '@pageData'], { timeout: 10000 });
    
    cy.get('[data-testid="audio-element"]', { timeout: 10000 }).should('be.visible');
    cy.get('[data-testid="audio-element"]').should('have.attr', 'controls');
  });

  it('displays audio metadata (title, artwork)', () => {
    cy.intercept('GET', '**/mobile-api/page/audio-item-uuid', { fixture: 'audio-item.json' }).as('pageData');
    cy.visit('/page/audio-item-uuid');
    cy.wait(['@siteData', '@pageData'], { timeout: 10000 });
    
    cy.get('[data-testid="audio-player"]', { timeout: 10000 }).within(() => {
      cy.get('[data-testid="audio-title"]').should('be.visible');
      cy.get('[data-testid="audio-title"]').should('contain', 'Sample Audio Episode');
      cy.get('[data-testid="audio-artwork"]').should('be.visible');
      cy.get('[data-testid="audio-artwork"]').should('have.attr', 'src', 'https://example.com/audio-artwork.jpg');
    });
  });

  it('displays audio duration when available', () => {
    cy.intercept('GET', '**/mobile-api/page/audio-item-uuid', { fixture: 'audio-item.json' }).as('pageData');
    cy.visit('/page/audio-item-uuid');
    cy.wait(['@siteData', '@pageData'], { timeout: 10000 });
    
    cy.get('[data-testid="audio-duration"]', { timeout: 10000 }).should('be.visible');
    cy.get('[data-testid="audio-duration"]').should('contain', '60:00');
  });

  it('displays content below audio player', () => {
    cy.intercept('GET', '**/mobile-api/page/audio-item-uuid', { fixture: 'audio-item.json' }).as('pageData');
    cy.visit('/page/audio-item-uuid');
    cy.wait(['@siteData', '@pageData'], { timeout: 10000 });
    
    cy.get('[data-testid="audio-player"]', { timeout: 10000 }).should('be.visible');
    cy.contains('This is an audio page with full metadata.').should('be.visible');
  });

  it('displays page title above audio player', () => {
    cy.intercept('GET', '**/mobile-api/page/audio-item-uuid', { fixture: 'audio-item.json' }).as('pageData');
    cy.visit('/page/audio-item-uuid');
    cy.wait(['@siteData', '@pageData'], { timeout: 10000 });
    
    cy.get('h1', { timeout: 10000 }).should('contain', 'Sample Audio Episode');
    cy.get('[data-testid="audio-player"]').should('be.visible');
  });

  it('handles audio without artwork gracefully', () => {
    const audioWithoutArtwork = {
      "page_type": "collection-item",
      "type": "audio",
      "title": "Audio Without Artwork",
      "data": {
        "audio": {
          "url": "https://example.com/audio.mp3",
          "duration": 1800,
          "title": "Audio Without Artwork"
        }
      }
    };
    
    cy.intercept('GET', '**/mobile-api/page/audio-no-artwork-uuid', audioWithoutArtwork).as('pageData');
    cy.visit('/page/audio-no-artwork-uuid');
    cy.wait(['@siteData', '@pageData'], { timeout: 10000 });
    
    cy.get('[data-testid="audio-player"]', { timeout: 10000 }).should('be.visible');
    cy.get('[data-testid="audio-element"]').should('be.visible');
    // Should not have artwork image
    cy.get('[data-testid="audio-artwork"]').should('not.exist');
  });

  it('handles audio without duration gracefully', () => {
    const audioWithoutDuration = {
      "page_type": "collection-item",
      "type": "audio",
      "title": "Audio Without Duration",
      "data": {
        "audio": {
          "url": "https://example.com/audio.mp3",
          "title": "Audio Without Duration"
        }
      }
    };
    
    cy.intercept('GET', '**/mobile-api/page/audio-no-duration-uuid', audioWithoutDuration).as('pageData');
    cy.visit('/page/audio-no-duration-uuid');
    cy.wait(['@siteData', '@pageData'], { timeout: 10000 });
    
    cy.get('[data-testid="audio-player"]', { timeout: 10000 }).should('be.visible');
    cy.get('[data-testid="audio-element"]').should('be.visible');
    // Duration should not be displayed
    cy.get('[data-testid="audio-duration"]').should('not.exist');
  });
});
