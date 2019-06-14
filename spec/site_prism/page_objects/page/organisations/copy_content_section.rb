module PageObjects
  module Page
    module Organisations
      class CopyContentSection < SitePrism::Section
        set_default_search_arguments '[data-qa="course__copy-content-form"]'

        def copy(course)
          select("#{course.name} (#{course.course_code})", from: 'Copy from')
          click_on('Copy content')
        end
      end
    end
  end
end
