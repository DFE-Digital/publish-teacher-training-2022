module PageObjects
  module Page
    class RootPage < OrganisationsPage
      set_url "/"

      element :provider_search, '[data-qa="provider-search"]'
      element :find_providers, '[data-qa="find-providers"]'
      element :provider_error, '[data-qa="provider-error"]'
    end
  end
end
