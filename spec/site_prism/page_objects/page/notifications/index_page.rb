module PageObjects
  module Page
    module Notifications
      class IndexPage < PageObjects::Base
        set_url "/notifications"

        element :opt_in_radio, "#consent-yes-field"
        element :opt_out_radio, "#consent-no-field"
        element :save_button, "input[value=Save]"
      end
    end
  end
end
