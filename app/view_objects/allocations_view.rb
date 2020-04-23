class AllocationsView
  module Status
    REQUESTED = "REQUESTED".freeze
    NOT_REQUESTED = "NOT REQUESTED".freeze
    YET_TO_REQUEST = "YET TO REQUEST".freeze
  end

  module Colour
    GREEN = "green".freeze
    RED = "red".freeze
    GREY = "grey".freeze
  end

  def initialize(training_providers:, allocations:)
    @training_providers = training_providers
    @allocations = allocations
  end

  def allocation_statuses
    @training_providers.map do |training_provider|
      allocation_view = {
        provider_name: training_provider.provider_name,
        provider_code: training_provider.provider_code,
      }
      matching_allocation = @allocations.select do |allocation|
        allocation.provider_id == training_provider.id
      end.first

      if matching_allocation.nil?
        allocation_view[:status] = Status::YET_TO_REQUEST
        allocation_view[:status_colour] = Colour::GREY
      end

      if matching_allocation && matching_allocation[:number_of_places] >= 1
        allocation_view[:status] = Status::REQUESTED
        allocation_view[:status_colour] = Colour::GREEN
      end

      if matching_allocation && matching_allocation[:number_of_places].zero?
        allocation_view[:status] = Status::NOT_REQUESTED
        allocation_view[:status_colour] = Colour::RED
      end

      allocation_view
    end
  end
end
