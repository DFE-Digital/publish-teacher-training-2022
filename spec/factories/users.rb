FactoryBot.define do
  factory :user, parent: :jsonapi_mock_serializable do
    transient do
      jsonapi_type           { 'user' }
      jsonapi_relationships  { [] }
      jsonapi_include_counts { [] }
    end

    sequence(:id)
    first_name { Faker::Name.first_name }
    last_name  { Faker::Name.last_name }
    email      { Faker::Internet.safe_email("#{first_name} #{last_name}") }
    state      { 'transitioned' }

    trait :new do
      state { 'new' }
    end
  end
end
