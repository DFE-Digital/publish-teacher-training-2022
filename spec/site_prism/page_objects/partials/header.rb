module PageObjects
  module Partials
    class Header < SitePrism::Page
      element :notifications_preference_link, "a.govuk-header__link", text: "Notifications"
      element :active_notifications_preference_link, "li.govuk-header__navigation-item--active a.govuk-header__link", text: "Notifications"
    end
  end
end
