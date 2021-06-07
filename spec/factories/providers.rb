FactoryBot.define do
  factory :provider do
    transient do
      sites { [] }
      recruitment_cycle { build :recruitment_cycle }
      include_counts { [] }
      users { [] }
    end

    sequence(:id, &:to_s)
    sequence(:provider_code) { |n| "A#{n}" }
    provider_name { "ACME SCITT #{provider_code}" }
    provider_type { "lead_school" }
    accredited_body? { false }
    can_add_more_sites? { true }
    courses { [] }
    train_with_us { Faker::Lorem.sentence(word_count: 100) }
    accredited_bodies { [] }
    train_with_disability { Faker::Lorem.sentence(word_count: 100) }
    website { "https://cat.me" }
    email { "info@acme-scitt.org" }
    telephone { "020 8123 4567" }
    ukprn { "12345678" }
    address1 { nil }
    address2 { nil }
    address3 { nil }
    address4 { nil }
    postcode { nil }
    latitude { nil }
    urn { Faker::Number.number(digits: [5, 6].sample) }
    longitude { nil }
    recruitment_cycle_year { recruitment_cycle.year.to_s }
    last_published_at { Time.zone.local(2019).utc.iso8601 }
    content_status { "Published" }
    gt12_contact { "gt12_contact@acme-scitt.org" }
    application_alert_contact { "application_alert_contact@acme-scitt.org" }
    send_application_alerts { "all" }
    can_sponsor_skilled_worker_visa { false }
    can_sponsor_student_visa { false }

    after :build do |provider, evaluator|
      # Necessary gubbins necessary to make JSONAPIClient's associations work.
      provider.sites = []
      evaluator.sites.each do |site|
        provider.sites << site
      end

      provider.courses = []
      evaluator.courses.each do |course|
        provider.courses << course
      end

      provider.users = []
      evaluator.users.each do |user|
        provider.users << user
      end

      provider.contacts = []
      evaluator.contacts.each do |contact|
        provider.contacts << contact
      end

      provider.recruitment_cycle = evaluator.recruitment_cycle
      provider.recruitment_cycle_year = evaluator.recruitment_cycle.year.to_s
    end

    trait :accredited_body do
      accredited_body? { true }
    end

    factory :providers_response, class: Hash do
      data do
        [
          jsonapi(:provider, provider_code: "A0", include_counts: %i[courses]).render,
          jsonapi(:provider, provider_code: "A1", include_counts: %i[courses]).render,
          jsonapi(:provider, provider_code: "A2", include_counts: %i[courses]).render,
        ].map { |d| d[:data] }
      end

      initialize_with { attributes }
    end
  end
end
