FactoryBot.define do
  factory :recruitment_cycle do
    sequence(:id)
    year { '2019' }

    trait :next_cycle do
      year { '2020' }
    end
  end
end
