class Provider < Base
  has_many :courses
  has_many :sites

  def course_count
    relationships.courses[:meta][:count]
  end
end
