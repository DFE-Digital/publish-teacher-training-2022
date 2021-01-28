#PaaS
cf_space                    = "bat-staging"
paas_app_environment        = "staging"
paas_app_environment_config = "staging"
paas_web_app_host_name      = "staging"
paas_web_app_instances      = 1
paas_web_app_memory         = 512

#StatusCake
statuscake_alerts = {
  staging-pubtt = {
    website_name   = "publish-teacher-training-staging"
    website_url    = "https://www.staging.publish-teacher-training-courses.service.gov.uk/ping"
    test_type      = "HTTP"
    check_rate     = 60
    contact_group  = [188603]
    trigger_rate   = 0
    node_locations = ["UKINT", "UK1", "MAN1", "MAN5", "DUB2"]
  }
}
