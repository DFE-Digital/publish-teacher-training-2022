module ApplicationHelper
  def markdown(source)
    options = {
      filter_html:     true,
      link_attributes: { rel: 'nofollow', target: "_blank", class: "govuk-link" },
    }

    extensions = {
      lax_spacing: true
    }

    renderer = Redcarpet::Render::HTML.new(options)
    markdown = Redcarpet::Markdown.new(renderer, extensions)

    markdown.render(source).html_safe
  end
end
