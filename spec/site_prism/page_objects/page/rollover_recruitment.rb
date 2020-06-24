module PageObjects
  module Page
    class RolloverRecruitment < PageObjects::Base
      set_url "/rollover-recruitment"

      element :title, ".govuk-heading-xl"
      element :continue, ".govuk-button[value=Continue]"
    end
  end
end
