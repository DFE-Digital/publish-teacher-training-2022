FactoryBot.define do
  factory :allocation do
    sequence(:id, &:to_s)
    provider_id { nil }
    accreditted_body_id { nil }
    number_of_places { nil }
  end
end
