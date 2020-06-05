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
    SETTINGS__GOOGLE__GCP_API_KEY                    = var.SETTINGS__GOOGLE__GCP_API_KEY
    SETTINGS__GOOGLE__MAPS_API_KEY                   = var.SETTINGS__GOOGLE__MAPS_API_KEY
    SETTINGS__REDIRECT_RESULTS_TO_C_SHARP            = var.app_env.SETTINGS__REDIRECT_RESULTS_TO_C_SHARP
    WEBPACKER_DEV_SERVER_HOST                        = var.app_env.WEBPACKER_DEV_SERVER_HOST
    WEBSITE_SLOT_POLL_WORKER_FOR_CHANGE_NOTIFICATION = var.app_env.WEBSITE_SLOT_POLL_WORKER_FOR_CHANGE_NOTIFICATION
    SETTINGS_DFE_SIGNIN_SECRET                       = var.SETTINGS_DFE_SIGNIN_SECRET
    SETTINGS_LOGSTASH_HOST                           = var.SETTINGS_LOGSTASH_HOST
    SETTINGS_LOGSTASH_PORT                           = var.app_env.SETTINGS_LOGSTASH_PORT
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
