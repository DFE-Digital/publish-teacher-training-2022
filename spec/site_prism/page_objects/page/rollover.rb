module PageObjects
  module Page
    class Rollover < PageObjects::Base
      set_url "/rollover"

      element :title, "h1"
      element :continue, "[data-qa=rollover__continue]"
    end
  end
end
