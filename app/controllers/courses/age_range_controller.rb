module Courses
  class AgeRangeController < ApplicationController
    include CourseBasicDetailConcern
    decorates_assigned :course
    before_action :build_course, only: %i[edit update]

    def update
      @errors = build_errors
      return render :edit if @errors.present?

      update_age_range_param

      if @course.update(course_params)
        flash[:success] = "Your changes have been saved"
        redirect_to(
          details_provider_recruitment_cycle_course_path(
            @course.provider_code,
            @course.recruitment_cycle_year,
            @course.course_code,
          ),
        )
      else
        @errors = @course.errors.messages
        render :edit
      end
    end

  private

    def update_age_range_param
      if age_from_param.present? && age_to_param.present? && age_range_is_other?
        params[:course][:age_range_in_years] = "#{age_from_param}_to_#{age_to_param}"
      elsif age_range_is_other?
        params[:course][:age_range_in_years] = nil
      end
    end

    def build_errors
      if age_range_is_other? && (age_from_param.blank? || age_to_param.blank?)
        {
          age_range_in_years: ["Enter an age for both from and to"],
          age_range_in_years_from: ["Enter an age"],
          age_range_in_years_to: ["Enter an age"],
        }
      end
    end

    def age_to_param
      course_param.dig(:course_age_range_in_years_other_to)
    end

    def age_from_param
      course_param.dig(:course_age_range_in_years_other_from)
    end

    def age_range_param
      course_param.dig(:age_range_in_years)
    end

    def age_range_is_other?
      age_range_param == "other"
    end

    def course_param
      params.dig(:course)
    end

    def current_step
      :age_range
    end

    def errors; end

    def build_course
      @course = Course
        .where(recruitment_cycle_year: params[:recruitment_cycle_year])
        .where(provider_code: params[:provider_code])
        .find(params[:code])
        .first
    end
  end
end
