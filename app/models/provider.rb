class Provider < Base
  has_many :courses

  def course_count
    relationships.courses[:meta][:count]
  end
end
