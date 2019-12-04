const baseUrl = Cypress.config().baseUrl;

describe("login", function () {
  it("viewing organisation list ", function () {
    cy.signIn()
      .visit(baseUrl);

    cy.url().should('eq', baseUrl);
    cy.get('footer').scrollIntoView({ duration: 2000 });
    cy.get('h1').contains('Organisations');
  });

  it("viewing provider page ", function () {
    const url = `${baseUrl}/organisations/T92`;
    cy.signIn()
      .visit(url);

    cy.url().should('eq', url);
    cy.get('footer').scrollIntoView({ duration: 2000 });
    // cy.get('h1').contains('provider name');
  });
});
