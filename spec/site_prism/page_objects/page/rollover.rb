module PageObjects
  module Page
    class Rollover < PageObjects::Base
      set_url "/rollover"

      element :title, ".govuk-heading-xl"
      element :continue, ".govuk-button", text: "Continue"
    end
  end
end
