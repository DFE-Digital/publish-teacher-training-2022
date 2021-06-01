module PageObjects
  module Page
    module Organisations
      class CourseDetails < CourseBase
        class SummaryList < SitePrism::Section
          element :value, ".govuk-summary-list__value"
          element :change_link, ".govuk-summary-list__actions .govuk-link"
        end

        set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/details"

        element :manage_provider_locations_link, "[data-qa=course__manage_provider_locations_link]"
        element :contact_support_link, "[data-qa=course__contact_support_link]"

        section :level, SummaryList, "[data-qa=course__level]"
        section :is_send, SummaryList, "[data-qa=course__is_send]"
        section :subjects, SummaryList, "[data-qa=course__subjects]"
        section :age_range, SummaryList, "[data-qa=course__age_range]"
        section :qualifications, SummaryList, "[data-qa=course__outcome]"
        section :apprenticeship, SummaryList, "[data-qa=course__apprenticeship]"
        section :funding, SummaryList, "[data-qa=course__funding]"
        section :study_mode, SummaryList, "[data-qa=course__study_mode]"
        section :locations, SummaryList, "[data-qa=course__locations]"
        section :accredited_body, SummaryList, "[data-qa=course__accredited_body]"
        section :applications_open, SummaryList, "[data-qa=course__applications_open]"
        section :start_date, SummaryList, "[data-qa=course__start_date]"
        section :name, SummaryList, "[data-qa=course__name]"
        section :description, SummaryList, "[data-qa=course__description]"
        section :course_code, SummaryList, "[data-qa=course__course_code]"
        section :entry_requirements, SummaryList, "[data-qa=course__entry_requirements]"
        section :allocations, SummaryList, "[data-qa=course__allocations]"
      end
    end
  end
end
