variable cf_space {}

variable web_app_instances {}

variable web_app_memory {}

variable web_app_host_name {}

variable worker_app_instances { default = 1 }

variable worker_app_memory {}

variable redis_service_plan {}

variable docker_image {}

variable dockerhub_credentials {}

variable logstash_url {}

variable app_environment {}

variable app_environment_variables { type = map }

locals {
  app_name_suffix      = var.app_environment != "review" ? var.app_environment : "pr-${var.web_app_host_name}"
  web_app_name         = "publish-teacher-training-${local.app_name_suffix}"
  worker_app_name      = "publish-teacher-training-worker-${local.app_name_suffix}"
  redis_service_name   = "publish-teacher-training-redis-${local.app_name_suffix}"
  web_app_routes       = [cloudfoundry_route.publish_service_gov_uk_route, cloudfoundry_route.web_app_cloudapps_digital_route]
  logging_service_name = "publish-teacher-training-logit-${local.app_name_suffix}"
}
