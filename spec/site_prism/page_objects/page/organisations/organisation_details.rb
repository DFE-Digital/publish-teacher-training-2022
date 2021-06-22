module PageObjects
  module Page
    module Organisations
      class OrganisationDetails < PageObjects::Base
        set_url "/organisations/{provider_code}/{recruitment_cycle_year}/details"

        element :title, ".govuk-heading-l"
        element :caption, ".govuk-caption-l"
        element :email, "[data-qa=enrichment__email]"
        element :telephone, "[data-qa=enrichment__telephone]"
        element :website, "[data-qa=enrichment__website]"
        element :address, "[data-qa=enrichment__address]"
        element :train_with_us, "[data-qa=enrichment__train_with_us]"
        element :train_with_disability, "[data-qa=enrichment__train_with_disability]"
        element :status_panel, "[data-qa=provider__status_panel]"
        element :flash, ".govuk-notification-banner--success"
        elements :breadcrumbs, ".govuk-breadcrumbs__link"
      end
    end
  end
end
