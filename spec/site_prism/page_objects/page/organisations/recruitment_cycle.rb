module PageObjects
  module Page
    module Organisations
      class RecruitmentCycle < PageObjects::Base
        set_url '/organisations/{provider_code}/{recruitment_cycle_year}'

        element :title, '.govuk-heading-xl'
        element :caption, '.govuk-caption-xl'

        element :locations_link, 'a[data-qa=provider__locations]', text: 'Locations'
        element :courses_link, 'a[data-qa=provider__courses]', text: 'Courses'
      end
    end
  end
end
