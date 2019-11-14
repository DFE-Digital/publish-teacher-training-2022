class OrganisationUser < Base
  belongs_to :organisation
  belongs_to :user
end
