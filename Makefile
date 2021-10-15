ifndef VERBOSE
.SILENT:
endif

help:
	echo "Environment setup targets:"
	echo "  review     - configure for review app"
	echo "  qa"
	echo "  staging"
	echo "  production"
	echo ""
	echo "Commands:"
	echo "  deploy-plan - Print out the plan for the deploy, does not deploy."
	echo ""
	echo "Command Options:"
	echo "      APP_NAME  - name of the review application being setup, only required when DEPLOY_ENV is review"
	echo "      IMAGE_TAG - git sha of a built image, see builds in GitHub Actions"
	echo "      PASSCODE  - your authentication code for GOVUK PaaS, retrieve from"
	echo "                  https://login.london.cloud.service.gov.uk/passcode"
	echo ""
	echo "Examples:"
	echo "  Create a review app"
	echo "    You will need to retrieve the authentication code from GOVUK PaaS"
	echo "    visit https://login.london.cloud.service.gov.uk/passcode. Then run"
	echo "    deploy-plan to test:"
	echo ""
	echo "        make review APP_NAME=<APP_NAME> deploy-plan IMAGE_TAG=GIT_REF PASSCODE=<CF_SSO_CODE>"
	echo "  Delete a review app"
	echo ""
	echo "        make review APP_NAME=<APP_NAME> destroy IMAGE_TAG=GIT_REF PASSCODE=<CF_SSO_CODE>"
	echo "Examples:"
	echo "  Deploy an pre-built image to qa"
	echo ""
	echo "        make qa deploy IMAGE_TAG=GIT_REF PASSCODE=<CF_SSO_CODE>"

review:
	$(eval DEPLOY_ENV=review)
	$(if $(APP_NAME), , $(error Missing environment variable "APP_NAME", Please specify a name for your review app))
	$(eval AZ_SUBSCRIPTION=s121-findpostgraduateteachertraining-development)
	$(eval backend_key=-backend-config=key=pr-$(APP_NAME).tfstate)
	$(eval export TF_VAR_paas_app_environment_config=review)
	$(eval export TF_VAR_paas_app_environment=review-$(APP_NAME))
	$(eval export TF_VAR_paas_web_app_host_name=$(APP_NAME))
	echo Review app: https://publish-teacher-training-pr-$(APP_NAME).london.cloudapps.digital in bat-qa space

.PHONY: local
local: ## Configure local dev environment
	$(eval DEPLOY_ENV=local)
	$(eval AZ_SUBSCRIPTION=s121-findpostgraduateteachertraining-development)

.PHONY: qa
qa: ## Set DEPLOY_ENV to qa
	$(eval DEPLOY_ENV=qa)
	$(eval AZ_SUBSCRIPTION=s121-findpostgraduateteachertraining-development)
	$(eval space=bat-qa)
	$(eval paas_env=qa)

.PHONY: staging
staging: ## Set DEPLOY_ENV to staging
	$(eval DEPLOY_ENV=staging)
	$(eval AZ_SUBSCRIPTION=s121-findpostgraduateteachertraining-test)
	$(eval space=bat-staging)
	$(eval paas_env=staging)

.PHONY: sandbox
sandbox: ## Set DEPLOY_ENV to sandbox
	$(eval DEPLOY_ENV=sandbox)
	$(eval AZ_SUBSCRIPTION=s121-findpostgraduateteachertraining-production)
	$(eval space=bat-prod)
	$(eval paas_env=sandbox)

.PHONY: production
production: ## Set DEPLOY_ENV to production
	$(eval DEPLOY_ENV=production)
	$(eval AZ_SUBSCRIPTION=s121-findpostgraduateteachertraining-production)
	$(if $(CONFIRM_PRODUCTION), , $(error Production can only run with CONFIRM_PRODUCTION))
	$(eval space=bat-prod)
	$(eval paas_env=prod)
	$(eval HOSTNAME=www)

.PHONY: ci
ci:	## Run in automation
	$(eval export DISABLE_PASSCODE=true)
	$(eval export AUTO_APPROVE=-auto-approve)

install-fetch-config:
	[ ! -f bin/fetch_config.rb ] \
		&& curl -s https://raw.githubusercontent.com/DFE-Digital/bat-platform-building-blocks/master/scripts/fetch_config/fetch_config.rb -o bin/fetch_config.rb \
		&& chmod +x bin/fetch_config.rb \
		|| true

set-azure-account:
	az account set -s ${AZ_SUBSCRIPTION}

