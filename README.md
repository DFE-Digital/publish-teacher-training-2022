[![Build Status](https://travis-ci.org/DFE-Digital/manage-courses-frontend.svg?branch=master)](https://travis-ci.org/DFE-Digital/manage-courses-frontend)

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

## Docker

Install Docker and Docker Compose.

```bash
docker-compose up --build
```

## Linting

It's best to lint just your app directories and not those belonging to the framework, e.g.

```bash
bundle exec govuk-lint-ruby app config db lib spec --format clang
```
