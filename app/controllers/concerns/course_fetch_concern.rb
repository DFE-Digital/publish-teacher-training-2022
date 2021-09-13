module CourseFetchConcern
  extend ActiveSupport::Concern
  include ApplicationHelper

private

  def fetch_course
    @course = Courses::Fetch.by_code(
      provider_code: params[:provider_code],
      course_code: params[:code],
      cycle_year: cycle_year,
    )
  end

  def fetch_courses
    @provider = Provider
      .includes(courses: [:accrediting_provider])
      .where(recruitment_cycle_year: cycle_year)
      .find(params[:provider_code])
      .first

    @courses_by_accrediting_provider = Courses::Fetch.by_accrediting_provider(@provider)

    @self_accredited_courses = @courses_by_accrediting_provider.delete(@provider.provider_name)
  end

  def fetch_copy_course
    @source_course = Courses::Fetch.by_code(
      cycle_year: cycle_year,
      provider_code: params[:provider_code],
      course_code: params[:copy_from],
    )
  end

  def cycle_year
    params.fetch(
      :recruitment_cycle_year,
      Settings.current_cycle,
    )
  end
end
