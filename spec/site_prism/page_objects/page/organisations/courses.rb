module PageObjects
  module Page
    module Organisations
      class Courses < PageObjects::Base
        set_url '/organisations/{provider_code}/courses'

        element :flash, '.govuk-success-summary'

        sections :courses_tables, '[data-qa="courses__table-section"]' do
          element :subheading, 'h2'
          sections :rows, 'tbody tr' do
            element :name, '[data-qa="courses-table__course"]'
            element :link, 'td.course-table__course-name a'
            element :ucas_status, '[data-qa="courses-table__ucas-status"]'
            element :content_status, '[data-qa="courses-table__content-status"]'
            element :is_it_on_find, '[data-qa="courses-table__findable"]'
            element :find_link, '[data-qa="courses-table__findable"] a'
            element :applications, '[data-qa="courses-table__applications"]'
            element :vacancies, '[data-qa="courses-table__vacancies"]'
          end
        end

        element :link_to_add_a_course_for_unaccredited_bodies, "a[href^=\"#{Settings.google_forms.new_course_for_unaccredited_bodies.url.gsub('?', '\?')}\"]",
                text: "Add a new course"

        element :link_to_add_a_course_for_accredited_bodies, "a[href^=\"#{Settings.google_forms.new_course_for_accredited_bodies.url.gsub('?', '\?')}\"]",
                text: "Add a new course"
      end
    end
  end
end
