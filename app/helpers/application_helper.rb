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
               message: error,
             )
           when :provider
             provider_enrichment_error_url(
               provider: @provider,
               field: field.to_s,
             )
           end

    govuk_inset_text(classes: "app-inset-text--narrow-border app-inset-text--error") do
      govuk_link_to(error, href)
    end
  end

  def enrichment_summary(summary_list, model, key, value, fields, truncate_value: true, action_path: nil, action_visually_hidden_text: nil)
    action = render_action(action_path, action_visually_hidden_text)

    if fields.select { |field| @errors&.key? field.to_sym }.any?
      errors = fields.map { |field|
        @errors[field.to_sym]&.map { |error| enrichment_error_link(model, field, error) }
      }.flatten

      value = raw(*errors)
      action = nil
    elsif truncate_value
      classes = "app-summary-list__value--truncate"
    end

    if value.blank?
      value = raw("<span class=\"app-!-colour-muted\">Empty</span>")
    end

    summary_list.row(html_attributes: { data: { qa: "enrichment__#{fields.first}" } }) do |row|
      row.key { key.html_safe }
      row.value(classes: classes) { value }
      if action
        row.action(action)
      else
        row.action
      end
    end
  end

private

  def render_action(action_path, action_visually_hidden_text)
    return if action_path.blank?

    {
      href: action_path,
      visually_hidden_text: action_visually_hidden_text,
    }
  end

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
