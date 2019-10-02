module PageObjects
  module Page
    module Organisations
      class CourseConfirmation < CourseBase
        set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/confirmation{?query*}"

        element :continue, '[data-qa="course__save"]'

        section :details, '[data-qa="course__details"]' do
          element :level, '[data-qa="course__level"]'
          element :is_send, '[data-qa="course__is_send"]'
          element :subjects, '[data-qa="course__subjects"]'
          element :age_range, '[data-qa="course__age_range"]'
          element :study_mode, '[data-qa="course__study_mode"]'
          element :locations, '[data-qa="course__locations"]'
          element :study_mode, '[data-qa="course__study_mode"]'
          element :application_open_from, '[data-qa="course__application_open_from"]'
          element :start_date, '[data-qa="course__start_date"]'
          element :name, '[data-qa="course__name"]'
          element :description, '[data-qa="course__description"]'
          element :entry_requirements, '[data-qa="course__entry_requirements"]'
        end
      end
    end
  end
end
