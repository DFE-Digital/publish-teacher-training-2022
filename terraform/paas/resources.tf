resource cloudfoundry_app publish-training {
  name         = var.app.name
  space        = data.cloudfoundry_space.space.id
  docker_image = var.app.docker_image
  strategy     = "blue-green-v2"

  environment = {
    ASSETS_PRECOMPILE                                = var.app_env.ASSETS_PRECOMPILE
    RAILS_ENV                                        = var.app_env.RAILS_ENV
    RAILS_SERVE_STATIC_FILES                         = var.app_env.RAILS_SERVE_STATIC_FILES
    SECRET_KEY_BASE                                  = var.SECRET_KEY_BASE
    SENTRY_DSN                                       = var.SENTRY_DSN
    SETTINGS__GOOGLE__MAPS_API_KEY                   = var.SETTINGS__GOOGLE__MAPS_API_KEY
    WEBPACKER_DEV_SERVER_HOST                        = var.app_env.WEBPACKER_DEV_SERVER_HOST
    WEBSITE_SLOT_POLL_WORKER_FOR_CHANGE_NOTIFICATION = var.app_env.WEBSITE_SLOT_POLL_WORKER_FOR_CHANGE_NOTIFICATION
    SETTINGS__DFE_SIGNIN__SECRET                     = var.SETTINGS__DFE_SIGNIN__SECRET
    SETTINGS__LOGSTASH__HOST                         = var.SETTINGS__LOGSTASH__HOST
    SETTINGS__LOGSTASH__PORT                         = var.app_env.SETTINGS__LOGSTASH__PORT
  }

  routes {
    route = cloudfoundry_route.publish-training-route.id
  }
}

resource cloudfoundry_route publish-training-route {
  domain   = data.cloudfoundry_domain.local.id
  space    = data.cloudfoundry_space.space.id
  hostname = var.app.hostname
}
