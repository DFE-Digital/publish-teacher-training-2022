FactoryBot.define do
  factory :site, class: Hash do
    sequence(:code, &:to_s)
    location_name { 'Main Site' + rand(1000000).to_s }

    initialize_with do
      {
        "id" => 1,
        "attributes" => attributes,
        "type" => "sites",
      }
    end
  end
end
