module PageObjects
  module Page
    module Organisations
      class CourseRequirements < PageObjects::Base
        set_url '/organisations/{provider_code}/courses/{course_code}/requirements'

        element :title, '.govuk-heading-xl'
        element :caption, '.govuk-caption-xl'
        element :required_qualifications, '#course_required_qualifications'
        element :personal_qualities, '#course_personal_qualities'
        element :other_requirements, '#course_other_requirements'
        element :flash, '.govuk-success-summary'
      end
    end
  end
end
