class Allocation < Base
  belongs_to :provider, param: :provider_code

  property :accredited_body_id
  property :number_of_places
  property :provider_id

  def has_places?
    number_of_places.positive?
  end
end
