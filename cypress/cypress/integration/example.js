import { getTopFrame } from "jest-message-util";

const urlBase = "https://localhost:3000/";

describe("login", function () {

  Cypress.Commands.add('loginWithSignIn', (username, password) => {
    Cypress.Cookies.debug(true);

    cy.clearCookies();

    cy.wrap({
      method: 'GET',
      url: `${urlBase}auth/dfe`,
      followRedirect: false
    })
      .as("step_1_option");

    cy.get("@step_1_option")
      .then(cy.request)
      .then(resp => {
        const step_2_option = {
          method: 'GET',
          url: resp.redirectedToUrl,
          followRedirect: true
        };

        cy.wrap(step_2_option).as("step_2_option")
      });

    cy.get("@step_2_option").then(cy.request)
      .then(response => {
        const authResponses = response.allRequestResponses.length;

        if (authResponses === 5) {
          cy.log("already logged in, skipping login sequence");
        } else {
          const lastResponse = response.allRequestResponses[response.allRequestResponses.length - 1];

          const authURL = lastResponse["Request URL"]

          const setCookiesHeaders = lastResponse["Response Headers"]["set-cookie"];

          setCookiesFromHeaders(setCookiesHeaders, authURL.hostname);

          // cy.log(`curl -b '${cookieHeaders.join("; ")}' -d username=${username} -d password='${password} -d _csrf='${csrfToken} -d cliendId='${clientId} -d redirectUri='${redirectUri}' '${authURL}'`);

          const form = getForm(response.body);
          const formInputs = arrayToObject(form.querySelectorAll('input'), {
            username: username,
            password: password,
          });

          const step_3_option = {
            method: 'POST',
            url: authURL,
            failOnStatusCode: false,
            form: true,
            body: formInputs,
          };
          cy.wrap(step_3_option).as("step_3_option")

          cy.get("@step_3_option")
            .then(step_3_option => cy.request(step_3_option))
            .then(response => {
              const loginResponses = response.allRequestResponses.length;
              expect(loginResponses).to.eq(1);

              const form = getForm(response.body);
              const formInputs = arrayToObject(form.querySelectorAll('input'));

              const step_4_option = {
                method: 'POST',
                url: form.action,
                failOnStatusCode: true,
                form: true,
                body: formInputs,
              };
              cy.wrap(step_4_option).as("step_4_option")
            });

          cy.get("@step_4_option")
            .then(cy.request)

          cy.log("you are in");
        }
      });
  });

  it("logging in ", function () {
    cy.loginWithSignIn("tim.abell+4@digital.education.gov.uk", 'omgsquirrel!88')
      .visit(urlBase);

    cy.url().should('eq', urlBase);
    cy.get('footer').scrollIntoView({ duration: 2000 });
    cy.get('h1').contains('Organisations');
  });
})

function getForm(body) {
  return Cypress.$(body).find('form')[0];
}


function arrayToObject(inputs, overrides) {
  inputs = Array.from(inputs);
  const reducer = (obj, item) => {
    obj[item.name] = item.value
    return obj
  };
  return Object.assign(inputs.reduce(reducer, {}), overrides)
}

function setCookiesFromHeaders(setCookiesHeaders, domain) {
  // setCookiesHeaders is a list of the set-cookie headers in the response:
  // 0: "_csrf=KDonEKj24XFEwGcOE8ndYfRr; Path=/; HttpOnly; Secure"
  // 1: "session=eyJyZWRpcmVjdFVyaSI6bnVsbH0=; path=/; secure; httponly"
  // 2: "session.sig=SaZR0Tt8DIt3oKMJyJ8qA58_iBw; path=/; secure; httponly"

  // const cookieWholeRE = new RegExp("^([^;]+);");
  // const cookieSettings = setCookiesHeader.map((cookie) => { return cookieWholeRE.exec(cookie)[1]; });


  if (setCookiesHeaders === undefined || setCookiesHeaders === null) {
    cy.log("Header has no cookies");
    ['_csrf', 'session', 'session.sig'].forEach(cookieName => cy.getCookie(cookieName))
  } else {
    const cookiePartsRE = new RegExp("^(.+?)=(.+?);");
    setCookiesHeaders.forEach((setCookieHeader) => {
      var matches = cookiePartsRE.exec(setCookieHeader);
      cy.log("Setting cookie: " + matches[1]);
      cy.setCookie(
        matches[1],
        matches[2],
        { domain: domain }
      );
    });
  }
}

