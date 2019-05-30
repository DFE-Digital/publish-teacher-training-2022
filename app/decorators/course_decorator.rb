class CourseDecorator < ApplicationDecorator
  delegate_all

  def name_and_code
    "#{object.name} (#{object.course_code})"
  end

  def vacancies
    content = object.has_vacancies? ? 'Yes' : 'No'
    content += " (" + edit_vacancy_link + ")"
    content.html_safe
  end

  def on_find(provider = object.provider)
    if object.findable?
      h.govuk_link_to("Yes - view online", h.search_ui_course_page_url(provider_code: provider.provider_code, course_code: object.course_code))
    else
      not_on_find
    end
  end

  def open_or_closed_for_applications
    object.open_for_applications? ? 'Open' : 'Closed'
  end

  def outcome
    object.qualifications.sort.map(&:upcase).join(' with ')
  end

  def is_send?
    object.is_send? ? 'Yes' : 'No'
  end

  def funding
    case object.funding
    when 'salary'
      'Salaried'
    when 'apprenticeship'
      'Teaching apprenticeship (with salary)'
    when 'fee'
      'Fee paying (no salary)'
    end
  end

  def apprenticeship?
    object.funding == 'apprenticeship' ? 'Yes' : 'No'
  end

  def sorted_subjects
    object.subjects.sort.join("<br>").html_safe
  end

  def status_tag
    tag = h.content_tag(:div, status_tag_content.html_safe, class: "govuk-tag phase-tag--small #{status_tag_css_class}")
    tag += unpublished_status_hint if object.has_unpublished_changes?
    tag.html_safe
  end

  def length
    case object.course_length
    when 'OneYear'
      '1 year'
    when 'TwoYears'
      'Up to 2 years'
    else
      object.course_length
    end
  end

  def ucas_status
    case object.ucas_status
    when 'running'
      'Running'
    when 'new'
      'New – not yet running'
    when 'not_running'
      'Not running'
    end
  end

  def alphabetically_sorted_site_statuses
    object.site_statuses.sort_by { |ss| ss.site.location_name }
  end

  def has_site?(site)
    object.site_statuses.map(&:site).include?(site)
  end

  def funding_option
    if object.funding == 'salary'
      "Salary"
    elsif object.has_scholarship_and_bursary?
      "Scholarship, bursary or student finance if you’re eligible"
    elsif object.has_bursary?
      "Bursary or student finance if you’re eligible";
    else
      "Student finance if you’re eligible"
    end
  end

private

  def status_tag_content
    case object.content_status
    when 'published'
      'Published'
    when 'empty'
      'Empty'
    when 'draft'
      'Draft'
    when 'published_with_unpublished_changes'
      'Published&nbsp;*'
    end
  end

  def status_tag_css_class
    case course.content_status
    when 'published'
      'phase-tag--published'
    when 'empty'
      'phase-tag--no-content'
    when 'draft'
      'phase-tag--draft'
    when 'published_with_unpublished_changes'
      'phase-tag--published'
    end
  end

  def unpublished_status_hint
    h.content_tag(:div, '*&nbsp;Unpublished&nbsp;changes'.html_safe, class: 'govuk-body govuk-body-s govuk-!-margin-bottom-0 govuk-!-margin-top-1')
  end

  def not_on_find
    if object.new_and_not_running?
      'No – still in draft'
    else
      'No'
    end
  end

  def edit_vacancy_link
    h.link_to('Edit', h.vacancies_provider_course_path(code: object.course_code), class: 'govuk-link')
  end
end
