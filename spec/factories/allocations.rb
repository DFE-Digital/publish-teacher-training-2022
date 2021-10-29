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

    trait :with_allocation_uplift do
      association :allocation_uplift
    end

    after :build do |allocation|
      # Neccessary hack to get attributes to persist through JSONAPI build

      allocation.allocation_uplift&.uplifts = 5
    end
  end
end
