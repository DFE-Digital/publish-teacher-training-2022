module PageObjects
  module Page
    module Organisations
      class CourseDescription < PageObjects::Base
        set_url '/organisations/{provider_code}/courses/{course_code}/description'

        element :title, '.govuk-heading-xl'
        element :caption, '.govuk-caption-xl'
        element :about, '[data-qa=course__about]'
        element :interview_process, '[data-qa=course__interview_process]'
        element :placements_info, '[data-qa=course__placements_info]'
        element :length, '[data-qa=course__length]'
        element :salary, '[data-qa=course__salary]'
        element :uk_fees, '[data-qa=course__uk_fees]'
        element :international_fees, '[data-qa=course__international_fees]'
        element :fee_details, '[data-qa=course__fee_details]'
        element :financial_support, '[data-qa=course__financial_support]'
        element :required_qualifications, '[data-qa=course__required_qualifications]'
        element :personal_qualities, '[data-qa=course__personal_qualities]'
        element :other_requirements, '[data-qa=course__other_requirements]'
        element :has_vacancies, '[data-qa=course__has_vacancies]'
        element :is_findable, '[data-qa=course__is_findable]'
        element :open_for_applications, '[data-qa=course__open_for_applications]'
      end
    end
  end
end
