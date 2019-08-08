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

    trait :for_course_outcome do
      errors {
        [
          {
            title: "Invalid qualification",
            detail: "Qualification error",
            source: { pointer: "/data/attributes/qualification" }
          }
        ]
      }
    end

    trait :for_course_publish do
      errors {
        [
          {
            title: "Invalid about_course",
            detail: "About course can't be blank",
            source: { pointer: "/data/attributes/about_course" }
          }
        ]
      }
    end

    trait :for_provider_update do
      errors {
        [
          {
            title: "Invalid train_with_us",
            detail: "Reduce the word count for train with us",
            source: { pointer: "/data/attributes/train_with_us" }
          }
        ]
      }
    end

    trait :for_access_request_create do
      errors {
        [
          {
            title: "Invalid first_name",
            detail: "Enter your first name",
            source: { pointer: "/data/attributes/first_name" }
          }
        ]
      }
    end
  end
end
