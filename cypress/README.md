# Cypress setup
On linux do not trust it to be effortless, who knows on mac?

go to
https://chromium.cypress.io/
and download

extract content to

```bash
./cypress/browsers
```

then yarn install
```
yarn install
```

an ./config/example.json is available as a basis to create ./config/local.json

to open cypress
```
yarn run cy:open -- --env 'email=someone@test.com,password=change me' --browser ~/repos/dfe/manage-courses-frontend/cypress/browsers/chrome-linux/chrome

# or using /config/local.json
yarn run cy:open --browser ~/repos/dfe/manage-courses-frontend/cypress/browsers/chrome-linux/chrome
```

to run cypress
```
yarn run cy:run --env 'email=someone@test.com,password=change me' --browser ~/repos/dfe/manage-courses-frontend/cypress/browsers/chrome-linux/chrome

# or using ./config/local.json
yarn run cy:run --browser ~/repos/dfe/manage-courses-frontend/cypress/browsers/chrome-linux/chrome
```

## upgrading cypress
version 3.6.1 of cypress is broken, so use version 3.6.0 or 3.7.0

## Noticable issues
- make sure that the user used exists
- is that it fails to properly have an isolated environment, therefore download chromuim
- opening cypress with snap chromuim on linux is not possible
- opening cypress with electron using snap chromuim, leads to the cypress failure to properly isolate enviroment
- between fails make sure you close the browser that was spawned, inorder for you to start from scratch
- to ensure cookie expectation, ie clearing cookies means clearing cookie, close the spawn browser