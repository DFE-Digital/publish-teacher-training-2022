class Provider < Base
  belongs_to :recruitment_cycle, param: :recruitment_cycle_year
  has_many :courses, param: :course_code
  has_many :sites

  self.primary_key = :provider_code

  def publish
    post_request('/publish')
  end

  def publishable?
    post_request('/publishable')
  end

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

private

  def post_base_url
    "#{Provider.site}#{Provider.path}/%<provider_code>s" % path_attributes
  end
end
