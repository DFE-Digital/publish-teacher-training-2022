
// const url = 'https://www.qa.publish-teacher-training-courses.service.gov.uk';
const jsdom = require("jsdom");
const { JSDOM } = jsdom;

const urlBase = "https://localhost:3000"
const _ = Cypress._
describe("login", function () {

  it("logging in ", function () {

    var step1_option = {
          method: 'GET',
          url: `${urlBase}/auth/dfe`,
          followRedirect: false
        }
        console.log("1");
        console.log(step1_option.url);

      var extractGuidFromUrl = (url) => {
        var re = new RegExp("/([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})/");

        return re.exec(url)[1];
      };
    cy.request(step1_option)
      .then((resp) => {
       return cy.request({
            method: 'GET',
            url: resp.redirectedToUrl,
            followRedirect: true
          })
        })
      .then(allResp => {

        var respo = allResp.allRequestResponses[allResp.allRequestResponses.length - 1]["Response Body"];
        var dom = new JSDOM(respo);

        var form = {};

        Array.from(dom.window.document.querySelectorAll("input"))
          .forEach((item) => { form[item.name] = item.value})

        form.username = "tim.abell+4@digital.education.gov.uk";
        form.password = 'omgsquirrel!88';

        return {
          // this is the one we should extract guid
            lastUrl: allResp.allRequestResponses[allResp.allRequestResponses.length - 1]["Request URL"]        ,
            previousUrl: allResp.allRequestResponses[allResp.allRequestResponses.length - 2]["Request URL"],
            form: form
        }
      })
      .then(login => {
        console.log(login)
        var guid = extractGuidFromUrl(login.lastUrl);



        return cy.request({
          method: 'POST',
          url: login.lastUrl,
          // url: redirects.lastUrl,
          followRedirect: true,
          form: true, // we are submitting a regular form body
          body: login.form
         })
      })

      .then(console.log);
  });
});


// body: {
//   username: "tim.abell+4@digital.education.gov.uk",
//   password: 'omgsquirrel!88',
//   clientId: "bats2",
//   redirectUri: "https://localhost:3000/auth/dfe/callback",
//   _csrf: ""
//   // <input type="hidden" name="_csrf" value="v6vVtmmb-mUXefRdss8w4uHdV9BESxJtqvuo" />
//   // <input type="hidden" name="clientId" value="bats2"/>
//   // <input type="hidden" name="redirectUri" value="https://localhost:3000/auth/dfe/callback"/>


// },
