class Provider < Base
  def course_count
    relationships.courses[:meta][:count]
  end
end
