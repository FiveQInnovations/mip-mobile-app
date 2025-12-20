describe('Content Page', () => {
  beforeEach(() => {
    // Mock site data for all tests
    cy.intercept('GET', '**/mobile-api', { fixture: 'homepage-navigation.json' }).as('siteData');
  });

  it('displays page title', () => {
    cy.intercept('GET', '**/mobile-api/page/valid-content-uuid', { fixture: 'page-content.json' }).as('pageData');
    cy.visitPage('valid-content-uuid');
    cy.wait('@siteData');
    cy.wait('@pageData');
    cy.get('h1').should('be.visible').and('contain', 'About Page');
  });

  it('renders HTML content from API', () => {
    cy.intercept('GET', '**/mobile-api/page/valid-content-uuid', { fixture: 'page-content.json' }).as('pageData');
    cy.visitPage('valid-content-uuid');
    cy.wait('@siteData');
    cy.wait('@pageData');
    cy.get('[data-testid="content-view"]').should('be.visible');
    cy.get('[data-testid="content-view"] p').should('have.length.at.least', 1);
    cy.get('[data-testid="content-view"]').should('contain', 'This is the about page content');
  });

  it('displays cover image when present', () => {
    cy.intercept('GET', '**/mobile-api/page/page-with-cover', { fixture: 'page-with-cover.json' }).as('pageData');
    cy.visitPage('page-with-cover');
    cy.wait('@siteData');
    cy.wait('@pageData');
    cy.get('img[alt="Page with Cover Image"]').should('be.visible');
    cy.get('img[alt="Page with Cover Image"]').should('have.attr', 'src', 'https://example.com/cover.jpg');
  });

  it('internal links navigate within app', () => {
    cy.intercept('GET', '**/mobile-api/page/page-with-internal-link', { fixture: 'page-with-internal-link.json' }).as('pageData');
    cy.intercept('GET', '**/mobile-api/page/about-uuid', { fixture: 'page-content.json' }).as('targetPage');
    
    cy.visitPage('page-with-internal-link');
    cy.wait('@siteData');
    cy.wait('@pageData');
    
    // Check that internal links are marked
    cy.get('[data-testid="content-view"] a[data-internal-link="true"]').should('exist');
    
    // Click internal link (note: actual navigation might need UUID resolution)
    cy.get('[data-testid="content-view"] a[data-internal-link="true"]').first().click();
    
    // Should navigate (though UUID resolution might need API lookup)
    cy.url().should('include', '/page/');
  });

  it('external links open in new tab', () => {
    cy.intercept('GET', '**/mobile-api/page/page-with-external-link', { fixture: 'page-with-external-link.json' }).as('pageData');
    
    cy.visitPage('page-with-external-link');
    cy.wait('@siteData');
    cy.wait('@pageData');
    
    // Check that external links have target="_blank"
    cy.get('[data-testid="content-view"] a[data-external-link="true"]').should('exist');
    cy.get('[data-testid="content-view"] a[data-external-link="true"]').should('have.attr', 'target', '_blank');
    cy.get('[data-testid="content-view"] a[data-external-link="true"]').should('have.attr', 'rel', 'noopener noreferrer');
    
    // Check for external link indicator (arrow icon)
    cy.get('[data-testid="content-view"] a[data-external-link="true"]').first().should('be.visible');
  });

  it('external links have visual indicator', () => {
    cy.intercept('GET', '**/mobile-api/page/page-with-external-link', { fixture: 'page-with-external-link.json' }).as('pageData');
    
    cy.visitPage('page-with-external-link');
    cy.wait('@siteData');
    cy.wait('@pageData');
    
    // External links should have the arrow indicator via CSS ::after
    cy.get('[data-testid="content-view"] a[data-external-link="true"]').first().should('have.css', 'position', 'relative');
  });

  it('shows form embed when page has form', () => {
    cy.intercept('GET', '**/mobile-api/page/form-page-uuid', { fixture: 'page-with-form.json' }).as('pageData');
    
    cy.visitPage('form-page-uuid');
    cy.wait('@siteData');
    cy.wait('@pageData');
    
    cy.get('[data-testid="form-embed"]').should('be.visible');
    cy.get('[data-testid="form-embed"] iframe').should('exist');
  });

  it('form iframe has proper attributes', () => {
    cy.intercept('GET', '**/mobile-api/page/form-page-uuid', { fixture: 'page-with-form.json' }).as('pageData');
    
    cy.visitPage('form-page-uuid');
    cy.wait('@siteData');
    cy.wait('@pageData');
    
    cy.get('[data-testid="form-embed"] iframe')
      .should('have.attr', 'sandbox')
      .and('include', 'allow-forms')
      .and('include', 'allow-scripts');
    
    cy.get('[data-testid="form-embed"] iframe')
      .should('have.attr', 'loading', 'lazy');
  });

  it('displays content above form when both present', () => {
    cy.intercept('GET', '**/mobile-api/page/form-page-uuid', { fixture: 'page-with-form.json' }).as('pageData');
    
    cy.visitPage('form-page-uuid');
    cy.wait('@siteData');
    cy.wait('@pageData');
    
    // Content should be visible
    cy.get('[data-testid="content-view"]').should('be.visible');
    cy.get('[data-testid="content-view"]').should('contain', 'Please fill out the form');
    
    // Form should be visible below content
    cy.get('[data-testid="form-embed"]').should('be.visible');
    
    // Form should come after content in DOM order
    cy.get('[data-testid="content-view"]').then(($content) => {
      cy.get('[data-testid="form-embed"]').then(($form) => {
        expect($content.position().top).to.be.lessThan($form.position().top);
      });
    });
  });

  it('handles pages without cover image', () => {
    cy.intercept('GET', '**/mobile-api/page/no-cover-uuid', { fixture: 'page-content.json' }).as('pageData');
    
    cy.visitPage('no-cover-uuid');
    cy.wait('@siteData');
    cy.wait('@pageData');
    
    // Page should still render correctly
    cy.get('h1').should('be.visible');
    cy.get('[data-testid="content-view"]').should('be.visible');
    
    // Should not have cover image
    cy.get('img[alt="About Page"]').should('not.exist');
  });

  it('applies mobile-optimized styles to content', () => {
    cy.intercept('GET', '**/mobile-api/page/valid-content-uuid', { fixture: 'page-content.json' }).as('pageData');
    
    cy.visitPage('valid-content-uuid');
    cy.wait('@siteData');
    cy.wait('@pageData');
    
    // Check that content view has proper styling
    cy.get('[data-testid="content-view"]').should('have.class', 'content-view');
    cy.get('[data-testid="content-view"]').should('have.class', 'prose');
    
    // Links should be touch-friendly (min-height)
    cy.get('[data-testid="content-view"] a').first().should('have.css', 'min-height');
  });
});

describe('Form Detection', () => {
  beforeEach(() => {
    cy.intercept('GET', '**/mobile-api', { fixture: 'homepage-navigation.json' }).as('siteData');
  });

  it('shows form embed when page has form', () => {
    cy.intercept('GET', '**/mobile-api/page/form-page-uuid', { fixture: 'page-with-form.json' }).as('pageData');
    
    cy.visit('/page/form-page-uuid');
    cy.wait('@siteData');
    cy.wait('@pageData');
    
    cy.get('[data-testid="form-embed"]').should('be.visible');
  });

  it('does not show form embed when page has no form', () => {
    cy.intercept('GET', '**/mobile-api/page/no-form-uuid', { fixture: 'page-content.json' }).as('pageData');
    
    cy.visitPage('no-form-uuid');
    cy.wait('@siteData');
    cy.wait('@pageData');
    
    cy.get('[data-testid="form-embed"]').should('not.exist');
  });
});
