FactoryBot.define do
  factory :provider, class: Hash do
    transient do
      relationships { %i[courses sites] }
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
        relationships: relationships_map
      )
    end
  end

  factory :providers_response, class: Hash do
    data {
      [
        jsonapi(:provider, institution_code: "A0"),
        jsonapi(:provider, institution_code: "A1"),
        jsonapi(:provider, institution_code: "A2")
      ]
    }

    initialize_with { attributes }
  end
end
