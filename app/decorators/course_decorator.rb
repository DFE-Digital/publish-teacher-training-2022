class CourseDecorator < ApplicationDecorator
  delegate_all

  def last_published_at
    object&.last_published_at&.to_date&.strftime("%-d %B %Y")
  end
end
