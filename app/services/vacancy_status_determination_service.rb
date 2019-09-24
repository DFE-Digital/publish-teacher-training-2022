class VacancyStatusDeterminationService
  attr_reader :vacancy_status_full_time,
              :vacancy_status_part_time,
              :course

  def self.call(vacancy_status_full_time:, vacancy_status_part_time:, course:)
    new(
      vacancy_status_full_time: vacancy_status_full_time,
      vacancy_status_part_time: vacancy_status_part_time,
      course:                   course,
    ).call
  end

  def initialize(vacancy_status_full_time:, vacancy_status_part_time:, course:)
    @vacancy_status_full_time = vacancy_status_full_time
    @vacancy_status_part_time = vacancy_status_part_time
    @course                   = course
  end

  def call
    vacancy_status = if course.full_time_or_part_time?
                       if vacancy_status_full_time? && vacancy_status_part_time?
                         "both_full_time_and_part_time_vacancies"
                       elsif vacancy_status_full_time?
                         "full_time_vacancies"
                       elsif vacancy_status_part_time?
                         "part_time_vacancies"
                       end
                     elsif course.full_time? && vacancy_status_full_time?
                       "full_time_vacancies"
                     elsif course.part_time? && vacancy_status_part_time?
                       "part_time_vacancies"
                     end

    vacancy_status || "no_vacancies"
  end

private

  def vacancy_status_full_time?
    vacancy_status_full_time == "1"
  end

  def vacancy_status_part_time?
    vacancy_status_part_time == "1"
  end
end
