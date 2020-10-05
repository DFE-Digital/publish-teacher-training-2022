module PageObjects
  module Page
    class Rollover < PageObjects::Base
      set_url "/rollover"

      element :title, ".govuk-heading-xl"
      element :continue_link, ".govuk-button", text: "Continue"
      element :continue_input_button, ".govuk-button[value=Continue]"
    end
  end
end
