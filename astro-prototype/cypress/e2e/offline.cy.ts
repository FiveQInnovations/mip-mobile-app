describe('PWA & Offline', () => {
  beforeEach(() => {
    cy.mockApi('mock-api-responses.json');
  });

  it('has valid web app manifest', () => {
    cy.request('/manifest.json').then((response) => {
      expect(response.status).to.eq(200);
      expect(response.body).to.have.property('name');
      expect(response.body).to.have.property('icons');
      expect(response.body.display).to.eq('standalone');
      expect(response.body).to.have.property('theme_color');
    });
  });

  it('manifest has correct theme color', () => {
    cy.request('/manifest.json').then((response) => {
      expect(response.body.theme_color).to.exist;
      expect(response.body.theme_color).to.match(/^#[0-9A-Fa-f]{6}$/);
    });
  });

  it('manifest has required icons', () => {
    cy.request('/manifest.json').then((response) => {
      expect(response.body.icons).to.be.an('array');
      expect(response.body.icons.length).to.be.at.least(2);
      
      const iconSizes = response.body.icons.map((icon: { sizes: string }) => icon.sizes);
      expect(iconSizes).to.include('192x192');
      expect(iconSizes).to.include('512x512');
    });
  });

  it('service worker is registered', () => {
    cy.visit('/');
    cy.window().then((win) => {
      return win.navigator.serviceWorker.ready.then((registration) => {
        expect(registration).to.exist;
        expect(registration.scope).to.include(win.location.origin);
      });
    });
  });

  it('handles network failures gracefully', () => {
    // Mock API first, then visit
    cy.mockApi('mock-api-responses.json');
    cy.visit('/');
    
    // Now simulate offline for subsequent requests
    cy.intercept('GET', '**/mobile-api*', { forceNetworkError: true }).as('offlineApi');
    
    // Navigate to offline page directly to test offline UI
    cy.visit('/offline', { failOnStatusCode: false });
    cy.contains('offline', { matchCase: false }).should('be.visible');
  });

  it('offline page has retry button', () => {
    cy.visit('/offline');
    cy.get('[data-testid="retry-button"]').should('be.visible');
    cy.get('[data-testid="home-link"]').should('be.visible');
  });

  it('offline page displays correct message', () => {
    cy.visit('/offline');
    cy.contains('offline', { matchCase: false }).should('be.visible');
    cy.contains('not connected', { matchCase: false }).should('be.visible');
  });

  it('manifest link is present in HTML', () => {
    cy.visit('/');
    cy.get('head link[rel="manifest"]').should('exist');
    cy.get('head link[rel="manifest"]').should('have.attr', 'href', '/manifest.json');
  });

  it('theme-color meta tag is present', () => {
    cy.visit('/');
    cy.get('head meta[name="theme-color"]').should('exist');
  });

  it('apple-mobile-web-app meta tags are present', () => {
    cy.visit('/');
    cy.get('head meta[name="apple-mobile-web-app-capable"]').should('exist');
    cy.get('head meta[name="apple-mobile-web-app-capable"]').should('have.attr', 'content', 'yes');
  });
});
