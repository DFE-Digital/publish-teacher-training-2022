FactoryBot.define do
  factory :allocation_uplift do
    sequence(:id)
    association :allocation

    uplifts { 5 }
  end
end
