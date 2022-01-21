#PaaS
cf_space                    = "bat-qa"
paas_app_environment        = "qa"
paas_app_environment_config = "qa"
paas_web_app_host_name      = "qa"
paas_web_app_instances      = 1
paas_web_app_memory         = 512
paas_worker_app_instances   = 1
paas_worker_app_memory      = 512
paas_redis_service_plan     = "micro-5_x"

#StatusCake
statuscake_alerts = {
  qa-pubtt = {
    website_name   = "publish-teacher-training-qa"
    website_url    = "https://qa.publish-teacher-training-courses.service.gov.uk/ping"
    test_type      = "HTTP"
    check_rate     = 60
    contact_group  = [151103]
    trigger_rate   = 0
    node_locations = ["UKINT", "UK1", "MAN1", "MAN5", "DUB2"]
  }
}

#vault
key_vault_resource_group = "s121d01-shared-rg"
