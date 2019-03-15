module ViewHelper
  def manage_ui_link_to(body, url, html_options = { class: 'govuk-link' })
    link_to body, "#{Settings.manage_ui.base_url}#{url}", html_options
  end

  def are_vacancies_available_for_course_site_status?(course, site_status)
    case course.study_mode
    when 'full_time'
      site_status.full_time_vacancies?
    when 'part_time'
      site_status.part_time_vacancies?
    when 'full_time_or_part_time'
      site_status.full_time_vacancies? && site_status.part_time_vacancies?
    end
  end

  def site_name_with_vac_status(site_status)
    if site_status.vac_status.present?
      site_status.site.location_name + ' (' + site_status.vac_status.humanize.gsub(' vacancies', '') + ')'
    else
      site_status.site.location_name
    end
  end
end
