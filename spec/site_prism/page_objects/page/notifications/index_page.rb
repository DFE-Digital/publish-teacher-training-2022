module PageObjects
  module Page
    module Notifications
      class IndexPage < PageObjects::Base
        set_url "/notifications"

        element :cancel_changes_link, '[data-qa="notifications__cancel"]'
        element :opt_in_radio, "#user-notification-preferences-explicitly-enabled-true-field"
        element :opt_out_radio, "#user-notification-preferences-explicitly-enabled-field"
        element :save_button, '[data-qa="notifications__save"]'
      end
    end
  end
end
