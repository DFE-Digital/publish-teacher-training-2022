module Courses
  class AccreditedBodyController < ApplicationController
    before_action :build_course_params, only: :continue
    include CourseBasicDetailConcern

    decorates_assigned :provider

    def edit
      build_provider
    end

    def continue
      other_selected_with_no_autocompleted_code = course_params[:accrediting_provider_code] == "other" && @autocompleted_provider_code.blank?

      if other_selected_with_no_autocompleted_code
        redirect_to(
          search_new_provider_recruitment_cycle_courses_accredited_body_path(
            query: @accredited_body,
            course: course_params,
          ),
        )
      else
        params[:course][:accrediting_provider_code] = @autocompleted_provider_code if @autocompleted_provider_code.present?
        super
      end
    end

    def search_new
      # These are not before_action hooks as they conflict with hooks
      # defined within the CourseBasicDetailConcern and cannot be overridden
      # without causing failures in other routes in this controller
      build_new_course
      build_provider
      build_previous_course_creation_params
      @query = params[:query]
      @provider_suggestions = ProviderSuggestion.suggest(@query)
    rescue JsonApiClient::Errors::ClientError => e
      @errors = e
    end

    def update
      build_provider
      code = update_course_params[:accrediting_provider_code]
      query = update_course_params[:accredited_body]

      @errors = errors_for_search_query(code, query)
      return render :edit if @errors.present?

      if update_params[:accrediting_provider_code] == "other"
        redirect_to_provider_search
      elsif @course.update(update_params)
        redirect_to_update_successful
      else
        @errors = @course.errors.messages
        render :edit
      end
    end

    def search
      build_course
      @query = params[:query]
      @provider_suggestions = ProviderSuggestion.suggest(@query)
    rescue JsonApiClient::Errors::ClientError => e
      @errors = e
    end

  private

    def build_provider
      @provider = Provider
                    .includes(:sites)
                    .where(recruitment_cycle_year: params[:recruitment_cycle_year])
                    .find(params[:provider_code])
                    .first
    end

    def error_keys
      [:accrediting_provider_code]
    end

    def redirect_to_provider_search
      redirect_to(
        accredited_body_search_provider_recruitment_cycle_course_path(
          @course.provider_code,
          @course.recruitment_cycle_year,
          @course.course_code,
          query: update_course_params[:accredited_body],
        ),
      )
    end

    def redirect_to_update_successful
      flash[:success] = "Your changes have been saved"
      redirect_to(
        details_provider_recruitment_cycle_course_path(
          @course.provider_code,
          @course.recruitment_cycle_year,
          @course.course_code,
        ),
      )
    end

    def current_step
      :accredited_body
    end

    def build_course_params
      @accredited_body = params[:course].delete(:accredited_body)
      @autocompleted_provider_code = params[:course].delete(:autocompleted_provider_code)
    end

    def errors_for_search_query(code, query)
      errors = {}

      if code == "other" && query.length < 3
        errors = { accredited_body: ["Accredited body search too short, enter 2 or more characters"] }
      elsif code.blank?
        errors = { accrediting_provider_code: ["Pick an accredited body"] }
      end

      errors
    end

    def build_course
      @course = Course
        .where(recruitment_cycle_year: params[:recruitment_cycle_year])
        .where(provider_code: params[:provider_code])
        .includes(:accrediting_provider)
        .find(params[:code])
        .first
    end

    def update_course_params
      params.require(:course).permit(
        :autocompleted_provider_code,
        :accrediting_provider_code,
        :accredited_body,
      )
    end

    def update_params
      autocompleted_code = update_course_params[:autocompleted_provider_code]
      code = update_course_params[:accrediting_provider_code]

      {
        accrediting_provider_code: if autocompleted_code.blank?
                                   then code
                                   else autocompleted_code
                                   end,
      }
    end
  end
end
