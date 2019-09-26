FactoryBot.define do
  factory :recruitment_cycle do
    sequence(:id)
    year { "2020" }
    application_start_date { "2019-10-09" }

    trait :next_cycle do
      year { "2021" }
    end

    trait :previous_cycle do
      year { "2019" }
    end
  end
end
