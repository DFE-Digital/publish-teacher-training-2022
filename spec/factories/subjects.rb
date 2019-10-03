FactoryBot.define do
  factory :subject do
    sequence(:id)
    type { "subject" }
    subject_code { "00" }
    subject_name { "Primary with Mathematics" }
  end
end
