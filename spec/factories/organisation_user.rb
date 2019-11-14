FactoryBot.define do
  factory :organisation_user do
    skip_create

    sequence(:id)
  end
end
