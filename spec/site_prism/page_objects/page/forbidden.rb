module PageObjects
  module Page
    class Forbidden < PageObjects::Base
      element :forbidden_text, "[data-qa=errors__forbidden]"
    end
  end
end
