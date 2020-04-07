module PageObjects
  module Page
    module Organisations
      class Course < CourseBase
        set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}"

        element :about, "[data-qa=enrichment__about_course]"
        element :interview_process, "[data-qa=enrichment__interview_process]"
        element :placements_info, "[data-qa=enrichment__how_school_placements_work]"
        element :length, "[data-qa=enrichment__course_length]"
        element :salary, "[data-qa=enrichment__salary_details]"
        element :uk_fees, "[data-qa=enrichment__fee_uk_eu]"
        element :international_fees, "[data-qa=enrichment__international_fees]"
        element :fee_details, "[data-qa=enrichment__fee_details]"
        element :financial_support, "[data-qa=enrichment__financial_support]"
        element :required_qualifications, "[data-qa=enrichment__qualifications]"
        element :personal_qualities, "[data-qa=enrichment__personal_qualities]"
        element :other_requirements, "[data-qa=enrichment__other_requirements]"
        element :has_vacancies, "[data-qa=course__has_vacancies]"
        element :is_findable, "[data-qa=course__is_findable]"
        element :open_for_applications, "[data-qa=course__open_for_applications]"
        element :last_published_at, "[data-qa=course__last_published_date]"
        element :status_tag, "[data-qa=course__content-status]"
        element :preview_link, "[data-qa=course__preview-link]"
        element :publish, "[data-qa=course__publish]"
        element :success_summary, ".govuk-success-summary"
        element :error_summary, ".govuk-error-summary"
        element :delete_error, "#delete-error"
        element :withdraw_error, "#withdraw-error"
        element :status_panel, "[data-qa=course__status_panel]"
        element :withdraw_link, '[data-qa="course__withdraw-link"]'
        element :delete_link, '[data-qa="course__delete-link"]'
      end
    end
  end
end
