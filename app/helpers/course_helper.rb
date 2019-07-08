module CourseHelper
  def course_manage_error_link(field, error)
    content_tag :a, error,
                class: 'govuk-link govuk-!-display-block',
                href: enrichment_error_url(
                  provider_code: @provider.provider_code,
                  course: @course,
                  field: field.to_s
                )
  end

  def course_summary_label(key, field)
    if @errors&.key? field
      content_tag :dt, class: 'govuk-summary-list__key app-course-parts__fields__label--error' do
        [
          content_tag(:span, key),
          *@errors[field].map { |error| course_manage_error_link(field, error) }
        ].reduce(:+)
      end
    else
      content_tag :dt, key, class: 'govuk-summary-list__key'
    end
  end

  def course_summary_value(value, field)
    css_class = 'govuk-summary-list__value govuk-summary-list__value--truncate'

    if value.blank?
      value = 'Empty'
      css_class += ' course-parts__fields__value--empty'
    end

    content_tag :dd, value, class: css_class, data: { qa: "course__#{field}" }
  end

  def course_summary_item(key, value, field)
    content_tag :div, class: 'govuk-summary-list__row' do
      course_summary_label(key, field) + course_summary_value(value, field)
    end
  end
end
