module Courses
  module Degrees
    class BaseController < ApplicationController
      include CourseBuilderConcern

      decorates_assigned :course
      before_action :build_course, :redirect_to_basic_details_page_if_provider_is_not_in_the_2022_cycle_or_higher
      before_action :build_copy_course, if: -> { params[:copy_from].present? }

    private

      def redirect_to_basic_details_page_if_provider_is_not_in_the_2022_cycle_or_higher
        redirect_to provider_recruitment_cycle_course_path unless @course.provider.recruitment_cycle_year.to_i >= Provider::CHANGES_INTRODUCED_IN_2022_CYCLE
      end

      def copy_field_if_present_in_source_course(field)
        source_value = @source_course[field]
        course[field] = source_value if source_value.present?
      end
    end
  end
end
