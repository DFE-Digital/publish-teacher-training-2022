FactoryBot.define do
  factory :contact do
    sequence(:id, &:to_s)
    name { Faker::Name.name }
    telephone { Faker::Number.number(digits: 10).to_s }
    email { Faker::Internet.email }
    permission_given { true }

    trait :admin do
      type { "admin" }
    end
  end
end
