#!/bin/sh
echo "$AZURE_CR_PASSWORD" | docker login batdevcontainerregistry.azurecr.io -u="batdevcontainerregistry" --password-stdin
docker push batdevcontainerregistry.azurecr.io/manage-courses-frontend:$TRAVIS_BRANCH
