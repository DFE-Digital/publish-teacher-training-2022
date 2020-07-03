module Courses
  class TitleController < ApplicationController
    before_action :check_admin

    def edit
      render locals: { course: course }
    end

    def update
      if course.update(course_params)
        flash[:success] = "Your changes have been saved"

        redirect_to(
          details_provider_recruitment_cycle_course_path(
            course.provider_code,
            course.recruitment_cycle_year,
            course.course_code,
          ),
        )
      else
        @errors = course.errors.messages
        render :edit, locals: { course: course }
      end
    end

  private

    def course
      @course ||= Course
        .where(recruitment_cycle_year: recruitment_cycle.year)
        .where(provider_code: params[:provider_code])
        .find(params[:code])
        .first
        .decorate
    end

    def course_params
      params.require(:course).permit(:name)
    end

    def recruitment_cycle
      return @recruitment_cycle if @recruitment_cycle

      cycle_year = params.fetch(
        :recruitment_cycle_year,
        Settings.current_cycle,
      )

      @recruitment_cycle = RecruitmentCycle.find(cycle_year).first
    end

    def check_admin
      unless user_is_admin?
        render "errors/forbidden", status: :forbidden
      end
    end
  end
end
