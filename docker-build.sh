#!/bin/bash
set -e

source config.sh

DOCKER_REGISTRY_HOST=$DOCKER_REGISTRY_HOST ./docker-login.sh

DOCKER_MASTER_TAG="$DOCKER_PATH:master"
DOCKER_BRANCH_TAG="$DOCKER_PATH:latest"

echo "Pulling $DOCKER_MASTER_TAG to populate layer cache..."
# Pull the latest build so that we can re-use the layers as part of the cache when building.
# Based on http://atodorov.org/blog/2017/08/07/faster-travis-ci-tests-with-docker-cache/
docker pull "$DOCKER_MASTER_TAG"

echo "Running docker build..."
docker build --cache-from "$DOCKER_MASTER_TAG" -t "$DOCKER_BRANCH_TAG" -f Dockerfile .

function docker-run() {
  echo "Running docker command: $1 ..."
  docker run "$DOCKER_BRANCH_TAG" /bin/sh -c "$1"
}

function bundle-run() {
  docker-run "$1"
}

echo "Running webpack..."
bundle-run "rails webpacker:compile"

echo "Running tests..."
bundle-run "rails spec"

echo "Running linters..."
bundle-run "govuk-lint-ruby app config db lib spec --format clang"
bundle-run "govuk-lint-sass app/webpacker/stylesheets"
