#!/bin/bash
set -e

# DEBUG: print env

env

# Set up script vars
DOCKER_IMAGE_TAG=$TAG
DOCKER_RUN="docker run $DOCKER_IMAGE_TAG /bin/sh -c"
DOCKER_HUB_USERNAME=$DOCKERHUBUSERNAME
DOCKER_HUB_PASSWORD=$password

echo "Building image: $DOCKER_IMAGE_TAG"
docker build -f Dockerfile -t $DOCKER_IMAGE_TAG .

echo "Run webpacker"
$DOCKER_RUN "rails webpacker:compile"

echo "Run tests"
$DOCKER_RUN 'rails spec SPEC_OPTS="--format RspecJunitFormatter"' | sed -e 1d >> rspec-results.xml

echo "Run linters"
$DOCKER_RUN "govuk-lint-ruby app config db lib spec --format clang"
$DOCKER_RUN "govuk-lint-sass app/webpacker/stylesheets"

echo "Pushing image"
echo $DOCKER_HUB_PASSWORD | docker login --username $DOCKER_HUB_USERNAME --password-stdin
docker push $DOCKER_IMAGE_TAG
