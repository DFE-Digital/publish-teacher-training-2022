module PageObjects
  module Page
    module Organisations
      class CourseLocations < PageObjects::Base
        set_url '/organisations/{provider_code}/courses/{course_code}/locations'

        element :title, '.govuk-heading-xl'
        element :caption, '.govuk-caption-xl'
        element :success_summary, '.govuk-success-summary'
        element :error_summary, '.govuk-error-summary'
        element :save, '[data-qa=course__save]'
      end
    end
  end
end
