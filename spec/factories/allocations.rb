FactoryBot.define do
  factory :allocation do
    sequence(:id)
    association :provider
    association :accredited_body, factory: %i(provider accredited_body)
    number_of_places { nil }
  end
end
