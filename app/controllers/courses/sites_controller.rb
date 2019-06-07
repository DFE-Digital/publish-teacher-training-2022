module Courses
  class SitesController < ApplicationController
    decorates_assigned :course
    before_action(
      :build_course,
      :build_provider
    )

    def edit; end

    def update
      @course.provider_code = @provider.provider_code
      selected_site_ids = params.dig(:course, :site_statuses_attributes)
        .values
        .select { |f| f["selected"] == "1" }
        .map { |f| f["id"] }

      @course.sites = @provider.sites.select { |site| selected_site_ids.include?(site.id) }

      if @course.save
        @course.sync_with_search_and_compare(provider_code: params[:provider_code])

        success_message = @course.is_running? ? 'Course locations saved and published' : 'Course locations saved'
        redirect_to provider_course_path(params[:provider_code], params[:code]), flash: { success: success_message }
      else
        @errors = @course.errors.full_messages

        render :edit
      end
    end

  private

    def build_course
      @provider_code = params[:provider_code]
      @course = Course
        .includes(:sites)
        .includes(provider: [:sites])
        .where(provider_code: @provider_code)
        .find(params[:code])
        .first
    end

    def build_provider
      @provider = @course.provider
    end
  end
end
