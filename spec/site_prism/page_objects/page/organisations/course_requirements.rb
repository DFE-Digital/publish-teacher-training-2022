module PageObjects
  module Page
    module Organisations
      class CourseRequirements < CourseBase
        set_url "/organisations/{provider_code}/{recruitment_cycle_year}/courses/{course_code}/requirements"

        element :enrichment_form, '[data-qa="enrichment-form"]'
        element :required_qualifications, "#course-required-qualifications-field"
        element :personal_qualities, "#course-personal-qualities-field"
        element :other_requirements, "#course-other-requirements-field"
      end
    end
  end
end
