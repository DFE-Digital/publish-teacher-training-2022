class RecruitmentCycle < Base
  def initialize(cycle_year)
    @cycle_year = cycle_year.to_i
    @current_cycle_year = Settings.current_cycle
    @next_cycle_year = Settings.current_cycle + 1
  end

  def current?
    @cycle_year == @current_cycle_year
  end

  def next?
    @cycle_year == @next_cycle_year
  end

  def year_range
    "#{@cycle_year} – #{@cycle_year + 1}"
  end

  def title
    if current?
      "Current cycle (#{year_range})"
    elsif next?
      "Next cycle (#{year_range})"
    else
      year_range
    end
  end
end
