module PageObjects
  module Page
    module Organisations
      class Courses < PageObjects::Base
        set_url '/organisations/{provider_code}/courses'

        element :title, '.govuk-heading-xl'
        sections :rows, 'tbody .govuk-table__row' do
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
    end
  end
end
