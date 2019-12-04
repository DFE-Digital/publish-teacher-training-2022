Cypress.Commands.add('signIn', (username = Cypress.env('email'), password = Cypress.env('password')) => {
  Cypress.Cookies.debug(true);

  cy.clearCookies();

  const baseUrl = Cypress.config().baseUrl;

  const params = {
    method: 'GET',
    url: baseUrl,
    followRedirect: false,
  };

  cy.log('initialRequestOptions', params);

  const url = new URL(baseUrl);

  cy.request(params)
    .then(response => {
      if (response.status === 302 && response.headers.location === `${url.origin}/signin`) {
        return authenticateWithDFESignIn(url.origin, username, password);
      } else {
        return response;
      };
    })
});

function appAuthRequest(url) {
  const params = {
    method: 'GET',
    url: url,
    followRedirect: false,
  };

  cy.log("appAuthRequestOptions", params);

  return cy.request(params);
};

function loginGetRequest(response) {
  const params = {
    method: 'GET',
    url: response.redirectedToUrl,
    followRedirect: true,
  };

  cy.log("loginGetRequestOptions", params);

  return cy.request(params);
};

function loginPostRequest(username, password) {
  return (response) => {
    const totalRequestResponses = response.allRequestResponses.length;

    if (totalRequestResponses === 5) {
      return cy.log("Already logged in, skipping login sequence", totalRequestResponses);
    }

    const lastResponse = response.allRequestResponses[totalRequestResponses - 1];
    const authURL = lastResponse["Request URL"];
    const setCookiesHeaders = lastResponse["Response Headers"]["set-cookie"];

    setCookiesFromHeaders(setCookiesHeaders, authURL.hostname);

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

    cy.log('loginPostRequestOptions', params);

    return cy.request(params);
  };
};

function continuePostRequest(response) {
  const totalRequestResponses = response.allRequestResponses.length;
  expect(totalRequestResponses).to.eq(1, 'Cookie is cleared properly');

  const form = getForm(response.body);
  const formInputs = arrayToObject(form.querySelectorAll('input'));

  const params = {
    method: 'POST',
    url: form.action,
    failOnStatusCode: true,
    form: true,
    body: formInputs,
  };

  cy.log('continuePostRequestOptions', params);

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
  // These '_csrf', 'session', 'session.sig' cookies should be set.
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
