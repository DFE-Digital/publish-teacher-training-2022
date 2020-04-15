module ApplicationHelper
  include Pagy::Frontend

  def pagy_govuk_nav(pagy)
    render "pagy/paginator", pagy: pagy
  end

  def markdown(source)
    render = Govuk::MarkdownRenderer
    # Options: https://github.com/vmg/redcarpet#and-its-like-really-simple-to-use
    # lax_spacing: HTML blocks do not require to be surrounded by an empty line as in the Markdown standard.
    # autolink: parse links even when they are not enclosed in <> characters
    options = { autolink: true, lax_spacing: true }
    markdown = Redcarpet::Markdown.new(render, options)
    markdown.render(source).html_safe
  end

  def enrichment_error_link(model, field, error)
    href = case model
           when :course
             enrichment_error_url(
               provider_code: @provider.provider_code,
               course: @course,
               field: field.to_s,
             )
           when :provider
             provider_enrichment_error_url(
               provider: @provider,
               field: field.to_s,
             )
           end
    content_tag :a, error,
                class: "govuk-link govuk-!-display-block",
                href: href
  end

  def enrichment_summary_label(model, key, fields)
    if fields.select { |field| @errors&.key? field }.any?
      errors = fields.map { |field|
        @errors[field]&.map { |error| enrichment_error_link(model, field, error) }
      }.flatten
      content_tag :dt, class: "govuk-summary-list__key app-course-parts__fields__label--error" do
        [
          content_tag(:span, key),
          *errors,
        ].reduce(:+)
      end
    else
      content_tag :dt, key, class: "govuk-summary-list__key"
    end
  end

  def enrichment_summary_value(value, fields)
    css_class = "govuk-summary-list__value govuk-summary-list__value--truncate"

    if value.blank?
      value = "Empty"
      css_class += " app-course-parts__fields__value--empty"
    end

    data_qa = "enrichment__#{fields.first}"
    content_tag :dd, value, class: css_class, data: { qa: data_qa }
  end

  def enrichment_summary_item(model, key, value, fields)
    content_tag :div, class: "govuk-summary-list__row" do
      enrichment_summary_label(model, key, fields) + enrichment_summary_value(value, fields)
    end
  end
end
