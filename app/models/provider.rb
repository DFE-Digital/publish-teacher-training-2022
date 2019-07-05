class Provider < Base
  has_many :courses, param: :course_code
  has_many :sites

  self.primary_key = :provider_code

  def course_count
    relationships.courses[:meta][:count]
  end

  def full_address
    [address1, address2, address3, address4, postcode].select(&:present?).join("<br> ").html_safe
  end

  def rolled_over?
    Settings.rollover
  end
end
