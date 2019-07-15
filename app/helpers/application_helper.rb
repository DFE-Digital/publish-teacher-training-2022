module ApplicationHelper
  def markdown(source)
    render = Govuk::MarkdownRenderer
    # Options: https://github.com/vmg/redcarpet#and-its-like-really-simple-to-use
    # lax_spacing: HTML blocks do not require to be surrounded by an empty line as in the Markdown standard.
    # autolink: parse links even when they are not enclosed in <> characters
    options = { autolink: true, lax_spacing: true }
    markdown = Redcarpet::Markdown.new(render, options)
    markdown.render(source).html_safe
  end

  def course_enrichment_error_link(field, error)
    content_tag :a, error,
                class: 'govuk-link govuk-!-display-block',
                href: enrichment_error_url(
                  provider_code: @provider.provider_code,
                  course: @course,
                  field: field.to_s
                )
  end

  def enrichment_summary_label(key, field)
    if @errors&.key? field
      content_tag :dt, class: 'govuk-summary-list__key app-course-parts__fields__label--error' do
        [
          content_tag(:span, key),
          *@errors[field].map { |error| course_enrichment_error_link(field, error) }
        ].reduce(:+)
      end
    else
      content_tag :dt, key, class: 'govuk-summary-list__key'
    end
  end

  def enrichment_summary_value(value, field)
    css_class = 'govuk-summary-list__value govuk-summary-list__value--truncate'

    if value.blank?
      value = 'Empty'
      css_class += ' app-course-parts__fields__value--empty'
    end

    content_tag :dd, value, class: css_class, data: { qa: "enrichment__#{field}" }
  end

  def enrichment_summary_item(key, value, field)
    content_tag :div, class: 'govuk-summary-list__row' do
      enrichment_summary_label(key, field) + enrichment_summary_value(value, field)
    end
  end
end
