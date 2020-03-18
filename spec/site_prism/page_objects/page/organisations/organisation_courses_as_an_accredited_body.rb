module PageObjects
  module Page
    module Organisations
      class OrganisationCoursesAsAnAccreditedBody < CourseBase
        set_url "/organisations/{provider_code}/training-providers/{training_provider_code}/courses"

        sections :courses_tables, '[data-qa="courses__table-section"]' do
          element :subheading, "h2"
          sections :rows, "tbody tr" do
            element :name, '[data-qa="courses-table__course"]'
            element :course_name, "td.app-course-table__course-name"
            element :ucas_status, '[data-qa="courses-table__ucas-status"]'
            element :status, '[data-qa="courses-table__status"]'
            element :on_find, '[data-qa="courses-table__findable"]'
            element :find_link, '[data-qa="courses-table__findable"] a'
            element :applications, '[data-qa="courses-table__applications"]'
            element :vacancies, '[data-qa="courses-table__vacancies"]'
          end
        end
      end
    end
  end
end
