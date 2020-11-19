data cloudfoundry_domain london_cloud_apps_digital {
  name = "london.cloudapps.digital"
}

data cloudfoundry_domain publish_service_gov_uk {
  name = "publish-teacher-training-courses.service.gov.uk"
}

data cloudfoundry_org org {
  name = "dfe-teacher-services"
}

data cloudfoundry_space space {
  name = var.cf_space
  org  = data.cloudfoundry_org.org.id
}
