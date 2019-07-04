module PageObjects
  module Page
    module Organisations
      class CourseVacancies < CourseBase
        set_url '/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/vacancies'

        element :title, 'h1.govuk-fieldset__heading'

        element :vacancies_radio_choice, '.govuk-radios'
        element :vacancies_radio_no_vacancies, '#course_has_vacancies_false.govuk-radios__input'
        element :vacancies_radio_has_some_vacancies, '#course_has_vacancies_true.govuk-radios__input'
        element :vacancies_running_sites_checkboxes, '.govuk-radios__conditional .govuk-checkboxes'

        element :confirm_no_vacancies_checkbox, '#change_vacancies_confirmation[value="no_vacancies_confirmation"]'
        element :confirm_has_vacancies_checkbox, '#change_vacancies_confirmation[value="has_vacancies_confirmation"]'
      end
    end
  end
end
