module PageObjects
  module Page
    module Organisations
      class CoursePreview < PageObjects::Base
        set_url '/organisations/{provider_code}/courses/{course_code}/preview'

        element :title, '.govuk-heading-xl'
        element :sub_title, '[data-qa=course__provider_name]'
        element :description, '[data-qa=course__description]'
        element :qualifications, '[data-qa=course__qualifications]'
        element :length, '[data-qa=course__length]'
        element :applications_open_from, '[data-qa=course__applications_open]'
        element :start_date, '[data-qa=course__start_date]'
        element :provider_website, '[data-qa=course__provider_website]'
        element :vacancies, '[data-qa=course__vacancies]'
        element :about_course, '#section-about'
        element :interview_process, '#section-interviews'
        element :school_placements, '#section-schools'
        element :uk_fees, '[data-qa=course__uk_fees]'
        element :eu_fees, '[data-qa=course__eu_fees]'
        element :international_fees, '[data-qa=course__international_fees]'
        element :salary_details, '#section-salary'
      end
    end
  end
end
