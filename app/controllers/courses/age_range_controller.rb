module Courses
  class AgeRangeController < ApplicationController
    decorates_assigned :course
    before_action :build_course, only: %i[edit update]
    before_action :build_provider, :build_new_course, only: %i[new continue]

    def new; end

    def continue
      redirect_to confirmation_provider_recruitment_cycle_courses_path(
        params[:provider_code],
        params[:recruitment_cycle_year],
        course_params
      )
    end

    def update
      # Age range 'other' override
      course = params.dig(:course)
      is_other = course.dig(:age_range_in_years) == "other"
      age_from = course.dig(:course_age_range_in_years_other_from)
      age_to = course.dig(:course_age_range_in_years_other_to)

      if is_other && (age_from.blank? || age_to.blank?)
        errors = {
          age_range_in_years: ["Enter an age for both from and to"],
          age_range_in_years_from: ["Enter an age"],
          age_range_in_years_to: ["Enter an age"],
        }
      elsif age_from.present? && age_to.present? && is_other
        params[:course][:age_range_in_years] = "#{age_from}_to_#{age_to}"
      elsif is_other
        params[:course][:age_range_in_years] = nil
      end

      @errors = errors
      return render :edit if @errors.present?

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
      if params.key? :course
        params.require(:course).permit(:age_range_in_years)
      else
        ActionController::Parameters.new({}).permit(:course)
      end
    end

    def build_provider
      @provider = Provider
                    .where(recruitment_cycle_year: params[:recruitment_cycle_year])
                    .find(params[:provider_code])
                    .first
    end

    def build_course
      @course = Course
        .where(recruitment_cycle_year: params[:recruitment_cycle_year])
        .where(provider_code: params[:provider_code])
        .find(params[:code])
        .first
    end

    def build_new_course
      @course = Course.build_new(
        recruitment_cycle_year: @provider.recruitment_cycle_year,
        provider_code: @provider.provider_code
      )
    end
  end
end
