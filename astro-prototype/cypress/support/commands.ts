export {};

declare global {
  namespace Cypress {
    interface Chainable {
      visitPage(uuid: string): Chainable<void>;
      waitForApiLoad(): Chainable<void>;
      assertHeader(text: string): Chainable<void>;
      mockApi(fixture: string, path?: string): Chainable<void>;
    }
  }
}

Cypress.Commands.add('visitPage', (uuid: string) => {
  cy.visit(`/page/${uuid}`);
});

const MOBILE_API_BASE = '**/mobile-api';
const MOBILE_API_PATTERN = '**/mobile-api*';

Cypress.Commands.add('waitForApiLoad', () => {
  cy.intercept('GET', MOBILE_API_PATTERN).as('api');
  cy.wait('@api', { timeout: 10000 });
});

Cypress.Commands.add('assertHeader', (text: string) => {
  cy.get('header').should('contain', text);
});

Cypress.Commands.add('mockApi', (fixture: string, path = MOBILE_API_BASE) => {
  cy.fixture(fixture).then((data) => {
    cy.intercept('GET', path, data);
  });
});
