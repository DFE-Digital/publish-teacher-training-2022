resource cloudfoundry_app web_app {
  name               = local.web_app_name
  space              = data.cloudfoundry_space.space.id
  docker_image       = var.docker_image
  docker_credentials = var.dockerhub_credentials
  strategy           = "blue-green-v2"
  environment        = var.app_environment_variables

  dynamic "routes" {
    for_each = local.web_app_routes
    content {
      route = routes.value.id
    }
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
