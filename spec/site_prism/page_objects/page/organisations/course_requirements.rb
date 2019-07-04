module PageObjects
  module Page
    module Organisations
      class CourseRequirements < CourseBase
        set_url '/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/requirements'

        element :enrichment_form, '[data-qa="enrichment-form"]'
        element :required_qualifications, '#course_required_qualifications'
        element :personal_qualities, '#course_personal_qualities'
        element :other_requirements, '#course_other_requirements'
      end
    end
  end
end
