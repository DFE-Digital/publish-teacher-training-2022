class CoursesController < ApplicationController
  before_action :authenticate

  def vacancies
    @course = Course.where(provider_code: params[:provider_code]).find(params[:code]).first
    @site_statuses = @course.site_statuses
  end
end
