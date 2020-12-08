module PageObjects
  module Page
    class SignIn < PageObjects::Base
      set_url "/sign-in"

      element :page_heading, ".govuk-heading-l"

      element :sign_in_button, ".govuk-button"
    end
  end
end
