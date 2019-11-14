FactoryBot.define do
  factory :access_request do
    skip_create

    sequence(:id)
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email_address { Faker::Internet.safe_email(name: "#{first_name} #{last_name}") }
    organisation { "organisation" }
    reason { Faker::Lorem.sentence(word_count: 10) }
    request_date_utc { Time.now.utc }
    status { %w[requested approved completed declined].sample }
    requester { build :user }
  end
end
