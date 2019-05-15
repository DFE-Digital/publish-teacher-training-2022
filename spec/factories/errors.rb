FactoryBot.define do
  factory :error, class: Hash do
    errors {
      [
        {
          title: "Invalid location_name",
          detail: "Location name can't be blank",
          source: { pointer: "/data/attributes/location_name" }
        }
      ]
    }

    initialize_with do
      attributes
    end

    trait :for_course_publish do
      errors {
        [
          {
            title: "Invalid latest_enrichment__about_course",
            detail: "About course can't be blank"
          }
        ]
      }
    end
  end
end
