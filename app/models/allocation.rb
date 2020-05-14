class Allocation < Base
  module RequestTypes
    INITIAL = "initial".freeze
    REPEAT = "repeat".freeze
    DECLINED = "declined".freeze
  end

  belongs_to :provider, param: :provider_code, shallow_path: true

  property :number_of_places
  property :request_type

  def has_places?
    number_of_places.to_i.positive?
  end

  def initial_request?
    request_type == Allocation::RequestTypes::INITIAL
  end
end
