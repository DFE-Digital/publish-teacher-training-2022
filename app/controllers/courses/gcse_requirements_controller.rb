module Courses
  class GcseRequirementsController < ApplicationController
    include CourseFetchConcern

    decorates_assigned :course
    before_action :fetch_course, :redirect_to_basic_details_page_if_provider_is_not_in_the_2022_cycle_or_higher
    before_action :fetch_copy_course, if: -> { params[:copy_from].present? }
    before_action :fetch_courses, only: %i[edit]

    def edit
      if params[:copy_from].present?
        @copied_fields = Courses::CloneableFields::GCSE.select { |_name, field| copy_field_if_present_in_source_course(field) }
      end

      @gcse_requirements_form = GcseRequirementsForm.build_from_course(@course)
    end

    def update
      @gcse_requirements_form = GcseRequirementsForm.new(
        accept_pending_gcse: accept_pending_gcse_required_params, accept_gcse_equivalency: accept_gcse_equivalency_required_params,
        accept_english_gcse_equivalency: accept_english_gcse_equivalency_required_params, accept_maths_gcse_equivalency: accept_maths_gcse_equivalency_required_params,
        accept_science_gcse_equivalency: accept_science_gcse_equivalency_required_params, additional_gcse_equivalencies: additional_gcse_equivalencies_required_params,
        level: @course.level
      )

      if @gcse_requirements_form.save(@course)
        flash[:success] = "Your changes have been saved"

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
      raw(params.dig(:courses_gcse_requirements_form, :additional_gcse_equivalencies))
    end

    def translate_params(key)
      case key
      when "true" then true
      when "false" then false
      when %w[Maths] then true
      when %w[English] then true
      when %w[Science] then true
      end
    end

    def redirect_to_basic_details_page_if_provider_is_not_in_the_2022_cycle_or_higher
      redirect_to provider_recruitment_cycle_course_path unless @course.provider.recruitment_cycle_year.to_i >= Provider::CHANGES_INTRODUCED_IN_2022_CYCLE
    end

    def copy_field_if_present_in_source_course(field)
      source_value = @source_course[field]
      course[field] = source_value if source_value.present?
    end
  end
end
