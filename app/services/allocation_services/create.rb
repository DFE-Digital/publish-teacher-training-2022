module AllocationServices
  class Create
    include PublishService

    def initialize(requested:, accredited_body_code:, provider_id:, number_of_places: nil)
      @requested = requested
      @accredited_body_code = accredited_body_code
      @provider_id = provider_id
      @number_of_places = number_of_places
    end

    def call
      Allocation.create(create_params)
    end

  private

    attr_reader :requested, :accredited_body_code, :provider_id, :number_of_places

    def create_params
      {
        provider_code: accredited_body_code,
        provider_id: provider_id,
        request_type: request_type,
      }.tap do |params_to_return|
        params_to_return[:number_of_places] = number_of_places if number_of_places.present?
      end
    end

    def request_type
      return Allocation::RequestTypes::REPEAT if requested && number_of_places.nil?
      return Allocation::RequestTypes::INITIAL if requested && number_of_places.present?
      return Allocation::RequestTypes::DECLINED unless requested
    end
  end
end
