class TrainingProvidersCoursesController < ApplicationController
  decorates_assigned :course
  decorates_assigned :provider
  before_action :build_recruitment_cycle
  rescue_from JsonApiClient::Errors::NotFound, with: :not_found
  before_action :build_provider

  def index
    course_csv_rows = Course.includes(:provider)
      .where(recruitment_cycle_year: @recruitment_cycle.year, accredited_body_code: @provider.provider_code)
      .map(&:decorate)
      .map do |c|
      {
        "Provider code" => c.provider.provider_code,
        "Provider" => c.provider.provider_name,
        "Course code" => c.course_code,
        "Course" => c.name,
        "Study mode" => c.study_mode&.humanize,
        "Qualification" => c.outcome,
        "Status" => c.content_status&.humanize,
        "View on Find" => c.find_url,
        "Applications open from" => l(c.applications_open_from&.to_date),
        "Vacancies" => c.has_vacancies? ? "Yes" : "No",
      }
    end

    courses_csv_string = CSV.generate(headers: course_csv_rows.first.keys, write_headers: true) do |csv|
      course_csv_rows.each do |course_csv_row|
        csv << course_csv_row
      end
    end

    respond_to do |format|
      format.csv { send_data courses_csv_string, filename: "courses-#{Time.zone.today}.csv" }
    end
  end

private

  def build_provider
    @provider = Provider
      .where(recruitment_cycle_year: @recruitment_cycle.year)
      .find(params[:provider_code])
      .first
  end

  def build_recruitment_cycle
    cycle_year = params.fetch(:year, Settings.current_cycle)

    @recruitment_cycle = RecruitmentCycle.find(cycle_year).first
  end
end
