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
  SETTINGS_LOGSTASH_PORT                           = 22135
}
