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

  CHANGES_INTRODUCED_IN_2022_CYCLE = 2022

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

  def declared_visa_sponsorship?
    !can_sponsor_student_visa.nil? && !can_sponsor_skilled_worker_visa.nil?
  end

  def can_sponsor_all_visas?
    can_sponsor_student_visa && can_sponsor_skilled_worker_visa
  end

  def can_only_sponsor_student_visa?
    can_sponsor_student_visa && !can_sponsor_skilled_worker_visa
  end

  def can_only_sponsor_skilled_worker_visa?
    !can_sponsor_student_visa && can_sponsor_skilled_worker_visa
  end

private

  def post_base_url
    sprintf("#{Provider.site}#{Provider.path}/%<provider_code>s", path_attributes)
  end
end
