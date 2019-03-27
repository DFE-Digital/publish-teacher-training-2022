FactoryBot.define do
  factory :course, class: Hash do
    transient do
      relationships { [:site_statuses, :provider] }
    end

    sequence(:id)
    sequence(:course_code) { |n| "X10#{n}" }
    name          { "English" }
    site_statuses { [] }
    provider      { nil }

    initialize_with do |evaluator|
      data_attributes = attributes.except(:id, *relationships)
      relationships_map = Hash[
        relationships.map do |relationship|
          [relationship, __send__(relationship)]
        end
      ]

      JSONAPIMockSerializable.new(
        id,
        'courses',
        attributes: data_attributes,
        relationships: relationships_map
      )
    end
  end

  factory :courses_response, class: Hash do
    data {
      [
        build(:course),
        build(:course),
        build(:course)
      ]
    }

    initialize_with { attributes }
  end
end