edit-app-secrets: install-fetch-config set-azure-account
	. terraform/workspace_variables/$(DEPLOY_ENV).sh && bin/fetch_config.rb -s azure-key-vault-secret:$${TF_VAR_key_vault_name}/$${TF_VAR_key_vault_app_secret_name} \
		-e -d azure-key-vault-secret:$${TF_VAR_key_vault_name}/$${TF_VAR_key_vault_app_secret_name} -f yaml -c

edit-infra-secrets: install-fetch-config set-azure-account
	. terraform/workspace_variables/$(DEPLOY_ENV).sh && bin/fetch_config.rb -s azure-key-vault-secret:$${TF_VAR_key_vault_name}/$${TF_VAR_key_vault_infra_secret_name} \
		-e -d azure-key-vault-secret:$${TF_VAR_key_vault_name}/$${TF_VAR_key_vault_infra_secret_name} -f yaml -c

print-app-secrets: install-fetch-config set-azure-account
	. terraform/workspace_variables/$(DEPLOY_ENV).sh && bin/fetch_config.rb -s azure-key-vault-secret:$${TF_VAR_key_vault_name}/$${TF_VAR_key_vault_app_secret_name} \
		-f yaml

deploy-init:
	$(if $(IMAGE_TAG), , $(eval export IMAGE_TAG=master))
	$(if $(or $(DISABLE_PASSCODE),$(PASSCODE)), , $(error Missing environment variable "PASSCODE", retrieve from https://login.london.cloud.service.gov.uk/passcode))
	$(eval export TF_VAR_paas_sso_passcode=$(PASSCODE))
	$(eval export TF_VAR_paas_docker_image=dfedigital/publish-teacher-training:$(IMAGE_TAG))
	$(eval export TF_VAR_paas_app_config_file=./workspace_variables/app_config.yml)
	$(eval export TF_VAR_paas_app_secrets_file=./workspace_variables/app_secrets.yml)
	az account set -s ${AZ_SUBSCRIPTION} && az account show
	cd terraform && terraform init -reconfigure -backend-config=workspace_variables/$(DEPLOY_ENV)_backend.tfvars $(backend_key)
	echo "🚀 DEPLOY_ENV is $(DEPLOY_ENV)"

deploy-plan: deploy-init
	cd terraform && . workspace_variables/$(DEPLOY_ENV).sh \
		&& terraform plan -var-file=workspace_variables/$(DEPLOY_ENV).tfvars

deploy: deploy-init
	cd terraform && . workspace_variables/$(DEPLOY_ENV).sh \
		&& terraform apply -var-file=workspace_variables/$(DEPLOY_ENV).tfvars $(AUTO_APPROVE)

destroy: deploy-init
	cd terraform && . workspace_variables/$(DEPLOY_ENV).sh \
		&& terraform destroy -var-file=workspace_variables/$(DEPLOY_ENV).tfvars $(AUTO_APPROVE)

console:
	cf target -s ${space}
	cf ssh publish-teacher-training-${paas_env} -t -c "cd /app && /usr/local/bin/bundle exec rails c"

enable-maintenance: ## make qa enable-maintenance / make prod enable-maintenance CONFIRM_PRODUCTION=y
	$(if $(HOSTNAME), $(eval REAL_HOSTNAME=${HOSTNAME}), $(eval REAL_HOSTNAME=${DEPLOY_ENV}))
	cf target -s ${space}
	cd service_unavailable_page && cf push
	cf map-route publish-unavailable publish-teacher-training-courses.service.gov.uk --hostname ${REAL_HOSTNAME}
	echo Waiting 5s for route to be registered... && sleep 5
	cf unmap-route publish-teacher-training-${DEPLOY_ENV} publish-teacher-training-courses.service.gov.uk --hostname ${REAL_HOSTNAME}

disable-maintenance: ## make qa disable-maintenance / make prod disable-maintenance CONFIRM_PRODUCTION=y
	$(if $(HOSTNAME), $(eval REAL_HOSTNAME=${HOSTNAME}), $(eval REAL_HOSTNAME=${DEPLOY_ENV}))
	cf target -s ${space}
	cf map-route publish-teacher-training-qa publish-teacher-training-courses.service.gov.uk --hostname ${REAL_HOSTNAME}
	echo Waiting 5s for route to be registered... && sleep 5
	cf unmap-route publish-unavailable publish-teacher-training-courses.service.gov.uk --hostname ${REAL_HOSTNAME}
	cf delete -rf publish-unavailable
