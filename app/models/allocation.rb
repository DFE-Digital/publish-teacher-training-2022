class Allocation < Base
  module RequestTypes
    INITIAL = "initial".freeze
    REPEAT = "repeat".freeze
    DECLINED = "declined".freeze
  end

  def self.journey_mode
    {
      "open" => "open",
      "closed" => "closed",
      "confirmed" => "confirmed",
    }.fetch(Settings.features.allocations.state, "open")
  end

  belongs_to :provider, param: :provider_code, shallow_path: true # accredited_body
  has_one :allocation_uplift

  property :number_of_places
  property :confirmed_number_of_places
  property :request_type

  validate :selected_number_of_places, if: :initial_request?

  def self.for_provider_and_training_provider(recruitment_cycle:, provider:, training_provider:)
    Allocation.where(recruitment_cycle_year: recruitment_cycle.year)
              .where(provider_code: provider.provider_code)
              .where(training_provider_code: training_provider.provider_code)
              .first
  end

  def selected_number_of_places
    return if number_of_places.nil?

    errors.add(:number_of_places, "You must enter a number") unless number_of_places_valid?
  end

  def has_places?
    number_of_places.to_i.positive?
  end

  def repeat_request?
    request_type == Allocation::RequestTypes::REPEAT
  end

  def initial_request?
    request_type == Allocation::RequestTypes::INITIAL
  end

private

  def number_of_places_valid?
    !number_of_places.to_s.empty? &&
      /\A\d+\z/.match?(number_of_places.to_s) &&
      number_of_places.to_i.positive?
  end
end
