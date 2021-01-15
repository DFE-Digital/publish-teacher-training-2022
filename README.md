![Deploy](https://github.com/DFE-Digital/publish-teacher-training/workflows/Deploy/badge.svg)
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

### 3. Run the server

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

## Basic auth

Basic auth is enabled in non-production and non-local environments. The credentials can be found in the Confluence pages.

## Persona login

Persona login is availale in local development and non-production environments. This allows you to log in to existing anonymised accounts or pre-selected accounts identified by personas.

## Using DfE Sign-In

Occasionally you may want to test the system integration with DfE Sign-In. In
the dev environment the system is configured to use basic auth so you need to
take a few extra steps to make it work with DfE Sign-In.

### Disable developer auth

The developer auth strategy supercedes DfE Sign-In and must be disabled first.

In `config/settings/development.local.yml` set `developer_auth` to `false`

The app must be rebooted in order for this change to take affect.

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
