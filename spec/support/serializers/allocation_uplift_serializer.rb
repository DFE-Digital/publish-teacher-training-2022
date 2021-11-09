class AllocationUpliftSerializer < JSONAPI::Serializable::Resource
  type "allocation_uplifts"

  belongs_to :allocation

  attribute :uplifts
end
