FactoryBot.define do
  factory :allocation do
    sequence(:id)
    association :provider
    association :accredited_body, factory: %i[provider accredited_body]

    number_of_places { nil }
    confirmed_number_of_places { nil }
    trait :repeat do
      request_type { "repeat" }
    end

    trait :declined do
      request_type { "declined" }
    end

    trait :initial do
      request_type { "initial" }
    end

    trait :with_uplift do
      association :allocation_uplift

      after :build do |allocation|
        # Neccessary hack to get attributes to persist through JSONAPI build, specifically the uplifts attribute
        # Other users have experienced similar issues: https://github.com/JsonApiClient/json_api_client/issues/342

        allocation.allocation_uplift.uplifts = 5
      end
    end
  end
end
