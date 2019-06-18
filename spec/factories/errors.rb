FactoryBot.define do
  factory :error, class: Hash do
    errors {
      [
        {
          title: "Invalid location_name",
          detail: "Name is missing",
          source: { pointer: "/data/attributes/location_name" }
        },
        {
          title: "Invalid postcode",
          detail: "Postcode is missing",
          source: { pointer: "/data/attributes/postcode" }
        },
        {
          title: "Invalid postcode",
          detail: "Postcode is invalid",
          source: { pointer: "/data/attributes/postcode" }
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
            title: "Invalid about_course",
            detail: "About course can't be blank"
          }
        ]
      }
    end
  end
end
