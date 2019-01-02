#!/bin/bash

BUNDLER_CACHE="$1"
NODE_MODULES="$2"

# path in the container
BUNDLE_PATH=/bundler-cache

function docker-run() {
  docker run --env BUNDLE_PATH=$BUNDLE_PATH \
    -v $BUNDLER_CACHE:$BUNDLE_PATH \
    -v $NODE_MODULES:/app/node_modules \
    batdevcontainerregistry.azurecr.io/manage-courses-frontend:$TRAVIS_BRANCH \
    /bin/sh -c "$1"
}

##########

docker-run "bundle check || bundle install"
docker-run "yarn"
docker-run "bundle exec rake assets:precompile"
docker-run "bundle exec rails webpacker:compile"
docker-run "bundle exec rails spec"
docker-run "bundle exec govuk-lint-ruby app config db lib spec --format clang"
docker-run "bundle exec govuk-lint-sass app/assets/stylesheets"
