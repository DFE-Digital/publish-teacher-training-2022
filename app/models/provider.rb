class Provider < Base
  has_many :courses, param: :provider_code

  def course_count
    courses.count
  end
end
