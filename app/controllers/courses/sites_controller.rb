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
        .map { |f| f["id"].to_i }

      @course.sites = @provider.sites.select { |site| selected_site_ids.include?(site.id) }

      if @course.save
        @course.sync_with_search_and_compare(provider_code: params[:provider_code])

        redirect_to provider_course_path(params[:provider_code], params[:code]), flash: { success: 'Course locations saved' }
      else
        # TODO: Change this to be @course.errors when the API is updated.
        flash[:error] = "You must choose at least one location"

        render :edit
      end
    end

  private

    def build_course
      @provider_code = params[:provider_code]
      @course = Course
        .includes(site_statuses: [:site])
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
