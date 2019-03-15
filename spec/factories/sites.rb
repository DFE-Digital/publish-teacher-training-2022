FactoryBot.define do
  factory :site, class: Hash do
    sequence(:id)
    sequence(:code, &:to_s)
    location_name { 'Main Site' }

    initialize_with do
      data_attributes = attributes.except(:id)
      JSONAPIMockSerializable.new(
        id,
        'sites',
        attributes: data_attributes
      )
    end
  end
end
