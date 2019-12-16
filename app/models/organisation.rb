class Organisation < Base
  has_many :organisation_users
  has_many :users, through: :organisation_users
  has_many :providers

  properties :name, :nctl_ids
end
