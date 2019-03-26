class VacancyStatusDeterminationService
  def call(vac_status_full_time: 0, vac_status_part_time: 0, course:)
    if @course.full_time_or_part_time?
      if vac_status_full_time == '0' && vac_status_part_time == '1'
        return 'part_time_vacancies'
      elsif vac_status_full_time == '1' && vac_status_part_time == '0'
        return 'full_time_vacancies'
      elsif vac_status_full_time == '1' && vac_status_part_time == '1'
        return 'both_full_time_and_part_time_vacancies'
      end
    elsif @course.full_time?
      return 'full_time_vacancies' if vac_status_full_time == '0'
      'no_vacancies'
    elsif @course.part_time?
      return 'part_time_vacancies' if vac_status_part_time == '0'
    end

    'no_vacancies'
  end
end
