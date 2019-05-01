class Provider < Base
  has_many :courses, param: :course_code
  has_many :sites

  self.primary_key = :provider_code

  def course_count
    relationships.courses[:meta][:count]
  end
end
