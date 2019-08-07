module Courses
  class LevelSendController < ApplicationController
    decorates_assigned :course
    before_action :build_course

    def update
      if @course.update(course_params)
        flash[:success] = 'Your changes have been saved'
        redirect_to(
          details_provider_recruitment_cycle_course_path(
            @course.provider_code,
            @course.recruitment_cycle_year,
            @course.course_code
          )
        )
      else
        @errors = @course.errors.messages
        render :edit
      end
    end

  private

    def course_params
      params.require(:course).permit(:is_send)
      params.require(:course).permit(:level)
    end

    def build_course
      @course = Course
        .where(recruitment_cycle_year: params[:recruitment_cycle_year])
        .where(provider_code: params[:provider_code])
        .find(params[:code])
        .first
    end
  end
end
