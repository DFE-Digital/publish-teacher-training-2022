[![Build Status](https://travis-ci.org/DFE-Digital/manage-courses-frontend.svg?branch=master)](https://travis-ci.org/DFE-Digital/manage-courses-frontend)
[![Build Status](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_apis/build/status/Find/manage-courses-frontend?branchName=master)](https://dfe-ssp.visualstudio.com/Become-A-Teacher/_build/latest?definitionId=29&branchName=master)

# Manage Courses Frontend

## Prerequisites

- Ruby 2.6.1
- NodeJS 8.11.x
- Yarn 1.12.x

## Setting up the app in development

1. [Follow these instructions to configure HTTPS](config/localhost/https/README.md)
3. Run `yarn` to install node dependencies
2. Run `bundle install` to install the gem dependencies
4. Run `bundle exec foreman start -f Procfile.dev` to launch the app on http://localhost:3000.
5. Run `./bin/webpack-dev-server` in a separate shell for faster compilation of assets.

## Docker

Install Docker and Docker Compose.

```bash
docker-compose up --build
```

*Warning*: Running docker seems to slow down local development significantly on macOS.

## Running specs and linter (SCSS and Ruby)
```
bundle exec rake
```

## Running specs
```
bundle exec rspec
```

## Linting

It's best to lint just your app directories and not those belonging to the framework, e.g.

```bash
bundle exec govuk-lint-ruby app config db lib spec Gemfile --format clang -a

or

bundle exec govuk-lint-sass app/webpacker/styles
```
