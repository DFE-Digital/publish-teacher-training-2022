class Course < Base
  belongs_to :provider, param: :provider_code
  has_many :site_statuses
  has_many :sites, through: :site_statuses, source: :site

  custom_endpoint :sync_with_search_and_compare, on: :member, request_method: :post

  self.primary_key = :course_code

  def full_time?
    study_mode == 'full_time'
  end

  def part_time?
    study_mode == 'part_time'
  end

  def full_time_or_part_time?
    study_mode == 'full_time_or_part_time'
  end

  def applications_being_accepted_now?
    attributes[:applications_being_accepted_now?]
  end

  def has_vacancies?
    attributes[:has_vacancies?]
  end
end
