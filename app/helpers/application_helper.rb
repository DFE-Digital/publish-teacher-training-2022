module ApplicationHelper
  def markdown(source)
    render = Govuk::MarkdownRenderer
    options = { autolink: true, lax_spacing: true }
    markdown = Redcarpet::Markdown.new(render, options)
    markdown.render(source).html_safe
  end
end
