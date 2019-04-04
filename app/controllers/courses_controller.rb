class CoursesController < ApplicationController
  before_action :authenticate

  def index
    @provider = Provider.includes(:courses).find(params[:provider_code]).first
  end

  def show
    @course = Course.where(provider_code: params[:provider_code]).find(params[:code]).first
  end
end
