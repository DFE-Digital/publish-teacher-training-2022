module CourseHelper
  def course_summary_label(key)
    content_tag :dt, key, class: 'govuk-summary-list__key'
  end

  def course_summary_value(value, data)
    css_class = 'govuk-summary-list__value govuk-summary-list__value--truncate'

    if value.blank?
      value = 'Empty'
      css_class += ' course-parts__fields__value--empty'
    end

    content_tag :dd, value, class: css_class, data: { qa: "course__#{data}" }
  end

  def course_summary_item(key, value, data)
    content_tag :div, class: 'govuk-summary-list__row' do
      course_summary_label(key) + course_summary_value(value, data)
    end
  end
end
