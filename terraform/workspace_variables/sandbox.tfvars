#PaaS
cf_space                    = "bat-prod"
paas_app_environment        = "sandbox"
paas_app_environment_config = "sandbox"
paas_web_app_host_name      = "sandbox"
paas_web_app_instances      = 1
paas_web_app_memory         = 512

#StatusCake
statuscake_alerts = {
  sandbox-pubtt = {
    website_name   = "publish-teacher-training-sandbox"
    website_url    = "https://sandbox.publish-teacher-training-courses.service.gov.uk/ping"
    test_type      = "HTTP"
    check_rate     = 60
    contact_group  = [151103]
    trigger_rate   = 0
    node_locations = ["UKINT", "UK1", "MAN1", "MAN5", "DUB2"]
  }
}
