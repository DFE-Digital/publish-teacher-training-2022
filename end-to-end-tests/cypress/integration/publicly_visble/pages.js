import publicly_visble_pages from "../../fixtures/publicly_visble/pages.json";

const baseUrl = Cypress.config().baseUrl;

console.log(publicly_visble_pages)
describe("publicly visible pages", function () {

  publicly_visble_pages.forEach(publicly_visble_page => {
    describe(`${publicly_visble_page.pageType} pages`, function () {
      publicly_visble_page.pages.forEach(page => {
        it(`can view ${page.urlPath}`, canView(page));
      });
    });
  });
});

function canView(page) {
  return function () {
    const url = baseUrl + page.urlPath;

    cy.clearCookies()
      .visit(url, {failOnStatusCode: false  })
      .url().should('eq', url, "You shouldn't be redirected")
      .get(page.selector).contains(page.content);

    if(page.selector !== 'body') {
      cy.get('footer').scrollIntoView({ duration: 2000 });
    }
  };
};
