module PageObjects
  module Page
    module Organisations
      class TrainingProviders < PageObjects::Base
        set_url "/organisations/{provider_code}/training-providers"

        class TrainingProviderSection < SitePrism::Section
          element :link, '[data-qa="link"]'
          element :course_count, '[data-qa="course_count"]'
        end

        element :training_providers_list, '[data-qa="provider__training_providers_list"]'
        sections :training_providers, TrainingProviderSection, '[data-qa="training_provider"]'
        element :download_section, '[data-qa="download-section"]'
      end
    end
  end
end
