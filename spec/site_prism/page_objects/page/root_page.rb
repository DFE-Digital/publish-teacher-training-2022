module PageObjects
  module Page
    class RootPage < OrganisationsPage
      set_url "/"

      element :provider_search, '[data-qa="provider-search"]'
      element :find_providers, '[data-qa="find-providers"]'
      element :error_summary, ".govuk-error-summary"
      element :provider_error, '[data-qa="provider-error"]'
      element :notifications_preference_link, "[data-qa='notifications-link']"
    end
  end
end
