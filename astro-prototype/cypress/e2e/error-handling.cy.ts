const getClient = () =>
  cy
    .window()
    .its('__mipApi', { timeout: 5000 })
    .should('exist')
    .then((client) => client!);

declare global {
  interface Window {
    __mipApi?: {
      getSiteData: () => Promise<any>;
      getMenu: () => Promise<any>;
      getPage: (uuid: string) => Promise<any>;
      clearApiCache: (key?: string) => void;
      expireCacheEntryForTesting: (key: string) => void;
      ApiError: typeof Error;
    };
  }
}

export {};

describe('API Client Error Handling', () => {
  beforeEach(() => {
    cy.visit('/');
    getClient().then((client) => client.clearApiCache());
  });

  it('wraps network failures in ApiError', () => {
    cy.intercept('GET', '**/mobile-api', { forceNetworkError: true }).as('siteError');

    getClient().then((client) =>
      cy.wrap(null).then(async () => {
        try {
          await client.getSiteData();
          throw new Error('Expected ApiError');
        } catch (err) {
          expect(err).to.be.instanceOf(client.ApiError);
          expect(err.status).to.eq(0);
          expect(err.url).to.include('/mobile-api');
        }
      })
    );
  });

  it('returns cached site data when refresh fails', () => {
    cy.intercept('GET', '**/mobile-api', { fixture: 'mock-api-responses.json' }).as('site');

    getClient().then((client) =>
      cy
        .wrap(null)
        .then(() => client.getSiteData())
        .then((data) => {
          expect(data.site_data.title).to.equal('Template Site');
        })
    );

    cy.wait('@site');

    getClient().then((client) => client.expireCacheEntryForTesting('site'));
    cy.intercept('GET', '**/mobile-api', { forceNetworkError: true }).as('siteFail');

    getClient().then((client) =>
      cy
        .wrap(null)
        .then(() => client.getSiteData())
        .then((data) => {
          expect(data.site_data.title).to.equal('Template Site');
        })
    );

    cy.wait('@siteFail');
  });

  it('surfaces 404s as ApiError for invalid page UUIDs', () => {
    cy.intercept('GET', '**/mobile-api/page/invalid-uuid-12345', {
      statusCode: 404,
      body: { message: 'Not found' },
    }).as('page404');

    getClient().then((client) => client.clearApiCache('page-invalid-uuid-12345'));

    getClient().then((client) =>
      cy.wrap(null).then(async () => {
        try {
          await client.getPage('invalid-uuid-12345');
          throw new Error('Expected ApiError');
        } catch (err) {
          expect(err).to.be.instanceOf(client.ApiError);
          expect(err.status).to.eq(404);
          expect(err.url).to.include('invalid-uuid-12345');
        }
      })
    );

    cy.wait('@page404');
  });
});
