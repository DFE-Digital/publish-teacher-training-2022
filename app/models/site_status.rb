class SiteStatus < Base
  def full_time_vacancies?
    vac_status == 'full_time_vacancies'
  end

  def part_time_vacancies?
    vac_status == 'part_time_vacancies'
  end

  def full_time_and_part_time_vacancies?
    vac_status == 'both_full_time_and_part_time_vacancies'
  end

  def running?
    status == 'running'
  end

  def new_or_running?
    status.in?(%w[running new_status])
  end
end
