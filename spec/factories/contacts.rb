FactoryBot.define do
  factory :contact do
    sequence(:id, &:to_s)
    name { Faker::Name.name }
    telephone { Faker::Number.number(digits: 10).to_s }
    email { Faker::Internet.email }

    trait :admin do
      type { "admin" }
    end

    trait :utt do
      type { "utt" }
    end

    trait :web_link do
      type { "web_link" }
    end

    trait :fraud do
      type { "fraud" }
    end

    trait :finance do
      type { "finance" }
    end
  end
end
