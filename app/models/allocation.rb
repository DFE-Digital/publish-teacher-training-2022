class Allocation < Base
  belongs_to :provider, param: :provider_code

  property :number_of_places

  def has_places?
    number_of_places.positive?
  end
end
