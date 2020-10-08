class ProviderSerializer < JSONAPI::Serializable::Resource
  type "providers"

  belongs_to :recruitment_cycle

  has_many :courses do
    meta do
      { count: @object.courses.count }
    end
  end
  has_many :sites
  has_many :users
  has_many :contacts

  attributes(*FactoryBot.attributes_for("provider").keys -
             %i[courses sites users])

  attribute :recruitment_cycle
  attribute :recruitment_cycle_year
end
