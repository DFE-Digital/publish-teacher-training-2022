class Course < Base
  belongs_to :recruitment_cycle, through: :provider, param: :recruitment_cycle_year
  belongs_to :provider, param: :provider_code, shallow_path: true
  has_many :site_statuses
  has_many :sites, through: :site_statuses, source: :site
  has_many :subjects

  property :fee_international, type: :string
  property :fee_uk_eu, type: :string
  property :maths, type: :string
  property :english, type: :string
  property :science, type: :string
  property :name, type: :string
  property :degree_grade, type: :string
  property :additional_degree_subject_requirements, type: :boolean
  property :degree_subject_requirements, type: :string
  property :accept_pending_gcse, type: :boolean
  property :accept_gcse_equivalency, type: :boolean
  property :accept_english_gcse_equivalency, type: :boolean
  property :accept_maths_gcse_equivalency, type: :boolean
  property :accept_science_gcse_equivalency, type: :boolean
  property :additional_gcse_equivalencies, type: :string

  delegate :provider_type, to: :provider

  custom_endpoint :send_vacancies_updated_notification, on: :member, request_method: :post

  self.primary_key = :course_code

  def publish
    post_request("/publish")
  end

  def publishable?
    post_request("/publishable")
  end

  def withdraw
    post_request("/withdraw")
  end

  def self.build_new(params)
    response = connection.run(:get, "#{Course.site}build_new_course?#{params.to_query}")

    course = Course.parser.parse(Course, response).first
    course.meta = response.body["data"]["meta"]

    response.body["data"]["errors"].each do |error_hash|
      key = error_hash["source"]["pointer"].sub("/data/attributes/", "")
      course.errors.add(key, error_hash["detail"])
    end

    course
  end

  def has_physical_education_subject?
    subjects.map(&:subject_name).include?("Physical education")
  end

  def full_time?
    study_mode == "full_time"
  end

  def part_time?
    study_mode == "part_time"
  end

  def full_time_or_part_time?
    study_mode == "full_time_or_part_time"
  end

  def is_running?
    ucas_status == "running"
  end

  def not_running?
    ucas_status == "not_running"
  end

  def new_and_not_running?
    ucas_status == "new"
  end

  def has_fees?
    funding_type == "fee"
  end

  def has_unpublished_changes?
    content_status == "published_with_unpublished_changes"
  end

  def is_published?
    content_status == "published"
  end

  def is_withdrawn?
    content_status == "withdrawn" || not_running?
  end

  def running_site_statuses
    site_statuses.select(&:running?)
  end

  def has_multiple_running_sites_or_study_modes?
    running_site_statuses.length > 1 || full_time_or_part_time?
  end

  def year
    applications_open_from.split("-").first if applications_open_from.present?
  end

  def month
    applications_open_from.split("-").second if applications_open_from.present?
  end

  def day
    applications_open_from.split("-").third if applications_open_from.present?
  end

  def is_school_direct?
    !(is_uni_or_scitt? || is_further_education?)
  end

  def is_uni_or_scitt?
    provider.accredited_body?
  end

  def is_further_education?
    level == "further_education"
  end

  def travel_to_work_areas
    travel_to_work_areas = sites.map { |site| site.london_borough || site.travel_to_work_area }.uniq

    travel_to_work_areas.to_sentence(last_word_connector: " and ")
  end

  def degree_section_complete?
    degree_grade.present?
  end

  def is_primary?
    level == "primary"
  end

  def gcse_section_complete?
    !accept_pending_gcse.nil? && !accept_gcse_equivalency.nil?
  end

private

  def post_base_url
    sprintf("#{Course.site}#{Course.path}/%<course_code>s", path_attributes)
  end
end
