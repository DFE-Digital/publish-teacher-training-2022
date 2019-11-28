
// const url = 'https://www.qa.publish-teacher-training-courses.service.gov.uk';
const jsdom = require("jsdom");
const { JSDOM } = jsdom;

const urlBase = "https://localhost:3000";
const _ = Cypress._;

describe("login", function () {

  Cypress.Commands.add('loginWithSignIn', (username, password) => {
    Cypress.Cookies.debug(true);

    var step1_option = {
      method: 'GET',
      url: `${urlBase}/auth/dfe`,
      followRedirect: false
    };
    console.log("1");
    console.log(step1_option.url);

    // var extractGuidFromUrl = (url) => {
    //   var re = new RegExp("/([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})/");

    //   return re.exec(url)[1];
    // };

    cy.clearCookies()

    return cy.request(step1_option)
      .then((resp) => {
        console.log(`GET ${resp.redirectedToUrl}`);
        return cy.request({
          method: 'GET',
          url: resp.redirectedToUrl,
          followRedirect: true
        });
      })
      .then(response => {
        var authURL = new URL(
          response.allRequestResponses[response.allRequestResponses.length - 1]["Request URL"]
        );

        const html = Cypress.$(response.body);
        // const csrfToken = $html.find("input[name=_csrf]").val();
        // const clientId = $html.find("input[name=clientId]").val();
        // const redirectUri = $html.find("input[name=redirectUri]").val();
        var formInputs = getMapOfFormInputs(html.find('input'));
        formInputs.username = username;
        formInputs.password = password;

        const responses = response["allRequestResponses"];
        const setCookiesHeaders = responses[responses.length - 1]["Response Headers"]["set-cookie"];
        if(setCookiesHeaders != undefined) {
          setCookiesFromHeaders(setCookiesHeaders, authURL.hostname);
        }

        console.log("  get auth response:");
        logger(response);
        console.log("  login page formInputs:");
        logger(formInputs);
        debugger;
        // console.log(`curl -b '${cookieHeaders.join("; ")}' -d username=${username} -d password='${password} -d _csrf='${csrfToken} -d cliendId='${clientId} -d redirectUri='${redirectUri}' '${authURL}'`);

        console.log(`POST ${authURL.toString()}`);
        return cy.request({
          method: 'POST',
          url: authURL.toString(),
          failOnStatusCode: false,
          form: true,
          body: formInputs,
          //   username: username,
          //   password: password,
          //   _csrf: csrfToken,
          //   clientId: clientId,
          //   redirectUri: redirectUri,
          // },
        });
      }).then((response) => {
        console.log("login post response:");
        logger(response);
        var continueParams = {};
        const html = Cypress.$(response.body);

        var formInputs = getMapOfFormInputs(html.find('input'));
        // $html.find("input").map((idx, input) => {
        //   continueParams[input.name] = input.value;
        //   console.log(`${input.name}: ${input.value}`);
        // });
        var continueURL = html.find("form")[0].action;
        debugger;

        console.log(`POST ${continueURL.toString()}`);
        return cy.request({
          method: 'POST',
          url: continueURL.toString(),
          failOnStatusCode: true,
          form: true,
          body: formInputs,
        });
      }).then((response => { console.log; }));
  });

  it("logging in ", function () {
    cy.loginWithSignIn("tim.abell+4@digital.education.gov.uk", 'omgsquirrel!88');
    //   .then((resp) => {
    //     debugger;
    //     expect(resp.status).to.eq(200);
    //     expect(resp.url).to.eq('https://localhost:3000/');
    // });
    cy.visit(urlBase);
  });
});


function logger(thing) {
  console.log(JSON.parse(JSON.stringify(thing)));
}

// Convert inputs into a mapping of input name to value for convenience.
//
// The "inputs" param is the input nodes from the HTML dom, e.g.
// $html.find('input')
function getMapOfFormInputs(inputs) {
  return Object.fromEntries(inputs.map((idx, input) => {
    return [[input.name, input.value]];
  }));
}

function setCookiesFromHeaders(setCookiesHeaders, domain) {
  // setCookiesHeaders is a list of the set-cookie headers in the response:
  // 0: "_csrf=KDonEKj24XFEwGcOE8ndYfRr; Path=/; HttpOnly; Secure"
  // 1: "session=eyJyZWRpcmVjdFVyaSI6bnVsbH0=; path=/; secure; httponly"
  // 2: "session.sig=SaZR0Tt8DIt3oKMJyJ8qA58_iBw; path=/; secure; httponly"

  // const cookieWholeRE = new RegExp("^([^;]+);");
  // const cookieSettings = setCookiesHeader.map((cookie) => { return cookieWholeRE.exec(cookie)[1]; });

  const cookiePartsRE = new RegExp("^(.+?)=(.+?);");
  setCookiesHeaders.forEach((setCookieHeader) => {
    var matches = cookiePartsRE.exec(setCookieHeader);
    console.log("Setting cookie: " + matches[1]);
    cy.setCookie(
      matches[1],
      matches[2],
      { domain: domain }
    );
  });
}

