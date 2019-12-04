[![Build Status](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_apis/build/status/Find/manage-courses-frontend?branchName=master)](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_build/latest?definitionId=29&branchName=master)

# Manage Courses Frontend

## Prerequisites

- Ruby 2.6.1
- NodeJS 8.11.x
- Yarn 1.12.x

## Setting up the app in development

1. Run `yarn` to install node dependencies
2. Run `bundle install` to install the gem dependencies
3. Create new file `config/settings/development.local.yml` with the below contents.
4. Run `bundle exec rails s` to launch the app on https://localhost:3000.

### Sign-in config

```
# config/settings/development.local.yml
dfe_signin:
    secret: dfe_sign_in_test_server_client_secret_here
```

### Trust the TLS certificate

You will also need to add the automatically generated SSL certificate to your OS keychain to make the browser trust the local site.

On macOS:

```bash
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain config/localhost/https/localhost.crt
```

## Docker

Install Docker and Docker Compose.

```bash
docker-compose up --build
```

_Warning_: Running docker seems to slow down local development significantly on macOS.


## Running specs

```
bundle exec rspec
```

## Running specs in parallel

```
# This uses the max available cores
bundle exec rails parallel:spec

# Modify the number of cores
bundle exec rails parallel:spec[number]
```

## Running specs and linter (SCSS and Ruby)

NB: This will run specs in parallel using the maximum cores available. To change
the number of cores set the following environment variable -
`PARALLEL_CORES`.

```
bundle exec rake
```

Or through guard (`--no-interactions` allows the use of `pry` inside tests):

```bash
bundle exec guard --no-interactions
```

## Linting

It's best to lint just your app directories and not those belonging to the framework, e.g.

```bash
bundle exec rubocop app config db lib spec Gemfile --format clang -a

or

bundle exec govuk-lint-sass app/webpacker/styles
```

## Secrets vs Settings

Refer to the [the config gem](https://github.com/railsconfig/config#accessing-the-settings-object) to understand the `file based settings` loading order.

To override file based via `Machine based env variables settings`

```bash
cat config/settings.yml
file
  based
    settings
      env1: 'foo'
```

```bash
export SETTINGS__FILE__BASED__SETTINGS__ENV1="bar"
```

```ruby
puts Settings.file.based.setting.env1

bar
```

Refer to the [settings file](config/settings.yml) for all the settings required to run this app

## Sentry

To track exceptions through Sentry, configure the `SENTRY_DSN` environment variable:

```
SENTRY_DSN=https://aaa:bbb@sentry.io/123 rails s
```


## Using Basic Auth Instead of DFE Sign-In

For local development, you can disable reliance on DFE Sign-In by creating a
file `config/settings/development.local.yml` with the contents:

```yaml
authorised_user:
  first_name: [your first name, this will be updated in the db]
  last_name: [your last name, this will be updated in the db]
  email: [the email address to login with]
  password: [the password you wish to use]
```

The email address has to exist in the users table of manage-courses-backend, but
the password can be any non-secure local password you care to use.

## Cypress

1. Configurations file
   1. A `./e2e/config/example.json` is available as a basis to create `./e2e/config/local.json`
   1. Change the values where appropriate

### Custom browser
1. Download the appropriate version browser from [Chromium Downloads Tool](https://chromium.cypress.io/).
    1. Extract content to `./e2e/browsers`

### Executing tests

1. To open cypress
    ``` bash
    # using ~/repos/dfe/manage-courses-frontend/e2e/config/local.json
    yarn run cy:open --browser $PWD/e2e/browsers/chrome-linux/chrome
    ```

    ``` bash
    # native
    yarn run cy:open --env 'email=someone@test.com,password=change me' --browser $PWD/e2e/browsers/chrome-linux/chrome
    ```

2. To run cypress
    ``` bash
    # using $PWD/e2e/config/local.json
    yarn run cy:run --browser $PWD/e2e/browsers/chrome-linux/chrome
    ```

    ``` bash
    # native
    yarn run cy:run --env 'email=someone@test.com,password=change me' --browser $PWD/e2e/browsers/chrome-linux/chrome
    ```

### Noticable issues
1. Make sure that the user used actually exists
1. Fails to properly have an isolated environment, therefore download chromuim
1. Opening cypress with snap chromuim on linux is not possible
1. Opening cypress with electron using snap chromuim, leads to the cypress failure to improper isolates environment
1. Between executing tests, make sure you close the browser that was spawned, in order for you to start from scratch, due to state retentations.
1. To ensure cookie expectation, ie clearing cookies means close the spawned browser