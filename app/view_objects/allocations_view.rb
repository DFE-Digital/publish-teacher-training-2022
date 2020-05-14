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

  module RequestType
    INITIAL = "initial".freeze
  end

  def initialize(training_providers:, allocations:)
    @training_providers = training_providers
    @allocations = allocations
  end

  def repeat_allocation_statuses
    filtered_training_providers.map do |training_provider|
      matching_allocation = find_matching_allocation(training_provider, repeat_allocations)
      build_repeat_allocations(matching_allocation, training_provider)
    end
  end

  def initial_allocation_statuses
    statuses = @training_providers.map do |training_provider|
      matching_allocation = find_matching_allocation(training_provider, initial_allocations)
      build_initial_allocations(matching_allocation, training_provider)
    end

    statuses.compact
  end

private

  def filtered_training_providers
    # When displaying 'repeat allocation statuses'
    # we need to first filter out those training providers
    # who will be allocated places for the first time (i.e. where the accredited provider)
    # has made initial allocation requests on their behalf)
    training_provider_ids = initial_allocations.map { |allocation| allocation.provider.id }
    @training_providers.reject { |tp| training_provider_ids.include?(tp.id) }
  end

  def repeat_allocations
    @allocations.reject { |allocation| allocation.request_type == RequestType::INITIAL }
  end

  def initial_allocations
    @allocations.select { |allocation| allocation.request_type == RequestType::INITIAL }
  end

  def find_matching_allocation(training_provider, allocations)
    allocations.find { |allocation| allocation.provider.id == training_provider.id }
  end

  def build_repeat_allocations(matching_allocation, training_provider)
    allocation_status = {
      training_provider_name: training_provider.provider_name,
      training_provider_code: training_provider.provider_code,
    }

    if yet_to_request?(matching_allocation)
      allocation_status[:status] = Status::YET_TO_REQUEST
      allocation_status[:status_colour] = Colour::GREY
    end

    if requested?(matching_allocation)
      allocation_status[:status] = Status::REQUESTED
      allocation_status[:status_colour] = Colour::GREEN
      allocation_status[:requested] = Requested::YES
    end

    if not_requested?(matching_allocation)
      allocation_status[:status] = Status::NOT_REQUESTED
      allocation_status[:status_colour] = Colour::RED
      allocation_status[:requested] = Requested::NO
    end

    if matching_allocation&.id
      allocation_status[:id] = matching_allocation.id
    end

    allocation_status
  end

  def build_initial_allocations(matching_allocation, training_provider)
    return if matching_allocation.nil?

    {
      training_provider_name: training_provider.provider_name,
      training_provider_code: training_provider.provider_code,
      status_colour: Colour::GREEN,
      requested: Requested::YES,
      status: "#{matching_allocation.number_of_places} PLACES REQUESTED",
    }
  end

  def not_requested?(matching_allocation)
    matching_allocation && matching_allocation[:number_of_places].zero?
  end

  def requested?(matching_allocation)
    matching_allocation && matching_allocation[:number_of_places] >= 1
  end

  def yet_to_request?(matching_allocation)
    matching_allocation.nil?
  end
end
