app = {
  name         = "qa-publish-teacher-training-courses"
  docker_image = "dfedigital/publish-teacher-training:latest"
  hostname     = "qa-publish-teacher-training-courses"
  space        = "find-qa"
}

app_env = {
  ASSETS_PRECOMPILE                                = true
  RAILS_ENV                                        = "qa"
  RAILS_SERVE_STATIC_FILES                         = true
  WEBPACKER_DEV_SERVER_HOST                        = "webpacker"
  WEBSITE_SLOT_POLL_WORKER_FOR_CHANGE_NOTIFICATION = "0"
  SETTINGS__LOGSTASH__PORT                         = 22135
  SETTINGS__DFE_SIGNIN__BASE_URL                   = "https://qa-publish-teacher-training-courses.london.cloudapps.digital"
}
