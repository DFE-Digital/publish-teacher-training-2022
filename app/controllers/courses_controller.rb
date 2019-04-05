class CoursesController < ApplicationController
  before_action :authenticate
  before_action :build_course, only: %i[show delete withdraw]

  def index
    @provider = Provider.includes(:courses).find(params[:provider_code]).first
  end

  def show; end

  def withdraw; end

  def delete; end

private

  def build_course
    @course = Course.where(provider_code: params[:provider_code]).find(params[:code]).first
  end
end
