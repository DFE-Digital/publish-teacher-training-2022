class AccessRequestSerializer < JSONAPI::Serializable::Resource
  type "access_request"

  belongs_to :requester

  attributes(*FactoryBot.attributes_for("access_request").keys)
end
