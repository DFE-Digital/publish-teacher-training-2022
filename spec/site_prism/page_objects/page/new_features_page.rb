module PageObjects
  module Page
    class NewFeaturesPage < PageObjects::Base
      set_url "/new-features"

      element :title, "h1"
    end
  end
end
