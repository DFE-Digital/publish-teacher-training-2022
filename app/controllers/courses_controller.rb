class CoursesController < ApplicationController
  before_action :authenticate

  def index
    @provider = Provider.find(params[:code]).first.attributes
    @courses = Course.where(provider_code: params[:provider_code])
  end

  def show
    @course = Course.where(provider_code: params[:provider_code]).find(params[:code]).first
  end
end
