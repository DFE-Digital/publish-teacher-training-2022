module PageObjects
  module Page
    class NotificationsInfo < PageObjects::Base
      set_url "/notifications-info"

      element :title, "h1"
      element :continue, ".govuk-button[value=Continue]"
    end
  end
end
