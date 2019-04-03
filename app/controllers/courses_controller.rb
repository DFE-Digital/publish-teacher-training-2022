class CoursesController < ApplicationController
  before_action :authenticate
  before_action :build_course, only: %i[show delete withdraw]

  def index
    @provider = Provider
      .includes(courses: [:accrediting_provider])
      .find(params[:provider_code])
      .first

    @courses_by_accrediting_provider = @provider
      .courses
      .group_by { |course| course.accrediting_provider&.provider_name || @provider[:provider_name] }
      .sort_by { |accrediting_provider, _| accrediting_provider }
      .map { |pair| [pair[0], pair[1].sort_by(&:name)] }
      .to_h

    @self_accredited_courses = @courses_by_accrediting_provider.delete(@provider[:provider_name])
  end

  def show; end

  def withdraw; end

  def delete; end

private

  def build_course
    @course = Course.where(provider_code: params[:provider_code]).find(params[:code]).first
  end
end
