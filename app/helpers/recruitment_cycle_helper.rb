module RecruitmentCycleHelper
  def rollover?
    Settings.rollover
  end

  def current_cycle?
    cycle_year == Settings.current_cycle
  end

  def next_cycle?
    cycle_year == Settings.current_cycle + 1
  end

  def recruitment_cycle_title
    year_range = "#{cycle_year} – #{cycle_year + 1}"

    if current_cycle?
      "Current cycle (#{year_range})"
    elsif next_cycle?
      "Next cycle (#{year_range})"
    else
      year_range
    end
  end

private

  def cycle_year
    params[:recruitment_cycle_year].to_i
  end
end
