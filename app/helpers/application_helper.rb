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

    # Convert quotes to smart quotes
    source_with_smart_quotes = smart_quotes(source)
    markdown.render(source_with_smart_quotes).html_safe
  end

  def smart_quotes(string)
    return "" if string.blank?

    RubyPants.new(string, [2, :dashes], ruby_pants_options).to_html
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
    govuk_link_to(error, href, class: "govuk-!-display-block")
  end

  def enrichment_summary(model, key, value, fields, truncate_value: true)
    classes = truncate_value ? "app-summary-list__row--truncate" : "app-summary-list__row"

    if fields.select { |field| @errors&.key? field.to_sym }.any?
      errors = fields.map { |field|
        @errors[field.to_sym]&.map { |error| enrichment_error_link(model, field, error) }
      }.flatten

      key = [key, *errors].reduce(:+)
      classes += " app-summary-list__row--error"
    end

    if value.blank?
      value = raw("<span class=\"app-!-colour-muted\">Empty</span>")
    end

    {
      key: key.html_safe,
      value: value,
      classes: classes,
      html_attributes: {
        data: {
          qa: "enrichment__#{fields.first}",
        },
      },
    }
  end

private

  # Use characters rather than HTML entities for smart quotes this matches how
  # we write smart quotes in templates and allows us to use them in <title>
  # elements
  # https://github.com/jmcnevin/rubypants/blob/master/lib/rubypants.rb
  def ruby_pants_options
    {
      double_left_quote: "“",
      double_right_quote: "”",
      single_left_quote: "‘",
      single_right_quote: "’",
      ellipsis: "…",
      em_dash: "—",
      en_dash: "–",
    }
  end
end
