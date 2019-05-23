module PageObjects
  module Page
    module Organisations
      class CoursePreview < PageObjects::Base
        set_url '/organisations/{provider_code}/courses/{course_code}/preview'

        element :title, '.govuk-heading-xl'
        element :sub_title, '[data-qa=course__provider_name]'
        element :description, '[data-qa=course__description]'
      end
    end
  end
end
