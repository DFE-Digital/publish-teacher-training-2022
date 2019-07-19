module PageObjects
  module Page
    module Organisations
      class OrganisationDetails < PageObjects::Base
        set_url '/organisations/{provider_code}/details'

        element :title, '.govuk-heading-xl'
        element :caption, '.govuk-caption-xl'
        element :email, '[data-qa=enrichment__email]'
        element :telephone, '[data-qa=enrichment__telephone]'
        element :website, '[data-qa=enrichment__website]'
        element :address, '[data-qa=enrichment__address]'
        element :train_with_us, '[data-qa=enrichment__train_with_us]'
        element :train_with_disability, '[data-qa=enrichment__train_with_disability]'
        element :content_status, '[data-qa=provider__content-status]'
      end
    end
  end
end
