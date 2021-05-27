class Provider < Base
  belongs_to :recruitment_cycle, param: :recruitment_cycle_year
  has_many :users
  has_many :courses, param: :course_code
  has_many :sites
  has_one :allocation
  has_many :training_providers
  has_many :contacts

  self.primary_key = :provider_code

  custom_endpoint :show_any, on: :member, request_method: :get

  def publish
    post_request("/publish")
  end

  def publishable?
    post_request("/publishable")
  end

  def course_count
    relationships.courses[:meta][:count]
  end

  def full_address
    [address1, address2, address3, address4, postcode].map { |line| ERB::Util.html_escape(line) }.select(&:present?).join("<br> ").html_safe
  end

  def rolled_over?
    FeatureService.enabled?("rollover.can_edit_current_and_next_cycles")
  end

  def from_previous_recruitment_cycle
    Provider.where(recruitment_cycle_year: recruitment_cycle_year.to_i.pred)
      .find(provider_code)
      .first
  end

private

  def post_base_url
    sprintf("#{Provider.site}#{Provider.path}/%<provider_code>s", path_attributes)
  end
end
