FactoryBot.define do
  factory :provider do
    transient do
      sites { [] }
      recruitment_cycle { build :recruitment_cycle }
      include_counts { [] }
    end

    sequence(:id)
    sequence(:provider_code) { |n| "A#{n}" }
    provider_name { "ACME SCITT #{provider_code}" }
    accredited_body? { false }
    can_add_more_sites? { true }
    courses { [] }
    train_with_us { Faker::Lorem.sentence(100) }
    train_with_disability { Faker::Lorem.sentence(100) }
    website { nil }
    email { 'info@acme-scitt.org' }
    telephone { '020 8123 4567' }
    address1 { nil }
    address2 { nil }
    address3 { nil }
    address4 { nil }
    postcode { nil }
    recruitment_cycle_year { '2019' }
    last_published_at { DateTime.new(2019).utc.iso8601 }
    content_status { 'Published' }

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

      provider.recruitment_cycle = evaluator.recruitment_cycle
      provider.recruitment_cycle_year = evaluator.recruitment_cycle.year
    end

    factory :providers_response, class: Hash do
      data {
        [
          jsonapi(:provider, provider_code: "A0", include_counts: %i[courses]).render,
          jsonapi(:provider, provider_code: "A1", include_counts: %i[courses]).render,
          jsonapi(:provider, provider_code: "A2", include_counts: %i[courses]).render
        ].map { |d| d[:data] }
      }

      initialize_with { attributes }
    end
  end
end
