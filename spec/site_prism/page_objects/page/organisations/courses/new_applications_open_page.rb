module PageObjects
  module Page
    module Organisations
      module Courses
        class NewApplicationsOpenPage < CourseBase
          set_url '/organisations/{provider_code}/{recruitment_cycle_year}/courses/application_open/new'

          element :applications_open_field, '[data-qa="applications_open_from"]'
          element :applications_open_field_other, '[data-qa="applications_open_from_other"]'
          element :applications_open_field_day, '[data-qa="day"]'
          element :applications_open_field_month, '[data-qa="month"]'
          element :applications_open_field_year, '[data-qa="year"]'
        end
      end
    end
  end
end
