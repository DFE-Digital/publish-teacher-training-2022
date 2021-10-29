class AllocationUpliftSerializer < JSONAPI::Serializable::Resource
  type "allocation_uplifts"

  belongs_to :allocation

  attributes(*FactoryBot.attributes_for("allocation_uplift").keys)

  attribute :uplifts
end
