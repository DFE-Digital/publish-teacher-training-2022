module ViewHelper
  def manage_ui_link_to(body, url, html_options = { class: 'govuk-link' })
    link_to body, "#{Settings.manage_ui.base_url}#{url}", html_options
  end

  def manage_ui_link_to_back(url)
    manage_ui_link_to('Back', url, class: "govuk-back-link")
  end

  def are_vacancies_available_for_course_site_status?(course, site_status, vacancy_study_mode = nil)
    case course.study_mode
    when 'full_time'
      site_status.full_time_vacancies?
    when 'part_time'
      site_status.part_time_vacancies?
    when 'full_time_or_part_time'
      if vacancy_study_mode == :part_time && site_status.part_time_vacancies?
        true
      elsif vacancy_study_mode == :full_time && site_status.full_time_vacancies?
        true
      elsif site_status.full_time_and_part_time_vacancies?
        true
      else
        false
      end
    end
  end
end
