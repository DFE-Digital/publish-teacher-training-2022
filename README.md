[![Build Status](https://travis-ci.org/DFE-Digital/dfe-rails-boilerplate.svg?branch=master)](https://travis-ci.com/DFE-Digital/dfe-rails-boilerplate)

# DfE Rails Boilerplate

## Prerequisites

- Ruby 2.5.3
- PostgreSQL
- NodeJS 8.11.x
- Yarn 1.12.x

## Setting up the app in development

1. Run `bundle install` to install the gem dependencies
2. Run `yarn` to install node dependencies
3. Run `bin/rails db:setup` to set up the database development and test schemas, and seed with test data.
4. Run `bundle exec foreman start -f Procfile.dev` to launch the app on http://localhost:5000.

## Running with Docker

Instead of the above, you can use [Docker](https://docs.docker.com) as follows:

```bash
$ docker-compose up --build
```

And access it normally via http://localhost:3000

To stop it, run `docker-compose stop`.

NOTE: If you have changed your working directory (e.g. checkout a branch, edit a file) you have to rerun `docker-compose build` before running `docker-compose up -d` to ensure all changes are picked up.

## Linting

It's best to lint just your app directories and not those belonging to the framework, e.g.

```bash
bundle exec govuk-lint-ruby app lib spec
```
