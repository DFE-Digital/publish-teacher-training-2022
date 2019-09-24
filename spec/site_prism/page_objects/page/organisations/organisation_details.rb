module PageObjects
  module Page
    module Organisations
      class OrganisationDetails < PageObjects::Base
        set_url "/organisations/{provider_code}/{recruitment_cycle_year}/details"

        element :title, ".govuk-heading-xl"
        element :caption, ".govuk-caption-xl"
        element :email, "[data-qa=enrichment__email]"
        element :telephone, "[data-qa=enrichment__telephone]"
        element :website, "[data-qa=enrichment__website]"
        element :address, "[data-qa=enrichment__address]"
        element :train_with_us, "[data-qa=enrichment__train_with_us]"
        element :train_with_disability, "[data-qa=enrichment__train_with_disability]"
        element :status_panel, "[data-qa=provider__status_panel]"
        element :content_status, "[data-qa=provider__content-status]"
        element :flash, ".govuk-success-summary"
        elements :breadcrumbs, ".govuk-breadcrumbs__link"
        element :publish_button, "[data-qa=provider__publish]"
        element :publish_in_next_cycle_button, "[data-qa=provider__publish_next_cycle]"
        element :next_recruitment_cycle_publishing_information, "[data-qa=provider__next_cycle_publish_help_text]"
      end
    end
  end
end
