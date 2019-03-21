module Courses
  class VacanciesController < ApplicationController
    before_action :authenticate, :get_course

    def edit
      @site_statuses = @course.site_statuses
    end

  private

    def get_course
      @course = Course.where(provider_code: params[:provider_code]).find(params[:code]).first
    end
  end
end
