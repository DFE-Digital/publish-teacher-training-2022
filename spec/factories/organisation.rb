FactoryBot.define do
  factory :organisation do
    skip_create

    sequence(:id)
    name { "Organisation" }
  end
end
