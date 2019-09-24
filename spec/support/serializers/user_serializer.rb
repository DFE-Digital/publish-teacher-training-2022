class UserSerializer < JSONAPI::Serializable::Resource
  type "users"

  attributes(*FactoryBot.attributes_for("user").keys)
end
