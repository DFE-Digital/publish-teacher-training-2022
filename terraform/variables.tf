#PaaS
variable cf_user { default = null }

variable cf_user_password { default = null }

variable cf_sso_passcode { default = null }

variable cf_space {}

variable paas_app_environment {}

variable paas_web_app_instances {}

variable paas_web_app_memory {}

variable paas_web_app_host_name {}

variable paas_docker_image {}

variable dockerhub_username {}

variable dockerhub_password {}

variable paas_app_config { type = map }

variable paas_app_secrets_file { default = "workspace_variables/app_secrets.yml" }

#StatusCake
variable statuscake_alerts { type = map }

variable statuscake_username {}

variable statuscake_password {}

locals {
  cf_api_url = "https://api.london.cloud.service.gov.uk"
  dockerhub_credentials = {
    username = var.dockerhub_username
    password = var.dockerhub_password
  }
  paas_app_secrets               = yamldecode(file(var.paas_app_secrets_file))
  paas_app_environment_variables = merge(local.paas_app_secrets, var.paas_app_config)
}
