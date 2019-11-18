class OrganisationSerializer < JSONAPI::Serializable::Resource
  type "organisation_users"
  belongs_to :organisation
  belongs_to :user

  attributes(*FactoryBot.attributes_for("organisation_user").keys)
end
