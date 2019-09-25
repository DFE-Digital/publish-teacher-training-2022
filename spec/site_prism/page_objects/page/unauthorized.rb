module PageObjects
  module Page
    class Unauthorized < PageObjects::Base
      element :unauthorized_text, "[data-qa=errors__unauthorized]"
    end
  end
end
