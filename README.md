[![Build Status](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_apis/build/status/Find/publish-teacher-training?branchName=master)](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_build/latest?definitionId=29&branchName=master)
[![Maintainability](https://api.codeclimate.com/v1/badges/e743af6a7da51c328a54/maintainability)](https://codeclimate.com/github/DFE-Digital/publish-teacher-training/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/e743af6a7da51c328a54/test_coverage)](https://codeclimate.com/github/DFE-Digital/publish-teacher-training/test_coverage)

# Publish Teacher Training

## Development setup

### 1. Install build dependencies

Install [asdf-vm](https://asdf-vm.com/).

Install the plugins and versions specified in `.tool-versions`

```
asdf plugin add ruby
asdf plugin add nodejs
asdf plugin add yarn
asdf install
```

When the versions are updated in master run `asdf install` again to update your
installation.

(We don't mandate asdf, you can use other tools if you prefer.)

### 2. Run the builds

Run the following commands:

```bash
yarn
bundle
bundle exec rake webpacker:compile
```

### 3. Setup Basic Auth Login

For local development, we rely on Basic Auth instead of DFE Sign-In, which can
be enabled if required. This will require that you have a login in the database,
this will be there if you have an account in production but if you don't yet, or
don't want to use it, you can create a user locally with:

```ruby
# Optional, use if you don't already have an account.
User.create(admin: true,
            email: "john.smith@digital.education.gov.uk",
            first_name: "John",
            last_name: "Smith",
            welcome_email_date_utc: Time.zone.now,
            accept_terms_date_utc: Time.zone.now,
            invite_date_utc: Time.zone.now,
            state: "transitioned")
```

Then create the file `config/settings/development.local.yml` with the contents:

```yaml
authorised_users:
  0:
    first_name: [your first name, this will be updated in the db]
    last_name: [your last name, this will be updated in the db]
    email: [the email address to login with]
    password: [the password you wish to use]
```


### 4. Run the server

1. Run `bundle exec rails s` to launch the app on https://localhost:3000.

You'll need a running
[teacher-training-api](https://github.com/DFE-Digital/teacher-training-api).

## Docker

Install Docker and Docker Compose.

```bash
docker-compose up --build
```

_Warning_: Running docker seems to slow down local development significantly on macOS.

## Running specs

Note: the rspec tests will fail until the site has been run for the first time.

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
bundle exec rubocop app config lib spec Gemfile --format clang -a

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

## Using DfE Sign-In

Occasionally you may want to test the system integration with DfE Sign-In. In
the dev environment the system is configured to use basic auth so you need to
take a few extra steps to make it work with DfE Sign-In.

### Ensure You Have a DfE Sign-In Account

You likely already have an account for certain environments, but you will need
to ensure you have an account in the DfE Sign-In test environment to be able to
login locally. Check with team members on how to do this.

### Configure DfE Sign-In

Create the following file and ask the team for the secret.

```yaml
# config/settings/development.local.yml
dfe_signin:
    secret: dfe_sign_in_test_server_client_secret_here
```

### Trust the TLS certificate

Depending on your browser you may need to add the automatically generated SSL
certificate to your OS keychain to make the browser trust the local site.

On macOS:

```bash
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain config/localhost/https/localhost.crt
```

### Run The Server in SSL Mode

You'll have to configure the server to run in SSL mode by setting the
environment variable `SETTINGS__USE_SSL`, for example, use this command to run
the server:

```bash
SETTINGS__USE_SSL=1 rails s
```

## Cypress

1. Configurations file
   1. A `./end-to-end-tests/config/example.json` is available as a basis to create `./end-to-end-tests/config/local.json`
   1. Change the values where appropriate

### Executing tests

1. From project root change directory to `end-to-end-tests`
    ``` bash
    cd end-to-end-tests
    ```
2. install dependancies
    ``` bash
    yarn install
    ```

3. To open cypress
    ``` bash
    # using ~/repos/dfe/publish-teacher-training/end-to-end-tests/config/local.json
    yarn run cy:open
    ```

    ``` bash
    # native
    yarn run cy:open --env 'email=someone@test.com,password=change me'
    ```

4. To run cypress
    ``` bash
    # using $PWD/end-to-end-tests/config/local.json
    yarn run cy:run
    ```

    ``` bash
    # native
    yarn run cy:run --env 'email=someone@test.com,password=change me'
    ```

### Additional required setup
1. User needs to be setup in dfe sigin
2. User needs to have the a single provider/organisation setup in the database

```bash
# creates the test `user` if missing
psql -d "your_db" -c "INSERT INTO \"user\" (email, first_name, last_name, state, accept_terms_date_utc) VALUES ('someone@test.com', 'integration', 'tests', 'transitioned', current_timestamp) ON CONFLICT (email) DO nothing;"

# creates the `provider` `bat 1 (B1T)` if missing
psql -d "your_db" -c "INSERT INTO \"provider\" (provider_code, provider_name, recruitment_cycle_id, scheme_member, provider_type, accrediting_provider) VALUES ('B1T', 'bat 1', (SELECT id FROM \"recruitment_cycle\" ORDER BY year DESC limit 1), 'N', 'O', 'Y') ON CONFLICT (provider_code, recruitment_cycle_id) DO nothing;"

# creates the `organisation` `Borg` if missing
psql -d "your_db" -c "INSERT INTO \"organisation\" (name) (SELECT 'Borg' WHERE NOT EXISTS (SELECT id FROM \"organisation\" WHERE name = 'Borg'));"

# creates the `organisation_provider` association if missing
psql -d "your_db" -c "INSERT INTO \"organisation_provider\" (provider_id, organisation_id) (SELECT (SELECT id FROM \"provider\" WHERE provider_code = 'B1T' AND recruitment_cycle_id = (SELECT id FROM \"recruitment_cycle\" ORDER BY year DESC limit 1)), (SELECT id FROM organisation WHERE name = 'Borg') WHERE NOT EXISTS (SELECT * FROM \"organisation_provider\" WHERE provider_id=(SELECT id FROM \"provider\" WHERE provider_code = 'B1T' AND recruitment_cycle_id = (SELECT id FROM \"recruitment_cycle\" ORDER BY year DESC limit 1)) AND organisation_id = (SELECT id FROM \"organisation\" WHERE name = 'Borg')));"

# creates `organisation_user` association for test `user` if missing
psql -d "your_db" -c "INSERT INTO \"organisation_user\" (user_id, organisation_id) SELECT ( SELECT id FROM \"user\" WHERE email = 'someone@test.com'), (SELECT id FROM \"organisation\" WHERE name = 'Borg') ON CONFLICT (user_id, organisation_id) DO nothing;"

# creates `organisation_user` association for admin `user` if missing
psql -d "your_db" -c "INSERT INTO \"organisation_user\" (user_id, organisation_id) SELECT id, (SELECT id FROM \"organisation\" WHERE name = 'Borg') FROM \"user\" WHERE admin = TRUE ON CONFLICT (user_id, organisation_id) DO nothing;"

```


### Optional custom browser
1. Download the appropriate version browser from [Chromium Downloads Tool](https://chromium.cypress.io/).
    1. Extract content to `./end-to-end-tests/browsers`
    2. Then open like so
      ``` bash
        yarn run cy:run --browser $PWD/end-to-end-tests/browsers/chrome-linux/chrome
      ```

### Noticable issues
1. Make sure that the user used actually exists
2. It does not work with snap chromuim so either install chromuim via package manager or setup optional custom browser
3. Between executing tests, make sure you close the browser that was spawned, in order for you to start from scratch, due to state retentations.
4. To ensure cookie expectation, ie clearing cookies means close the spawned browser
