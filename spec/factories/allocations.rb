FactoryBot.define do
  factory :allocation do
    sequence(:id)
    association :provider
    association :accredited_body, factory: %i[provider accredited_body]
    number_of_places { nil }

    trait :repeat do
      request_type { "repeat" }
    end

    trait :decline do
      request_type { "decline" }
    end

    trait :initial do
      request_type { "initial" }
    end
  end
end
