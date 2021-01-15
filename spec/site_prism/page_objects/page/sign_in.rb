module PageObjects
  module Page
    class SignIn < PageObjects::Base
      set_url "/sign-in"

      element :page_heading, "h1"

      element :sign_in_button, ".govuk-button"
    end
  end
end
