module PageObjects
  module Page
    module Organisations
      class Course < PageObjects::Base
        set_url '/organisations/{provider_code}/course/{course_code}'

        element :title, '.govuk-heading-xl'
        element :caption, '.govuk-caption-xl'
        element :qualifications, '[data-qa=course__qualifications]'
        element :study_mode, '[data-qa=course__study_mode]'
        element :start_date, '[data-qa=course__start_date]'
        element :name, '[data-qa=course__name]'
        element :description, '[data-qa=course__description]'
        element :course_code, '[data-qa=course__course_code]'
        element :locations, '[data-qa=course__locations]'
        element :apprenticeship, '[data-qa=course__apprenticeship]'
        element :funding, '[data-qa=course__funding]'
        element :accredited_body, '[data-qa=course__accredited_body]'
        element :applications_open, '[data-qa=course__applications_open]'
      end
    end
  end
end
