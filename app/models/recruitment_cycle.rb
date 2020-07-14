class RecruitmentCycle < Base
  has_many :providers
  has_many :courses, through: :providers
  has_many :sites, through: :providers

  self.primary_key = :year

  def self.current
    RecruitmentCycle.includes(:providers).find(Settings.current_cycle).first
  end

  def current?
    year.to_i == Settings.current_cycle
  end

  def current_and_open?
    current? && FeatureService.enabled?("rollover.has_current_cycle_started?")
  end

  def next?
    year.to_i == Settings.current_cycle + 1
  end

  def year_range
    "#{year} to #{year.to_i + 1}"
  end

  def title
    if current_and_open?
      "Current cycle (#{year_range})"
    elsif current?
      "New cycle (#{year_range})"
    elsif next?
      "Next cycle (#{year_range})"
    else
      year_range
    end
  end
end
