module PageObjects
  module Page
    module Notifications
      class IndexPage < PageObjects::Base
        set_url "/notifications"

        element :opt_in_radio, "#user-notification-preferences-explicitly-enabled-true-field"
        element :opt_out_radio, "#user-notification-preferences-explicitly-enabled-field"
        element :save_button, "input[value=Save]"
      end
    end
  end
end
