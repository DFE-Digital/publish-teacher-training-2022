const baseUrl = Cypress.config().baseUrl;

describe("login", function () {
  it("viewing organisation list ", function () {
    cy.signIn()
      .visit(baseUrl);

    cy.url().should('eq', baseUrl);
    cy.get('h1').contains('Organisations');
    cy.get('footer').scrollIntoView({ duration: 2000 });
  });
});
