class Course < Base
  belongs_to :provider, param: :provider_code
  has_many :site_statuses
  has_many :sites, through: :site_statuses, source: :site

  def full_time?
    study_mode == 'full time'
  end

  def part_time?
    study_mode == 'part time'
  end
end
