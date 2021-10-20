module PageObjects
  module Page
    class NewLocationsPage < PageObjects::Base
      set_url "/organisations/{provider_code}/{recruitment_cycle_year}/locations/new{?query*}"

      element :title, '[data-qa="page-heading"]'
      elements :site_names, '[data-qa="site__name"]'
    end
  end
end
