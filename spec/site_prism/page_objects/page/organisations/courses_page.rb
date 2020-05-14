module PageObjects
  module Page
    module Organisations
      class CoursesPage < PageObjects::Base
        def load_with_provider(provider)
          self.load(provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year)
        end

        set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses"

        element :flash, ".govuk-success-summary"
        element :caption, ".govuk-caption-xl"

        element :course_create, '[data-qa="course-create"]'
        element :course_create_additional, '[data-qa="course-create-additional"]'

        sections :courses_tables, '[data-qa="courses__table-section"]' do
          element :subheading, "h2"
          sections :rows, "tbody tr" do
            element :name, '[data-qa="courses-table__course"]'
            element :link, "td.app-course-table__course-name a"
            element :ucas_status, '[data-qa="courses-table__ucas-status"]'
            element :status, '[data-qa="courses-table__status"]'
            element :on_find, '[data-qa="courses-table__findable"]'
            element :find_link, '[data-qa="courses-table__findable"] a'
            element :applications, '[data-qa="courses-table__applications"]'
            element :vacancies, '[data-qa="courses-table__vacancies"]'
          end
        end

        element :link_to_add_a_course_for_unaccredited_bodies_current_cycle,
                "a[href^=\"#{Settings.google_forms.current_cycle.new_course_for_unaccredited_bodies.url.gsub('?', '\?')}\"]",
                text: "Add a new course"

        element :link_to_add_a_course_for_accredited_bodies_current_cycle,
                "a[href^=\"#{Settings.google_forms.current_cycle.new_course_for_accredited_bodies.url.gsub('?', '\?')}\"]",
                text: "Add a new course"

        element :link_to_add_a_course_for_unaccredited_bodies_next_cycle,
                "a[href^=\"#{Settings.google_forms.next_cycle.new_course_for_unaccredited_bodies.url.gsub('?', '\?')}\"]",
                text: "Add a new course"

        element :link_to_add_a_course_for_accredited_bodies_next_cycle,
                "a[href^=\"#{Settings.google_forms.next_cycle.new_course_for_accredited_bodies.url.gsub('?', '\?')}\"]",
                text: "Add a new course"
      end
    end
  end
end
