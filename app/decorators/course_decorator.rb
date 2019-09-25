class CourseDecorator < ApplicationDecorator
  delegate_all

  def name_and_code
    "#{object.name} (#{object.course_code})"
  end

  def vacancies
    content = object.has_vacancies? ? "Yes" : "No"
    content += " (" + edit_vacancy_link + ")"
    content.html_safe
  end

  def on_find(provider = object.provider)
    if object.findable?
      if current_cycle?
        h.govuk_link_to("Yes - view online", h.search_ui_course_page_url(provider_code: provider.provider_code, course_code: object.course_code))
      elsif next_cycle?
        "Yes – from October"
      end
    else
      not_on_find
    end
  end

  def open_or_closed_for_applications
    object.open_for_applications? ? "Open" : "Closed"
  end

  def outcome
    I18n.t("edit_options.qualifications.#{object.qualification}.label")
  end

  def is_send?
    object.is_send? ? "Yes" : "No"
  end

  def funding
    case object.funding_type
    when "salary"
      "Salaried"
    when "apprenticeship"
      "Teaching apprenticeship (with salary)"
    when "fee"
      "Fee paying (no salary)"
    end
  end

  def apprenticeship?
    object.funding_type == "apprenticeship" ? "Yes" : "No"
  end

  def sorted_subjects
    object.subjects.sort.join("<br>").html_safe
  end

  def length
    case object.course_length
    when "OneYear"
      "1 year"
    when "TwoYears"
      "Up to 2 years"
    else
      object.course_length
    end
  end

  def other_course_length?
    %w[OneYear TwoYears].exclude?(course.course_length)
  end

  def other_age_range?
    options = object.meta["edit_options"]["age_range_in_years"]
    options.exclude?(course.age_range_in_years)
  end

  def ucas_status
    case object.ucas_status
    when "running"
      "Running"
    when "new"
      "New – not yet running"
    when "not_running"
      "Not running"
    end
  end

  def alphabetically_sorted_sites
    object.sites.sort_by(&:location_name)
  end

  def preview_site_statuses
    site_statuses.select(&:new_or_running?).sort_by { |status| status.site.location_name }
  end

  def has_site?(site)
    object.sites.include?(site)
  end

  def funding_option
    if object.funding_type == "salary"
      "Salary"
    elsif object.has_scholarship_and_bursary?
      "Scholarship, bursary or student finance if you’re eligible"
    elsif object.has_bursary?
      "Bursary or student finance if you’re eligible";
    else
      "Student finance if you’re eligible"
    end
  end

  def current_cycle?
    course.recruitment_cycle_year.to_i == Settings.current_cycle
  end

  def next_cycle?
    course.recruitment_cycle_year.to_i == Settings.current_cycle + 1
  end

  def age_range
    if object.age_range_in_years.present?
      I18n.t("edit_options.age_range_in_years.#{object.age_range_in_years}.label", default: object.age_range_in_years.humanize)
    else
      "<span class='app-course-parts__fields__value--empty'>Unknown</span>".html_safe
    end
  end

  def applications_open_from_message_for(recruitment_cycle)
    is_current_recruitment_cycle = recruitment_cycle.year == Settings.current_cycle.to_s
    if is_current_recruitment_cycle
      "As soon as the course is on Find (recommended)"
    else
      year = recruitment_cycle.year.to_i
      day_month = Date.parse(recruitment_cycle.application_start_date).strftime("%-d %B")
      "On #{day_month} when applications for the #{year} – #{year + 1} cycle open"
    end
  end

private

  def not_on_find
    if object.new_and_not_running?
      "No – still in draft"
    else
      "No"
    end
  end

  def edit_vacancy_link
    h.link_to("Edit", h.vacancies_provider_recruitment_cycle_course_path(provider_code: object.provider_code, recruitment_cycle_year: object.recruitment_cycle_year, code: object.course_code), class: "govuk-link")
  end
end
