module Courses
  class GcseRequirementsController < ApplicationController
    decorates_assigned :course
    before_action :build_course, :redirect_to_basic_details_page_if_provider_is_not_in_the_2022_cycle_or_higher
    before_action :build_copy_course, if: -> { params[:copy_from].present? }

    def edit
      @gcse_requirements_form = GcseRequirementsForm.build_from_course(@course)

      if params[:copy_from].present?
        @copied_fields = [
          ["Accept pending GCSE", "accept_pending_gcse"],
          ["Accept GCSE equivalency", "accept_gcse_equivalency"],
          ["Accept English GCSE equivalency", "accept_english_gcse_equivalency"],
          ["Accept Maths GCSE equivalency", "accept_maths_gcse_equivalency"],
          ["Additional GCSE equivalencies", "additional_gcse_equivalencies"],
        ].keep_if { |_name, field| copy_field_if_present_in_source_course(field) }
        @gcse_requirements_form = GcseRequirementsForm.build_from_course(@course)
      end
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

    def build_course
      cycle_year = params.fetch(
        :recruitment_cycle_year,
        Settings.current_cycle,
      )

      @course = Course
        .includes(:provider)
        .where(recruitment_cycle_year: params[:recruitment_cycle_year])
        .where(provider_code: params[:provider_code])
        .find(params[:code])
        .first

      @provider = Provider
        .includes(courses: [:accrediting_provider])
        .where(recruitment_cycle_year: cycle_year)
        .find(params[:provider_code])
        .first

      # rubocop:disable Style/MultilineBlockChain
      @courses_by_accrediting_provider = @provider
        .courses
        .group_by { |course|
          # HOTFIX: A courses API response no included hash seems to cause issues with the
          # .accrediting_provider relationship lookup. To be investigated, for now,
          # if this throws, it's self-accredited.
          begin
            course.accrediting_provider&.provider_name || @provider.provider_name
          rescue StandardError
            @provider.provider_name
          end
        }
        .sort_by { |accrediting_provider, _| accrediting_provider.downcase }
        .map { |provider_name, courses|
        [provider_name,
         courses.sort_by { |course| [course.name, course.course_code] }
                                      .map(&:decorate)]
      }
        .to_h
      # rubocop:enable Style/MultilineBlockChain

      @self_accredited_courses = @courses_by_accrediting_provider.delete(@provider.provider_name)
    end

    def redirect_to_basic_details_page_if_provider_is_not_in_the_2022_cycle_or_higher
      redirect_to provider_recruitment_cycle_course_path unless @course.provider.recruitment_cycle_year.to_i >= Provider::CHANGES_INTRODUCED_IN_2022_CYCLE
    end

    def copy_field_if_present_in_source_course(field)
      source_value = @source_course[field]
      course[field] = source_value if source_value.present?
    end

    def build_copy_course
      cycle_year = params.fetch(
        :recruitment_cycle_year,
        Settings.current_cycle,
      )

      @source_course = Course
        .includes(:subjects)
        .includes(:sites)
        .includes(provider: [:sites])
        .includes(:accrediting_provider)
        .where(recruitment_cycle_year: cycle_year)
        .where(provider_code: params[:provider_code])
        .find(params[:copy_from])
        .first
    end
  end
end
