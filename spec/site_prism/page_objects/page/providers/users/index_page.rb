module PageObjects
  module Page
    module Providers
      module Users
        class IndexPage < PageObjects::Base
          set_url "/organisations/{provider_code}/users"

          element :heading, "h1"
          element :user_name, "h2", match: :first
        end
      end
    end
  end
end
