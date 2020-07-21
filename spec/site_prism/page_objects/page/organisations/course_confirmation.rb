module PageObjects
  module Page
    module Organisations
      class CourseConfirmation < CourseBase
        set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/confirmation{?query*}"

        element :save_button, '[data-qa="course__save"]'

        section :details, '[data-qa="course__details"]' do
          element :edit_level, '[data-qa="course__edit_level_link"]'
          element :level, '[data-qa="course__level"]'
          element :edit_age_range, '[data-qa="course__edit_age_range_link"]'
          element :age_range, '[data-qa="course__age_range"]'
          element :edit_apprenticeship, '[data-qa="course__edit_apprenticeship_link"]'
          element :apprenticeship, '[data-qa="course__apprenticeship"]'
          element :fee_or_salary, '[data-qa="course__fee_or_salary"]'
          element :edit_is_send, '[data-qa="course__edit_is_send_link"]'
          element :is_send, '[data-qa="course__is_send"]'
          element :subjects, '[data-qa="course__subjects"]'
          element :edit_subjects, '[data-qa="course__edit_subjects_link"]'
          element :edit_study_mode, '[data-qa="course__edit_study_mode_link"]'
          element :study_mode, '[data-qa="course__study_mode"]'
          element :edit_locations, '[data-qa="course__edit_locations_link"]'
          element :locations, '[data-qa="course__locations"]'
          element :accredited_body, '[data-qa="course__accredited_body"]'
          element :edit_application_open_from, '[data-qa="course__edit_application_open_from_link"]'
          element :application_open_from, '[data-qa="course__application_open_from"]'
          element :edit_start_date, '[data-qa="course__edit_start_date_link"]'
          element :start_date, '[data-qa="course__start_date"]'
          element :name, '[data-qa="course__name"]'
          element :description, '[data-qa="course__description"]'
          element :edit_entry_requirements, '[data-qa="course__edit_entry_requirements_link"]'
          element :entry_requirements, '[data-qa="course__entry_requirements"]'
          element :edit_qualifications, '[data-qa="course__edit_qualifications_link"]'
          element :qualifications, '[data-qa="course__qualifications"]'
          element :single_location_help_text, '[data-qa="course__locations__help"]'
        end

        section :preview, '[data-qa="course__preview"]' do
          element :name, '[data-qa="course__name"]'
          element :description, '[data-qa="course__description"]'
        end
      end
    end
  end
end
