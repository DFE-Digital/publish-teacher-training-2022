[![Build Status](https://travis-ci.org/DFE-Digital/manage-courses-frontend.svg?branch=master)](https://travis-ci.org/DFE-Digital/manage-courses-frontend)

# Manage Courses Frontend

## Prerequisites

- Ruby 2.3.3
- NodeJS 8.11.x
- Yarn 1.12.x

## Setting up the app in development

1. Run `bundle install` to install the gem dependencies
2. Run `yarn` to install node dependencies
3. Run `bundle exec foreman start -f Procfile.dev` to launch the app on http://localhost:5000.

## Linting

It's best to lint just your app directories and not those belonging to the framework, e.g.

## Docker

Install Docker and Docker Compose.

```bash
docker-compose up --build
```

```bash
bundle exec govuk-lint-ruby app lib spec
```
