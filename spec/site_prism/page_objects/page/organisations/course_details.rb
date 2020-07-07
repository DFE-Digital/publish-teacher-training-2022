module PageObjects
  module Page
    module Organisations
      class CourseDetails < CourseBase
        set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/details"

        element :qualifications, "[data-qa=course__qualifications]"
        element :study_mode, "[data-qa=course__study_mode]"
        element :edit_study_mode_link, "[data-qa=course__edit_study_mode_link]"
        element :start_date, "[data-qa=course__start_date]"
        element :edit_start_date_link, "[data-qa=course__edit_start_date_link]"
        element :name, "[data-qa=course__name]"
        element :description, "[data-qa=course__description]"
        element :course_code, "[data-qa=course__course_code]"
        element :locations, "[data-qa=course__locations]"
        element :edit_locations_link, "[data-qa=course__edit_locations_link]"
        element :manage_provider_locations_link, "[data-qa=course__manage_provider_locations_link]"
        element :apprenticeship, "[data-qa=course__apprenticeship]"
        element :edit_apprenticeship_link, "[data-qa=course__edit_apprenticeship_link]"
        element :funding, "[data-qa=course__funding]"
        element :edit_funding_link, "[data-qa=course__edit_funding_link]"
        element :accredited_body, "[data-qa=course__accredited_body]"
        element :application_status, "[data-qa=course__application_status]"
        element :edit_open_applications_link, "[data-qa=course__edit_open_applications_link]"
        element :edit_application_status_link, "[data-qa=course__edit_application_status_link]"
        element :is_send, "[data-qa=course__is_send]"
        element :edit_is_send_link, "[data-qa=course__edit_is_send]"
        element :subjects, "[data-qa=course__subjects]"
        element :edit_subjects_link, "[data-qa=course__edit_subjects_link]"
        element :age_range, "[data-qa=course__age_range]"
        element :edit_age_range_link, "[data-qa=course__edit_age_range_link]"
        element :level, "[data-qa=course__level]"
        element :entry_requirements, "[data-qa=course__entry_requirements]"
        element :allocations_info, "[data-qa=course__allocations_info]"
        element :contact_support, "[data-qa=course__contact_support]"

        def title_detail
          node = page.find_all("div.govuk-summary-list__row").find { |n| n.text.include?("Title") }
          Detail.new(page, node)
        end

        class Detail < SitePrism::Section
          element :value, "dd.govuk-summary-list__value"
          element :actions, "dd.govuk-summary-list__actions"
        end
      end
    end
  end
end
