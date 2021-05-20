#PaaS
cf_space                    = "bat-staging"
paas_app_environment        = "rollover"
paas_app_environment_config = "rollover"
paas_web_app_host_name      = "rollover"
paas_web_app_instances      = 1
paas_web_app_memory         = 512

#StatusCake
statuscake_alerts = {
  sandbox-pubtt = {
    website_name   = "publish-teacher-training-rollover"
    website_url    = "https://publish-teacher-training-rollover.london.cloudapps.digital/ping"
    test_type      = "HTTP"
    check_rate     = 60
    contact_group  = [151103]
    trigger_rate   = 0
    node_locations = ["UKINT", "UK1", "MAN1", "MAN5", "DUB2"]
  }
}

key_vault_resource_group    = "s121t01-shared-rg"
