Developing against Teacher Training API
=======================================

Publish does not have its own database as it is a front-end to the [Teacher Training API](https://github.com/DFE-Digital/teacher-training-api).
Working locally the two apps are configured on different ports and can be run together. An anonymised production database dump can be retrieved by following [these instructions](https://dfedigital.atlassian.net/wiki/spaces/BaT/pages/2657157167/Seeding+local+database+with+production+data).

## QA

In the QA environment - https://qa.publish-teacher-training-courses.service.gov.uk, Publish is backed by the QA version of TTAPI. This is synced nightly with an anonymised production dump. Publish has persona login in this environment and is protected with basic auth.

## Staging

In the staging environment - https://staging.publish-teacher-training-courses.service.gov.uk, Publish is backed by the staging version of TTAPI. This is synced nightly with an anonymised production dump. Publish has full DfE Signin authentication in this environment (Pre-prod DfE Signin)

## Production

In the production environment - https://www.publish-teacher-training-courses.service.gov.uk, Publish is backed by the production version of TTAPI. Publish has full DfE Signin authentication in this environment.

We also have rollover and sandbox environments that have their own TTAPI instances and databases that are not synced or restored.

## Review Apps

When a PR is opened on this repo a review app is created in PaaS and linked from a comment in the PR. These review apps are all backed by the QA instance of TTAPI.

## What if I need the TTAPI database to be in a particular state

Well... you're in luck. There are some options.

### If the changes are minor and unlikely to affect other review apps or are only going to be around for a short while they can often be made to the QA TTAPI.

Good:

* Simple
* All review apps and QA will pick up the changes automatically

Bad:

* All review apps and QA will pick up the changes automatically. This may not be what you want.
* The QA environment is reset overnight

### Set up a whole new environment (or use an existing one like rollover)

Good

* You can run riot with the changes as they will be isolated from everything else
* The environment won't be reset

Bad:

* A bit more time consuming to set up
* You'll probably require infrastructure support unless you speak fluent PaaS.

### Deploy a TTAPI PR with the appropriate configuration

Good:

* Isolated
* Simple

Bad: 

* Config is a bit of a faff  

## Configuring a pair of review apps

* Open a PR on TTAPI
* This will create a review app in the bat-qa space
* `cf login --sso` to authenticate with GOVUK PaaS
* Choose the bat-qa space (or `cf target -s bat-qa` if coming from another space)
* `cf apps` will list the apps, including your PR e.g. teacher-training-api-pr-1973 and also the URL to the app e.g. teacher-training-api-pr-1973.london.cloudapps.digital
* `cf ssh <app-name>` will get you onto the app if required and regular commands and the rails console will work from there. (from within the /app directory)
* In publish update config/settings/review.yml. Set `teacher_training_api` -> `base_url` to point to the URL of the TTAPI review app
* Open a PR on publish containing the updated review.yml and any changes that require testing
* The publish review app should now be running against the TTAPI review app
* The app 'pair' will persist for as long as the PRs are open

Oh... and don't forget to remove the settings.yml changes before you merge your PR.

Author: Graham Pengelly 
Review: 07-01-2022
