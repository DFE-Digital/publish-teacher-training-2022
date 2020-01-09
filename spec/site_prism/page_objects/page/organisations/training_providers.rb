module PageObjects
  module Page
    module Organisations
      class TrainingProviders < PageObjects::Base
        set_url "/organisations/{provider_code}/training-providers"

        element :training_providers_list, '[data-qa="provider__training_providers_list"]'
      end
    end
  end
end
