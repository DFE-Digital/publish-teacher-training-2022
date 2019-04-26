class CourseDecorator < ApplicationDecorator
  delegate_all

  def formatted_last_published_at
    object.last_published_at&.to_date&.strftime("%-d %B %Y")
  end
end
