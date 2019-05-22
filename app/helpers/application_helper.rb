module ApplicationHelper
  def markdown(source)
    markdown = RDiscount.new(source)
    markdown.to_html.html_safe
  end
end
