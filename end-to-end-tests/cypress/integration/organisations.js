const baseUrl = Cypress.config().baseUrl;

// This test is skipped as the auth process is broken
// Rather than fix the plan is to port these E2E specs to Ruby.
describe("login", function () {
  // NOTE: user only has one organisation associated so,
  //       it can not view a list of organisations
  it.skip("viewing B1T organisation details ", function () {
    cy.signIn()
      .visit(baseUrl);

    cy.url().should('eq', `${baseUrl}organisations/B1T`);
    cy.get('h1').contains('bat 1');
    cy.get('footer').scrollIntoView({ duration: 2000 });
  });
});
