class AllocationSerializer < JSONAPI::Serializable::Resource
  type "allocations"

  belongs_to :accredited_body
  belongs_to :provider
  has_one :allocation_uplift

  attributes(*FactoryBot.attributes_for("allocation").keys)

  attribute :number_of_places
  attribute :request_type
end
