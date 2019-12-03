import { getTopFrame } from "jest-message-util";

const baseUrl = Cypress.config().baseUrl;

describe("login", function () {
  Cypress.Commands.add('signIn', (username = Cypress.env('email'), password = Cypress.env('password')) => {
    Cypress.Cookies.debug(true);

    cy.clearCookies();

    const initialRequest = {
      method: 'GET',
      url: baseUrl,
      followRedirect: false,
    };

    const url = new URL(baseUrl);

    cy.log(initialRequest);
    cy.log(baseUrl);

    cy.request(initialRequest)
      .then(response => {
        if (response.status == 302 && response.headers.location == `${url.origin}/signin`) {
          return authenticateWithDFESignIn(url.origin, username, password);
        } else {
          return response;
        };
      })
  });

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

// step 1
function appAuthRequest(url) {
  const params = {
    method: 'GET',
    url: url,
    followRedirect: false,
  };

  cy.log("appAuthRequest", params);

  return cy.request(params);
};

function loginGetRequest(response) {
  const params = {
    method: 'GET',
    url: response.redirectedToUrl,
    followRedirect: true,
  };

  cy.log(params);

  return cy.request(params);
};

function loginPostRequest(username, password) {
  return (response) => {
    const authResponses = response.allRequestResponses.length;

    if (authResponses === 5) {
      return cy.log("already logged in, skipping login sequence");
    }

    const lastResponse = response.allRequestResponses[response.allRequestResponses.length - 1];
    const authURL = lastResponse["Request URL"];
    const setCookiesHeaders = lastResponse["Response Headers"]["set-cookie"];

    setCookiesFromHeaders(setCookiesHeaders, authURL.hostname);

    // cy.log(`curl -b '${cookieHeaders.join("; ")}' -d username=${username} -d password='${password} -d _csrf='${csrfToken} -d cliendId='${clientId} -d redirectUri='${redirectUri}' '${authURL}'`);

    const form = getForm(response.body);
    const formInputs = arrayToObject(form.querySelectorAll('input'), {
      username: username,
      password: password,
    });

    const params = {
      method: 'POST',
      url: authURL,
      failOnStatusCode: false,
      form: true,
      body: formInputs,
    };

    cy.log(params);

    return cy.request(params);
  };
};

function continuePostRequest(response) {
  const loginResponses = response.allRequestResponses.length;
  expect(loginResponses).to.eq(1);

  const form = getForm(response.body);
  const formInputs = arrayToObject(form.querySelectorAll('input'));

  const params = {
    method: 'POST',
    url: form.action,
    failOnStatusCode: true,
    form: true,
    body: formInputs,
  };

  cy.log(params);

  return cy.request(params);
};

function authenticateWithDFESignIn(origin, username, password) {
  return appAuthRequest(`${origin}/auth/dfe`)  // authentication request to our app
    .then(loginGetRequest) // initial sign-in request, since we can't follow cross-site redirects
    .then(loginPostRequest(username, password)) // POST login
    .then(response => {
      if (response == undefined) {
        return response;
      } else {
        return continuePostRequest(response); // POST continue
      }
    });
};

function getForm(body) {
  return Cypress.$(body).find('form')[0];
};

function arrayToObject(inputs, overrides) {
  inputs = Array.from(inputs);
  const reducer = (obj, item) => {
    obj[item.name] = item.value;
    return obj;
  };
  return Object.assign(inputs.reduce(reducer, {}), overrides);
};

function setCookiesFromHeaders(setCookiesHeaders, domain) {
  // setCookiesHeaders is a list of the set-cookie headers in the response:
  // 0: "_csrf=KDonEKj24XFEwGcOE8ndYfRr; Path=/; HttpOnly; Secure"
  // 1: "session=eyJyZWRpcmVjdFVyaSI6bnVsbH0=; path=/; secure; httponly"
  // 2: "session.sig=SaZR0Tt8DIt3oKMJyJ8qA58_iBw; path=/; secure; httponly"

  // const cookieWholeRE = new RegExp("^([^;]+);");
  // const cookieSettings = setCookiesHeader.map((cookie) => { return cookieWholeRE.exec(cookie)[1]; });


  if (setCookiesHeaders === undefined || setCookiesHeaders === null) {
    cy.log("Header has no cookies");
    ['_csrf', 'session', 'session.sig'].forEach(cookieName => cy.getCookie(cookieName));
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
};

