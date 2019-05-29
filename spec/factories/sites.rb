FactoryBot.define do
  factory :site, class: Hash do
    sequence(:id)
    sequence(:code, &:to_s)
    location_name { 'Main Site' }
    address1 { nil }
    address2 { nil }
    address3 { nil }
    address4 { nil }
    postcode { nil }

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
