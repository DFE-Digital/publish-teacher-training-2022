const baseUrl = Cypress.config().baseUrl;

describe("login", function () {
  it("viewing organisation list ", function () {
    cy.signIn()
      .visit(baseUrl);

    cy.url().should('eq', `${baseUrl}organisations/B1T`);
    cy.get('h1').contains('bat 1');
    cy.get('footer').scrollIntoView({ duration: 2000 });
  });
});
