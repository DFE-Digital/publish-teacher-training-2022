class Course < Base
  belongs_to :recruitment_cycle, through: :provider, param: :recruitment_cycle_year
  belongs_to :provider, param: :provider_code
  has_many :site_statuses
  has_many :sites, through: :site_statuses, source: :site

  custom_endpoint :sync_with_search_and_compare, on: :member, request_method: :post
  custom_endpoint :build_new, on: :collection, request_method: :get

  property :fee_international, type: :string
  property :fee_uk_eu, type: :string
  property :maths, type: :string
  property :english, type: :string
  property :science, type: :string

  self.primary_key = :course_code

  def publish
    post_request('/publish')
  end

  def publishable?
    post_request('/publishable')
  end

  def full_time?
    study_mode == 'full_time'
  end

  def part_time?
    study_mode == 'part_time'
  end

  def full_time_or_part_time?
    study_mode == 'full_time_or_part_time'
  end

  def is_running?
    ucas_status == 'running'
  end

  def not_running?
    ucas_status == 'not_running'
  end

  def new_and_not_running?
    ucas_status == 'new'
  end

  def has_fees?
    funding == 'fee'
  end

  def has_unpublished_changes?
    content_status == "published_with_unpublished_changes"
  end

  def is_published?
    content_status == 'published'
  end

  def running_site_statuses
    site_statuses.select(&:running?)
  end

  def has_multiple_running_sites_or_study_modes?
    running_site_statuses.length > 1 || full_time_or_part_time?
  end

  def year
    applications_open_from.split('-').first if applications_open_from.present?
  end

  def month
    applications_open_from.split('-').second if applications_open_from.present?
  end

  def day
    applications_open_from.split('-').third if applications_open_from.present?
  end

private

  def post_base_url
    "#{Course.site}#{Course.path}/%<course_code>s" % path_attributes
  end
end
