module PageObjects
  module Partials
    class Footer < SitePrism::Page
      element :access_requests_link, "[data-qa=access_requests_link]"
      element :organisations_link, "[data-qa=organisations_link]"
    end
  end
end
