const TEMPLATE_PRIMARY_RGB = 'rgb(37, 99, 235)'; // #2563eb from template config
const TEMPLATE_TEXT_RGB = 'rgb(15, 23, 42)'; // #0f172a from template config

describe('App Launch', () => {
  beforeEach(() => {
    cy.mockApi('mock-api-responses.json');
    cy.visit('/');
  });

  it('displays app name from config', () => {
    cy.get('header').should('contain', 'Mobile Template');
  });

  it('applies theme colors from config', () => {
    cy.get('header')
      .should('have.css', 'background-color', TEMPLATE_PRIMARY_RGB)
      .and('have.css', 'color', TEMPLATE_TEXT_RGB);
  });

  it('displays logo in header', () => {
    cy.get('header img').should('be.visible');
  });

  it('sets CSS custom properties from config', () => {
    cy.get('body')
      .invoke('attr', 'style')
      .should('contain', '--color-primary: #2563eb')
      .and('contain', '--color-background: #ffffff');
  });

  it('shows home screen with menu items', () => {
    // Check if Action Hub is rendered (for FFCI sites) or navigation type (for other sites)
    cy.get('body').then(($body) => {
      const hasActionHub = $body.find('[data-testid="quick-tasks"]').length > 0;
      const hasMenuGrid = $body.find('[data-testid="menu-grid"]').length > 0;
      
      if (hasActionHub) {
        // FFCI site with Action Hub
        cy.get('[data-testid="quick-tasks"]').should('be.visible');
        cy.get('[data-testid="get-connected"]').should('be.visible');
        cy.get('[data-testid="featured"]').should('be.visible');
      } else if (hasMenuGrid) {
        // Navigation type homepage
        cy.get('[data-testid="menu-grid"]').should('be.visible');
        cy.get('[data-testid="menu-item"]').should('have.length.at.least', 1);
      } else {
        throw new Error('Homepage should render either Action Hub or menu grid');
      }
    });
  });
});
