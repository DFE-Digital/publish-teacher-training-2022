class Provider < Base
  has_many :courses, param: :provider_code
  has_many :sites

  def course_count
    courses.count
  end
end
