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
    sign_in_user_id { Faker::Number.number(digits: 10) }
    associated_with_accredited_body { false }
    notifications_configured { true }

    trait :new do
      state { "new" }
    end

    trait :transitioned do
      state { "transitioned" }
    end

    trait :rolled_over do
      state { "rolled_over" }
    end

    trait :notifications_configured do
      state { "notifications_configured" }
    end

    trait :inactive do
      accept_terms_date_utc { nil }
    end

    trait :admin do
      admin { true }
    end
  end
end
