module PageObjects
  module Page
    class NotificationsInfo < PageObjects::Base
      set_url "/notifications-info"

      element :title, "h1"
      element :continue, "[data-qa=transition__continue]"
    end
  end
end
