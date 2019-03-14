class CoursesController < ApplicationController
  before_action :authenticate

  def vacancies
    @course = Course.where(provider_id: params[:provider_code]).find(params[:code]).first.attributes
  end
end
