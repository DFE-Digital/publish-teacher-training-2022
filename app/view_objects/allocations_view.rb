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

  module Requested
    YES = "yes".freeze
    NO = "no".freeze
  end

  def initialize(training_providers:, allocations:)
    @training_providers = training_providers
    @allocations = allocations
  end

  def allocation_statuses
    @training_providers.map do |training_provider|
      matching_allocation = find_matching_allocation(training_provider)
      build_allocation_status(matching_allocation, training_provider)
    end
  end

private

  def find_matching_allocation(training_provider)
    @allocations.find do |allocation|
      allocation.provider.id == training_provider.id.to_s
    end
  end

  def build_allocation_status(matching_allocation, training_provider)
    allocation_status = {
      training_provider_name: training_provider.provider_name,
      training_provider_code: training_provider.provider_code,
    }

    if matching_allocation.nil?
      allocation_status[:status] = Status::YET_TO_REQUEST
      allocation_status[:status_colour] = Colour::GREY
    end

    if matching_allocation && matching_allocation[:number_of_places] >= 1
      allocation_status[:status] = Status::REQUESTED
      allocation_status[:status_colour] = Colour::GREEN
      allocation_status[:requested] = Requested::YES
    end

    if matching_allocation && matching_allocation[:number_of_places].zero?
      allocation_status[:status] = Status::NOT_REQUESTED
      allocation_status[:status_colour] = Colour::RED
      allocation_status[:requested] = Requested::NO
    end

    allocation_status
  end
end
