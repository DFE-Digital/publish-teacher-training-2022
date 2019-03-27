module VacancyHelper
  # TODO: Refactor this, consider moving elsewhere.
  def are_vacancies_available_for_course_site_status?(course, site_status, vacancy_study_mode = nil)
    if course.full_time? && site_status.full_time_vacancies?
      true
    elsif course.part_time? && site_status.part_time_vacancies?
      true
    elsif course.full_time_or_part_time?
      if vacancy_study_mode == :part_time && site_status.part_time_vacancies?
        true
      elsif vacancy_study_mode == :full_time && site_status.full_time_vacancies?
        true
      elsif site_status.full_time_and_part_time_vacancies?
        true
      else
        false
      end
    else
      false
    end
  end
end
