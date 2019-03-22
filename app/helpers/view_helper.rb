module ViewHelper
  def manage_ui_link_to(body, url, html_options = { class: 'govuk-link' })
    link_to body, "#{Settings.manage_ui.base_url}#{url}", html_options
  end

  def manage_ui_link_to_back(url)
    manage_ui_link_to('Back', url, class: "govuk-back-link")
  end

  # Get this working
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

  def vac_status_checkboxes(form, course, site_status)
    if course.study_mode == 'full_time_or_part_time'
      (content_tag :div, class: 'govuk-checkboxes__item' do
          concat(
            form.check_box('vac_status_part_time', checked: are_vacancies_available_for_course_site_status?(course, site_status), class: 'govuk-checkboxes__input') +
            form.label(:vac_status, "#{site_status.site.location_name} (Part time)", class: 'govuk-label govuk-checkboxes__label')
          )
        end) +
      (content_tag :div, class: 'govuk-checkboxes__item' do
        concat(
          form.check_box('vac_status_full_time', checked: are_vacancies_available_for_course_site_status?(course, site_status), class: 'govuk-checkboxes__input') +
          form.label(:vac_status, "#{site_status.site.location_name} (Full time)", class: 'govuk-label govuk-checkboxes__label')
        )
      end)
    elsif course.study_mode == 'full_time'
      content_tag :div, class: 'govuk-checkboxes__item' do
        concat(
          form.check_box(:vac_status, checked: are_vacancies_available_for_course_site_status?(course, site_status), class: 'govuk-checkboxes__input') +
          form.label(:vac_status, "#{site_status.site.location_name} (Full time)", class: 'govuk-label govuk-checkboxes__label')
        )
      end
    elsif course.study_mode == 'part_time'
      content_tag :div, class: 'govuk-checkboxes__item' do
        concat(
          form.check_box(:vac_status, checked: are_vacancies_available_for_course_site_status?(course, site_status), class: 'govuk-checkboxes__input') +
          form.label(:vac_status, "#{site_status.site.location_name} (Part time)", class: 'govuk-label govuk-checkboxes__label')
        )
      end
    else
      "foo"
    end
  end
end
