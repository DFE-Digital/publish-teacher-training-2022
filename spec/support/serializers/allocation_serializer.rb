class AllocationSerializer < JSONAPI::Serializable::Resource
  type "allocations"

  belongs_to :accredited_body
  belongs_to :provider

  attributes(*FactoryBot.attributes_for("allocation").keys)
end
