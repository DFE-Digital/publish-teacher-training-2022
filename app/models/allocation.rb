class Allocation < Base
  belongs_to :provider, param: :provider_code

  properties :number_of_places

  def has_places?
    number_of_places.positive?
  end
end
