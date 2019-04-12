class CoursesController < ApplicationController
  before_action :authenticate
  before_action :build_course, only: %i[show delete withdraw]
  before_action :build_provider, only: %i[index show]

  def index
    # rubocop:disable Style/MultilineBlockChain
    @courses_by_accrediting_provider = @provider
      .courses
      .group_by { |course|
        # HOTFIX: A courses API response no included hash seems to cause issues with the
        # .accrediting_provider relationship lookup. To be investigated, for now,
        # if this throws, it's self-accredited.
        begin
          course.accrediting_provider&.provider_name || @provider[:provider_name]
        rescue StandardError
          @provider[:provider_name]
        end
      }
      .sort_by { |accrediting_provider, _| accrediting_provider }
      .map { |pair| [pair[0], pair[1].sort_by { |course| [course.name, course.course_code] }] }
      .to_h
    # rubocop:enable Style/MultilineBlockChain

    @self_accredited_courses = @courses_by_accrediting_provider.delete(@provider[:provider_name])
  end

  def show; end

  def withdraw; end

  def delete; end

private

  def build_provider
    @provider = Provider
      .includes(courses: [:accrediting_provider])
      .find(params[:provider_code])
      .first
  end

  def build_course
    @provider_code = params[:provider_code]
    @course = Course.where(provider_code: @provider_code).find(params[:code]).first
  end
end
