class ProviderReferencesForm
  include ActiveModel::Model

  FIELDS = %w[ukprn urn].freeze

  attr_accessor(*FIELDS)
  attr_reader :provider

  validates :ukprn, length: { is: 8, message: "UKPRN must be 8 numbers" }
  validates :urn, length: { minimum: 5, maximum: 6, message: "URN must be 5 or 6 numbers" }, if: :lead_school?

  def initialize(provider, params: {})
    @provider = provider
    super(provider.attributes.slice(*FIELDS).merge(params))
  end

  def save
    provider.update(instance_values.slice(*FIELDS).compact) if valid?
  end

  def lead_school?
    provider&.provider_type == "lead_school"
  end
end
