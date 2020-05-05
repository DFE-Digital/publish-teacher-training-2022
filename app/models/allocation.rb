class Allocation < Base
  module RequestTypes
    INITIAL = "initial".freeze
    REPEAT = "repeat".freeze
    DECLINED = "declined".freeze
  end

  belongs_to :provider, param: :provider_code

  property :number_of_places
  property :request_type
  property :provider_id

  def has_places?
    number_of_places.positive?
  end
end
