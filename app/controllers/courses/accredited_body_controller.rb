module Courses
  class AccreditedBodyController < ApplicationController
    include CourseBasicDetailConcern

    before_action :build_course_params, only: :continue
    decorates_assigned :provider

    def edit
      build_provider
    end

    def update
      build_provider
      @errors = errors
      return render :edit if @errors.present?

      if update_params[:accrediting_provider_code] == "other"
        redirect_to(
          accredited_body_search_provider_recruitment_cycle_course_path(
            @course.provider_code,
            @course.recruitment_cycle_year,
            @course.course_code,
            query: update_course_params[:accredited_body],
          ),
        )
      elsif @course.update(update_params)
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

    def search
      build_course
      @query = params[:query]
      @provider_suggestions = ProviderSuggestion.suggest(@query)
    rescue JsonApiClient::Errors::ClientError => e
      @errors = e
    end

  private

    def errors
      code = update_course_params[:accrediting_provider_code]
      query = update_course_params[:accredited_body]
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
