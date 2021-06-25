module Courses
  class GcseRequirementsController < ApplicationController
    decorates_assigned :course
    before_action :build_course, :redirect_to_basic_details_page_if_provider_is_not_in_the_22_cycle_or_higher

    def edit
      @gcse_requirements_form = GcseRequirementsForm.build_from_course(@course)
    end

    def update
      @gcse_requirements_form = GcseRequirementsForm.new(
        accept_pending_gcse: accept_pending_gcse_required_params, accept_gcse_equivalency: accept_gcse_equivalency_required_params,
        accept_english_gcse_equivalency: accept_english_gcse_equivalency_required_params, accept_maths_gcse_equivalency: accept_maths_gcse_equivalency_required_params,
        accept_science_gcse_equivalency: accept_science_gcse_equivalency_required_params, additional_gcse_equivalencies: additional_gcse_equivalencies_required_params
    )

      if @gcse_requirements_form.save(@course)
        redirect_to provider_recruitment_cycle_course_path
      else
        @errors = @gcse_requirements_form.errors.messages
        render :edit
      end
    end

  private

    def accept_pending_gcse_required_params
      translate_params(params.dig(:courses_gcse_requirements_form, :accept_pending_gcse))
    end

    def accept_gcse_equivalency_required_params
      translate_params(params.dig(:courses_gcse_requirements_form, :accept_gcse_equivalency))
    end

    def accept_english_gcse_equivalency_required_params
      translate_params(params.dig(:courses_gcse_requirements_form, :accept_english_gcse_equivalency))
    end

    def accept_maths_gcse_equivalency_required_params
      translate_params(params.dig(:courses_gcse_requirements_form, :accept_maths_gcse_equivalency))
    end

    def accept_science_gcse_equivalency_required_params
      translate_params(params.dig(:courses_gcse_requirements_form, :accept_science_gcse_equivalency))
    end

    def additional_gcse_equivalencies_required_params
      params.dig(:courses_gcse_requirements_form, :additional_gcse_equivalencies)
    end

    def translate_params(key)
      case key
      when "true" then true
      when "false" then false
      when ["Maths"] then true
      when ["English"] then true
      when ["Science"] then true
      else
        false
      end
    end

    def build_course
      @course = Course
        .includes(:provider)
        .where(recruitment_cycle_year: params[:recruitment_cycle_year])
        .where(provider_code: params[:provider_code])
        .find(params[:code])
        .first
    end

    def redirect_to_basic_details_page_if_provider_is_not_in_the_22_cycle_or_higher
      redirect_to provider_recruitment_cycle_course_path unless @course.provider.recruitment_cycle_year.to_i >= Provider::CHANGES_INTRODUCED_IN_2022_CYCLE
    end
  end
end
