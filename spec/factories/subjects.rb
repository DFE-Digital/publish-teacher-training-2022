FactoryBot.define do
  factory :subject do
    sequence(:id, &:to_s)
    type { "subject" }
    subject_code { "00" }
    subject_name { "Primary with Mathematics" }

    trait :english do
      subject_name { "English" }
    end

    trait :mathematics do
      subject_name { "Mathematics" }
    end

    trait :biology do
      subject_name { "Biology" }
    end

    trait :english_with_primary do
      subject_name { "English with primary" }
    end
  end
end
