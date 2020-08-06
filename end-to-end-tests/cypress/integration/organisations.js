const baseUrl = Cypress.config().baseUrl;

// This test is skipped as the auth process is broken
// Rather than fix the plan is to port these E2E specs to Ruby.
describe("login", function () {
  // NOTE: user only has one organisation associated so,
  //       it can not view a list of organisations
  it("viewing B1T organisation details ", function () {
    const params = {
      auth: {
        username: "admin",
        password: Cypress.env('password')
      },
      method: 'GET',
      url: baseUrl
    }

    cy.visit(params);
    cy.contains('Login as an anonymised user').click();
    cy.get('input#email')
      .type('becomingateacher+integration-tests@digital.education.gov.uk');
    cy.get('form').submit();

    cy.url().should('eq', `${baseUrl}organisations/B1T`);
    cy.get('h1').contains('bat 1');
    cy.get('footer').scrollIntoView({ duration: 100 });
  });
});
