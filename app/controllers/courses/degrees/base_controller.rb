module Courses
  module Degrees
    class BaseController < ApplicationController
      decorates_assigned :course
      before_action :build_course, :redirect_to_basic_details_page_if_provider_is_not_in_the_2022_cycle_or_higher

    private

      def build_course
        @course = Course
          .includes(:provider)
          .where(recruitment_cycle_year: params[:recruitment_cycle_year])
          .where(provider_code: params[:provider_code])
          .find(params[:code])
          .first
      end

      def redirect_to_basic_details_page_if_provider_is_not_in_the_2022_cycle_or_higher
        redirect_to provider_recruitment_cycle_course_path unless @course.provider.recruitment_cycle_year.to_i >= Provider::CHANGES_INTRODUCED_IN_2022_CYCLE
      end
    end
  end
end
