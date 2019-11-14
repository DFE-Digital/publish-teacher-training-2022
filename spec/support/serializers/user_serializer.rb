class UserSerializer < JSONAPI::Serializable::Resource
  type "users"
  has_many :organisations

  attributes(*FactoryBot.attributes_for("user").keys)
end
