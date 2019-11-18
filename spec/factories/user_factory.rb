FactoryBot.define do
  factory :user do
    skip_create

    sequence(:id)
    first_name { Faker::Name.first_name }
    last_name  { Faker::Name.last_name }
    email      { Faker::Internet.safe_email(name: "#{first_name} #{last_name}") }
    state      { "rolled_over" }
    admin      { false }
    accept_terms_date_utc { Time.current }
    organisation_users { [] }

    trait :new do
      state { "new" }
    end

    trait :transitioned do
      state { "transitioned" }
    end

    trait :inactive do
      accept_terms_date_utc { nil }
    end

    trait :admin do
      admin { true }
    end
  end
end
