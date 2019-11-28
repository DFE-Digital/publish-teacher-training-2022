module Courses
  class AgeRangeController < ApplicationController
    include CourseBasicDetailConcern
    decorates_assigned :course
    before_action :build_course, only: %i[edit update]

    def update
      @errors = build_errors
      if @errors.present?
        @course.age_range_in_years = "#{age_from_param}_to_#{age_to_param}"
        return render :edit
      end

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

    def error_keys
      [:age_range_in_years]
    end

    def update_age_range_param
      params[:course][:age_range_in_years] = "#{age_from_param}_to_#{age_to_param}" if valid_custom_age_range?
    end

    def valid_custom_age_range?
      age_from_param.present? && age_to_param.present? && age_range_is_other?
    end

    def build_errors
      if age_range_from_and_to_missing?
        return {
          age_range_in_years: [t("age_range.errors.from_and_to_error")],
          age_range_in_years_from: [t("age_range.errors.from_missing_error")],
          age_range_in_years_to: [t("age_range.errors.to_missing_error")],
        }
      end

      if age_range_from_missing?
        return {
          age_range_in_years_from: [t("age_range.errors.from_missing_error")],
        }
      end

      if age_range_to_missing?
        return {
          age_range_in_years_to: [t("age_range.errors.to_missing_error")],
        }
      end

      if age_range_from_invalid?
        return {
          age_range_in_years: [t("age_range.errors.from_invalid_error")],
          age_range_in_years_from: [t("age_range.errors.from_invalid_error")],
        }
      end

      if age_range_less_than_4?
        {
          age_range_in_years: [t("age_range.errors.to_invalid_error")],
          age_range_in_years_to: [t("age_range.errors.to_invalid_error")],
        }
      end
    end

    def age_range_less_than_4?
      age_range_is_other? && ((age_to_param.to_i - age_from_param.to_i).abs < 4)
    end

    def age_range_from_invalid?
      age_range_is_other? && (age_from_param.to_i > age_to_param.to_i)
    end

    def age_range_from_and_to_missing?
      age_range_is_other? && (age_from_param.blank? && age_to_param.blank?)
    end

    def age_range_from_missing?
      age_range_is_other? && (age_from_param.blank? && age_to_param.present?)
    end

    def age_range_to_missing?
      age_range_is_other? && (age_from_param.present? && age_to_param.blank?)
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

    def build_course
      @course = Course
        .where(recruitment_cycle_year: params[:recruitment_cycle_year])
        .where(provider_code: params[:provider_code])
        .find(params[:code])
        .first
    end
  end
end
