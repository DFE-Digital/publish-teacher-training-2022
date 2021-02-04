resource cloudfoundry_app web_app {
  name                       = local.web_app_name
  space                      = data.cloudfoundry_space.space.id
  health_check_type          = "http"
  health_check_http_endpoint = "/ping"
  docker_image               = var.docker_image
  docker_credentials         = var.dockerhub_credentials
  timeout                    = 180
  strategy                   = "blue-green-v2"
  environment                = var.app_environment_variables

  dynamic "routes" {
    for_each = local.web_app_routes
    content {
      route = routes.value.id
    }
  }

  service_binding {
    service_instance = cloudfoundry_user_provided_service.logging.id
  }
}

resource cloudfoundry_route web_app_cloudapps_digital_route {
  domain   = data.cloudfoundry_domain.london_cloud_apps_digital.id
  space    = data.cloudfoundry_space.space.id
  hostname = local.web_app_name
}

resource cloudfoundry_route publish_service_gov_uk_route {
  domain   = data.cloudfoundry_domain.publish_service_gov_uk.id
  space    = data.cloudfoundry_space.space.id
  hostname = var.web_app_host_name
}

resource cloudfoundry_user_provided_service logging {
  name             = local.logging_service_name
  space            = data.cloudfoundry_space.space.id
  syslog_drain_url = var.logstash_url
}
