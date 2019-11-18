module PageObjects
  class Base < SitePrism::Page
    element :access_requests_link, "[data-qa=\"access_requests_link\"]"
  end
end
