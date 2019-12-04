# Cypress

## Local setup
On linux do not trust it to be effortless, who knows on mac?

1. go to [Chromium Downloads Tool](https://chromium.cypress.io/) and download the appropriate version

    1. extract content to `./cypress/browsers`

2. install node dependencies

    ```
    yarn install
    ```

3. configurations file
   1. a `./config/example.json` is available as a basis to create `./config/local.json`
   1. change the values where appropriate


## Executing tests
1. to open cypress
    ``` bash
    # using /config/local.json
    yarn run cy:open --browser ~/repos/dfe/manage-courses-frontend/cypress/browsers/chrome-linux/chrome
    ```

    ``` bash
    # native
    yarn run cy:open --env 'email=someone@test.com,password=change me' --browser ~/repos/dfe/manage-courses-frontend/cypress/browsers/chrome-linux/chrome
    ```

2. to run cypress

    ``` bash
    # using ./config/local.json
    yarn run cy:run --browser ~/repos/dfe/manage-courses-frontend/cypress/browsers/chrome-linux/chrome
    ```
    ``` bash
    # native
    yarn run cy:run --env 'email=someone@test.com,password=change me' --browser ~/repos/dfe/manage-courses-frontend/cypress/browsers/chrome-linux/chrome
    ```


## Noticable issues
1. make sure that the user used actually exists
1. fails to properly have an isolated environment, therefore download chromuim
1. opening cypress with snap chromuim on linux is not possible
1. opening cypress with electron using snap chromuim, leads to the cypress failure to improper isolates environment
1. between fails/runs make sure you close the browser that was spawned, in order for you to start from scratch
1. to ensure cookie expectation, ie clearing cookies means close the spawned browser