module PageObjects
  module Page
    module Organisations
      class NoProviders < PageObjects::Base
        element :no_providers_text, "[data-qa=errors__no_providers]"
      end
    end
  end
end
