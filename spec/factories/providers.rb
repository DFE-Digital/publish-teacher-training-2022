FactoryBot.define do
  factory :provider, class: Hash do
    transient do
      relationships { %i[courses sites] }
      include_counts { [] }
    end

    sequence(:id)
    sequence(:provider_code) { |n| "A#{n}" }
    provider_name { "ACME SCITT #{provider_code}" }
    accredited_body? { false }
    courses { [] }
    sites { [] }

    initialize_with do |_evaluator|
      data_attributes = attributes.except(:id, *relationships)
      relationships_map = Hash[
        relationships.map do |relationship|
          [relationship, __send__(relationship)]
        end
      ]

      JSONAPIMockSerializable.new(
        id,
        'providers',
        attributes: data_attributes,
        relationships: relationships_map,
        include_counts: include_counts
      )
    end
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
