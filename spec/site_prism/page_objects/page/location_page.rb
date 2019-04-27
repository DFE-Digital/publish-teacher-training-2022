module PageObjects
  module Page
    class LocationPage < PageObjects::Base
      set_url '/organisations/{provider_code}/locations/{site_id}/edit'

      element :title, 'h1'
    end
  end
end
