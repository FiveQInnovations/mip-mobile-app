describe('Audio Playback', () => {
  beforeEach(() => {
    // Mock site data for all tests
    cy.fixture('mock-api-responses.json').then((siteData) => {
      cy.intercept('GET', '**/mobile-api', siteData);
    });
  });

  it('displays audio player for audio items', () => {
    cy.fixture('audio-item.json').then((pageData) => {
      cy.intercept('GET', '**/mobile-api/page/*', pageData);
      cy.visit('/page/audio-item-uuid');
      cy.get('[data-testid="audio-player"]').should('be.visible');
    });
  });

  it('audio player has playback controls', () => {
    cy.fixture('audio-item.json').then((pageData) => {
      cy.intercept('GET', '**/mobile-api/page/*', pageData);
      cy.visit('/page/audio-item-uuid');
      
      cy.get('[data-testid="audio-element"]').should('be.visible');
      cy.get('[data-testid="audio-element"]').should('have.attr', 'controls');
    });
  });

  it('displays audio metadata (title, artwork)', () => {
    cy.fixture('audio-item.json').then((pageData) => {
      cy.intercept('GET', '**/mobile-api/page/*', pageData);
      cy.visit('/page/audio-item-uuid');
      
      cy.get('[data-testid="audio-player"]').within(() => {
        cy.get('[data-testid="audio-title"]').should('be.visible');
        cy.get('[data-testid="audio-title"]').should('contain', 'Sample Audio Episode');
        cy.get('[data-testid="audio-artwork"]').should('be.visible');
        cy.get('[data-testid="audio-artwork"]').should('have.attr', 'src', 'https://example.com/audio-artwork.jpg');
      });
    });
  });

  it('displays audio duration when available', () => {
    cy.fixture('audio-item.json').then((pageData) => {
      cy.intercept('GET', '**/mobile-api/page/*', pageData);
      cy.visit('/page/audio-item-uuid');
      
      cy.get('[data-testid="audio-duration"]').should('be.visible');
      cy.get('[data-testid="audio-duration"]').should('contain', '60:00');
    });
  });

  it('displays content below audio player', () => {
    cy.fixture('audio-item.json').then((pageData) => {
      cy.intercept('GET', '**/mobile-api/page/*', pageData);
      cy.visit('/page/audio-item-uuid');
      
      cy.get('[data-testid="audio-player"]').should('be.visible');
      cy.contains('This is an audio page with full metadata.').should('be.visible');
    });
  });

  it('displays page title above audio player', () => {
    cy.fixture('audio-item.json').then((pageData) => {
      cy.intercept('GET', '**/mobile-api/page/*', pageData);
      cy.visit('/page/audio-item-uuid');
      
      cy.get('h1').should('contain', 'Sample Audio Episode');
      cy.get('[data-testid="audio-player"]').should('be.visible');
    });
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
    
    cy.intercept('GET', '**/mobile-api/page/*', audioWithoutArtwork);
    cy.visit('/page/audio-no-artwork-uuid');
    
    cy.get('[data-testid="audio-player"]').should('be.visible');
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
    
    cy.intercept('GET', '**/mobile-api/page/*', audioWithoutDuration);
    cy.visit('/page/audio-no-duration-uuid');
    
    cy.get('[data-testid="audio-player"]').should('be.visible');
    cy.get('[data-testid="audio-element"]').should('be.visible');
    // Duration should not be displayed
    cy.get('[data-testid="audio-duration"]').should('not.exist');
  });
});
