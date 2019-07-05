FactoryBot.define do
  factory :user do
    skip_create

    sequence(:id)
    first_name { Faker::Name.first_name }
    last_name  { Faker::Name.last_name }
    email      { Faker::Internet.safe_email("#{first_name} #{last_name}") }
    state      { 'rolled_over' }
    accept_terms_date_utc { Time.current }

    trait :new do
      state { 'new' }
    end

    trait :transitioned do
      state { 'transitioned' }
    end
  end
end
