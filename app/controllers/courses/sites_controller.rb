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
      @course.sites = params.dig(:course, :site_statuses_attributes)
        &.values
        &.select { |field| field["selected"] == "1" }
        &.map { |field| @provider.sites.find { |site| site.id == field["id"] } }

      if @course.save
        @course.sync_with_search_and_compare(provider_code: params[:provider_code])

        redirect_to provider_course_path(params[:provider_code], params[:code]), flash: { success: 'Course locations published' }
      else
        @errors = @site.errors.reduce({}) { |errors, (field, message)|
          errors[field] ||= []
          errors[field].push(map_errors(message))
          errors
        }

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
