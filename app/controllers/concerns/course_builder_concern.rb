module CourseBuilderConcern
  extend ActiveSupport::Concern
  include ApplicationHelper

  def build_course
    cycle_year = params.fetch(
      :recruitment_cycle_year,
      Settings.current_cycle,
    )

    @course = Course
      .includes(:subjects)
      .includes(:sites)
      .includes(provider: [:sites])
      .includes(:accrediting_provider)
      .where(recruitment_cycle_year: cycle_year)
      .where(provider_code: params[:provider_code])
      .find(params[:code])
      .first
  rescue JsonApiClient::Errors::NotFound
    render template: "errors/not_found", status: :not_found
  end

  def build_courses
    cycle_year = params.fetch(
      :recruitment_cycle_year,
      Settings.current_cycle,
    )

    @provider = Provider
      .includes(courses: [:accrediting_provider])
      .where(recruitment_cycle_year: cycle_year)
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
      .sort_by { |accrediting_provider, _| accrediting_provider.downcase }
      .map { |provider_name, courses|
      [provider_name,
       courses.sort_by { |course| [course.name, course.course_code] }
                                    .map(&:decorate)]
    }
      .to_h
    # rubocop:enable Style/MultilineBlockChain

    @self_accredited_courses = @courses_by_accrediting_provider.delete(@provider.provider_name)
  end

  def build_copy_course
    cycle_year = params.fetch(
      :recruitment_cycle_year,
      Settings.current_cycle,
    )

    @source_course = Course
      .includes(:subjects)
      .includes(:sites)
      .includes(provider: [:sites])
      .includes(:accrediting_provider)
      .where(recruitment_cycle_year: cycle_year)
      .where(provider_code: params[:provider_code])
      .find(params[:copy_from])
      .first
  end
end
