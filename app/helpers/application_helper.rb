module ApplicationHelper
  def formatted_date(iso8601_date)
    iso8601_date.to_date.strftime("%-d %B %Y")
  end
end
