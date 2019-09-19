module PageObjects
  module Page
    module Organisations
      module Courses
        class NewApplicationsOpenPage < CourseBase
          set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/applications-open/new{?query*}"

          element :applications_open_field, '[data-qa="applications_open_from"]'
          element :applications_open_field_other, '[data-qa="applications_open_from_other"]'
          element :applications_open_field_day, '[data-qa="day"]'
          element :applications_open_field_month, '[data-qa="month"]'
          element :applications_open_field_year, '[data-qa="year"]'
          element :continue, '[data-qa="course__save"]'
        end
      end
    end
  end
end
