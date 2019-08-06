module PageObjects
  module Page
    module Organisations
      class CourseDetails < CourseBase
        set_url '/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/details'

        element :qualifications, '[data-qa=course__qualifications]'
        element :study_mode, '[data-qa=course__study_mode]'
        element :start_date, '[data-qa=course__start_date]'
        element :name, '[data-qa=course__name]'
        element :description, '[data-qa=course__description]'
        element :course_code, '[data-qa=course__course_code]'
        element :locations, '[data-qa=course__locations]'
        element :edit_locations_link, '[data-qa=course__edit_locations_link]'
        element :manage_provider_locations_link, '[data-qa=course__manage_provider_locations_link]'
        element :apprenticeship, '[data-qa=course__apprenticeship]'
        element :funding, '[data-qa=course__funding]'
        element :accredited_body, '[data-qa=course__accredited_body]'
        element :application_status, '[data-qa=course__application_status]'
        element :is_send, '[data-qa=course__is_send]'
        element :subjects, '[data-qa=course__subjects]'
        element :age_range, '[data-qa=course__age_range]'
        element :edit_age_range_link, '[data-qa=course__edit_age_range_link]'
        element :level, '[data-qa=course__level]'
        element :entry_requirements, '[data-qa=course__entry_requirements]'
      end
    end
  end
end
