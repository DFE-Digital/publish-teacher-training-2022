class CourseDecorator < ApplicationDecorator
  delegate_all

  def name_and_code
    "#{object.name} (#{object.course_code})"
  end

  def vacancies
    content = object.has_vacancies? ? "Yes" : "No"
    content += " (" + edit_vacancy_link + ")" unless object.is_withdrawn?
    content.html_safe
  end

  def on_find(provider = object.provider)
    if object.findable?
      if current_cycle_and_open?
        h.govuk_link_to("Yes - view online", h.search_ui_course_page_url(provider_code: provider.provider_code, course_code: object.course_code))
      else
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

  def subject_name
    if object.subjects.count == 1
      object.subjects.first.subject_name
    else
      object.name
    end
  end

  def has_scholarship_and_bursary?
    has_bursary? && has_scholarship?
  end

  def bursary_first_line_ending
    if bursary_requirements.count > 1
      ":"
    else
      "#{bursary_requirements.first}."
    end
  end

  def bursary_requirements
    requirements = ["a degree of 2:2 or above in any subject"]

    if object.subjects.any? { |subject| subject.subject_name.downcase == "primary with mathematics" }
      mathematics_requirement = "at least grade B in maths A-level (or an equivalent)"
      requirements.push(mathematics_requirement)
    end

    requirements
  end

  def bursary_only?
    has_bursary? && !has_scholarship?
  end

  def has_bursary?
    object.subjects.present? &&
      object.subjects.any? { |subject| subject.attributes["bursary_amount"].present? }
  end

  def excluded_from_bursary?
    object.subjects.present? &&
      # incorrect bursary eligibility only shows up on courses with 2 subjects
      object.subjects.count == 2 &&
      has_excluded_course_name?
  end

  def has_scholarship?
    object.subjects.present? &&
      object.subjects.any? { |subject| subject.attributes["scholarship"].present? }
  end

  def has_early_career_payments?
    object.subjects.present? &&
      object.subjects.any? { |subject| subject.attributes["early_career_payments"].present? }
  end

  def bursary_amount
    find_max("bursary_amount")
  end

  def scholarship_amount
    find_max("scholarship")
  end

  def salaried?
    object.funding_type == "salary"
  end

  def apprenticeship?
    object.funding_type == "apprenticeship" ? "Yes" : "No"
  end

  def sorted_subjects
    object.subjects.map(&:subject_name).sort.join("<br>").html_safe
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
    !course.sites.nil? && object.sites.any? { |s| s.id == site.id }
  end

  def funding_option
    if object.funding_type == "salary"
      "Salary"
    elsif excluded_from_bursary?
      "Student finance if you’re eligible"
    elsif has_scholarship_and_bursary?
      "Scholarship, bursary or student finance if you’re eligible"
    elsif has_bursary?
      "Bursary or student finance if you’re eligible"
    else
      "Student finance if you’re eligible"
    end
  end

  def current_cycle?
    course.recruitment_cycle_year.to_i == Settings.current_cycle
  end

  def current_cycle_and_open?
    current_cycle? && Settings.current_cycle_open
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
    if current_cycle?
      "As soon as the course is on Find (recommended)"
    else
      year = recruitment_cycle.year.to_i
      day_month = Date.parse(recruitment_cycle.application_start_date).strftime("%-d %B")
      "On #{day_month} when applications for the #{year} – #{year + 1} cycle open"
    end
  end

  def selectable_master_subjects
    meta["edit_options"]["subjects"].map { |subject| [subject["attributes"]["subject_name"], subject["id"]] }
  end

  def selectable_subordinate_subjects
    selectable_master_subjects + [%w[None None]]
  end

  def subject_present?(subject_to_find)
    subjects.map { |subject| subject["id"] }.include?(subject_to_find["id"])
  end

private

  def not_on_find
    if object.new_and_not_running?
      "No – still in draft"
    elsif object.is_withdrawn?
      "No – withdrawn"
    else
      "No"
    end
  end

  def edit_vacancy_link
    h.link_to("Edit", h.vacancies_provider_recruitment_cycle_course_path(provider_code: object.provider_code, recruitment_cycle_year: object.recruitment_cycle_year, code: object.course_code), class: "govuk-link")
  end

  def find_max(attribute)
    subject_attributes = object.subjects.map do |s|
      if s.attributes[attribute].present?
        s.__send__(attribute).to_i
      end
    end

    subject_attributes.compact.max.to_s
  end

  def has_excluded_course_name?
    exclusions = [
      /^Drama/,
      /^Media Studies/,
      /^PE/,
      /^Physical/,
    ]
    # We only care about course with a name matching the pattern 'Foo with bar'
    # We don't care about courses matching the pattern 'Foo and bar'
    return false unless /with/.match?(object.name)

    exclusions.any? { |e| e.match?(object.name) }
  end
end
