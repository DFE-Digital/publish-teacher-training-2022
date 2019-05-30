module Courses
  class SitesController < ApplicationController
    decorates_assigned :course
    before_action(
      :build_course,
      :build_provider
    )

    def edit; end

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
