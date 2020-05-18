module AllocationServices
  class Create
    include ServicePattern

    def initialize(request_type:, accredited_body_code:, provider_id:, number_of_places: nil)
      @request_type = request_type
      @accredited_body_code = accredited_body_code
      @provider_id = provider_id
      @number_of_places = number_of_places
    end

    def call
      Allocation.create(create_params)
    end

  private

    attr_reader :request_type, :accredited_body_code, :provider_id, :number_of_places

    def create_params
      {
        provider_code: accredited_body_code,
        provider_id: provider_id,
        request_type: request_type,
      }.tap do |params_to_return|
        params_to_return[:number_of_places] = number_of_places if number_of_places.present?
      end
    end
  end
end
