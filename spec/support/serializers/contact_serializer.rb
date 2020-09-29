class ContactSerializer < JSONAPI::Serializable::Resource
  type "contacts"

  belongs_to :provider

  attribute :name
  attribute :telephone
  attribute :email
  attribute :type
  attribute :permission_given
end
