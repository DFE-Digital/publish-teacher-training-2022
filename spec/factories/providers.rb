FactoryBot.define do
  factory :provider, class: Hash do
    transient do
      relationships { %i[courses sites] }
      include_counts { [] }
    end

    sequence(:id)
    sequence(:institution_code) { |n| "A#{n}" }
    institution_name { "ACME SCITT #{institution_code}" }
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
        jsonapi(:provider, institution_code: "A0", include_counts: %i[courses]).render,
        jsonapi(:provider, institution_code: "A1", include_counts: %i[courses]).render,
        jsonapi(:provider, institution_code: "A2", include_counts: %i[courses]).render
      ].map { |d| d[:data] }
    }

    initialize_with { attributes }
  end
end
