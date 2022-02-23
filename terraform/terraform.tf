terraform {
  required_version = "~> 0.13.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.45.1"
    }
    cloudfoundry = {
      source  = "cloudfoundry-community/cloudfoundry"
      version = "0.12.6"
    }
    statuscake = {
      source  = "terraform-providers/statuscake"
      version = "1.0.0"
    }
  }
  backend azurerm {
  }
}

provider cloudfoundry {
  api_url           = local.cf_api_url
  user              = var.paas_sso_passcode == "" ? local.infra_secrets.CF_USER : null
  password          = var.paas_sso_passcode == "" ? local.infra_secrets.CF_PASSWORD : null
  sso_passcode      = var.paas_sso_passcode != "" ? var.paas_sso_passcode : null
  store_tokens_path = var.paas_sso_passcode != "" ? "tokens" : null
}

provider statuscake {
  username = local.infra_secrets.STATUSCAKE_USERNAME
  apikey   = local.infra_secrets.STATUSCAKE_PASSWORD
}

provider azurerm {
  features {}

  skip_provider_registration = true
  subscription_id            = try(local.azure_credentials.subscriptionId, null)
  client_id                  = try(local.azure_credentials.clientId, null)
  client_secret              = try(local.azure_credentials.clientSecret, null)
  tenant_id                  = try(local.azure_credentials.tenantId, null)
}


module paas {
  source = "./modules/paas"

  cf_space                  = var.cf_space
  app_environment           = var.paas_app_environment
  docker_image              = var.paas_docker_image
  web_app_host_name         = var.paas_web_app_host_name
  web_app_memory            = var.paas_web_app_memory
  web_app_instances         = var.paas_web_app_instances
  worker_app_instances      = var.paas_worker_app_instances
  worker_app_memory         = var.paas_worker_app_memory
  redis_service_plan        = var.paas_redis_service_plan
  app_environment_variables = local.paas_app_environment_variables
  logstash_url              = local.infra_secrets.LOGSTASH_URL
}

module statuscake {
  source = "./modules/statuscake"

  alerts = var.statuscake_alerts
}
