class SiteStatus < Base
  def full_time_vacancies?
    vac_status == 'full_time_vacancies'
  end

  def part_time_vacancies?
    vac_status == 'part_time_vacancies'
  end
end
