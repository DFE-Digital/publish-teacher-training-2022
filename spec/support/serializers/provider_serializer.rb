class ProviderSerializer < JSONAPI::Serializable::Resource
  type 'providers'

  has_many :courses
  has_many :sites

  attributes(*FactoryBot.attributes_for('provider').keys)
end
