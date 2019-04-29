class CoursesController < ApplicationController
  decorates_assigned :course
  before_action :build_course, only: %i[show description delete withdraw]
  before_action :build_provider, only: %i[show description]

  def index
    @provider = Provider
      .includes(courses: [:accrediting_provider])
      .find(params[:provider_code])
      .first

    # rubocop:disable Style/MultilineBlockChain
    @courses_by_accrediting_provider = @provider
      .courses
      .group_by { |course|
        # HOTFIX: A courses API response no included hash seems to cause issues with the
        # .accrediting_provider relationship lookup. To be investigated, for now,
        # if this throws, it's self-accredited.
        begin
          course.accrediting_provider&.provider_name || @provider.provider_name
        rescue StandardError
          @provider.provider_name
        end
      }
      .sort_by { |accrediting_provider, _| accrediting_provider }
      .map { |provider_name, courses|
      [provider_name, courses.sort_by { |course| [course.name, course.course_code] }
                             .map(&:decorate)]
    }
      .to_h
    # rubocop:enable Style/MultilineBlockChain

    @self_accredited_courses = @courses_by_accrediting_provider.delete(@provider.provider_name)
  end

  def show; end

  def description; end

  def withdraw; end

  def delete; end

private

  def build_course
    @provider_code = params[:provider_code]
    @course = Course
      .includes(site_statuses: [:site])
      .includes(provider: [:sites])
      .includes(:accrediting_provider)
      .where(provider_code: @provider_code)
      .find(params[:code])
      .first
  end

  def build_provider
    @provider = @course.provider
  end
end
