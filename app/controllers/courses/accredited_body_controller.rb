module Courses
  class AccreditedBodyController < ApplicationController
    include CourseBasicDetailConcern

    before_action :build_provider
    decorates_assigned :provider

  private

    def errors
      params.dig(:course, :accrediting_provider_code) ? {} : { accrediting_provider_code: ["Pick an accredited body"] }
    end

    def build_course
      @course = Course
        .where(recruitment_cycle_year: params[:recruitment_cycle_year])
        .where(provider_code: params[:provider_code])
        .includes(:accrediting_provider)
        .find(params[:code])
        .first
    end

    def course_params
      params.require(:course).permit(:accrediting_provider_code)
    end
  end
end
