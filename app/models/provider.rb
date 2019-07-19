class Provider < Base
  belongs_to :recruitment_cycle, param: :year
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

  def has_unpublished_changes?
    content_status == "published_with_unpublished_changes"
  end

  def is_published?
    content_status == 'published'
  end
end
