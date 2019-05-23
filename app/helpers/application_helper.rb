module ApplicationHelper
  def markdown(source)
    render = Govuk::MarkdownRenderer
    markdown = Redcarpet::Markdown.new(render)
    markdown.render(source).html_safe
  end
end
