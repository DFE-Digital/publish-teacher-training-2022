module PageObjects
  module Page
    module Organisations
      class OrganisationAbout < PageObjects::Base
        set_url "/organisations/{provider_code}/about"

        element :title, ".govuk-heading-l"
        element :caption, ".govuk-caption-l"
        element :train_with_us, "#provider-train-with-us-field"
        element :train_with_disability, "#provider-train-with-disability-field"
        element :error_flash, ".govuk-error-summary"
      end
    end
  end
end
