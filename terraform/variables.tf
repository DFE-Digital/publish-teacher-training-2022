#PaaS
variable cf_user { default = null }

variable cf_user_password { default = null }

variable cf_sso_passcode { default = null }

variable cf_space {}

variable paas_app_environment {}

variable paas_app_environment_config {}

variable paas_web_app_instances {}

variable paas_web_app_memory {}

variable paas_web_app_host_name {}

variable paas_docker_image {}

variable dockerhub_username {}

variable dockerhub_password {}

variable paas_app_config_file { default = "workspace_variables/app_config.yml" }

variable paas_app_secrets_file { default = "workspace_variables/app_secrets.yml" }

#StatusCake
variable statuscake_alerts {
  type    = map
  default = {}
}

variable statuscake_username { default = "not-empty" }

variable statuscake_password { default = "not-empty" }

locals {
  cf_api_url = "https://api.london.cloud.service.gov.uk"
  dockerhub_credentials = {
    username = var.dockerhub_username
    password = var.dockerhub_password
  }
  paas_app_config                = yamldecode(file(var.paas_app_config_file))[var.paas_app_environment_config]
  paas_app_secrets               = yamldecode(file(var.paas_app_secrets_file))
  paas_app_environment_variables = merge(local.paas_app_secrets, local.paas_app_config)
}
