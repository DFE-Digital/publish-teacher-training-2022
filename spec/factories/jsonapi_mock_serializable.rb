FactoryBot.define do
  factory :jsonapi_mock_serializable, class: Hash do
    initialize_with do |_evaluator|
      data_attributes = attributes.except(:id, *jsonapi_relationships)
      relationships_map = Hash[
        jsonapi_relationships.map do |relationship|
          [relationship, __send__(relationship)]
        end
      ]

      JSONAPIMockSerializable.new(
        id,
        jsonapi_type,
        attributes: data_attributes,
        relationships: relationships_map,
        include_counts: jsonapi_include_counts
      )
    end
  end
end
