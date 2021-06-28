FactoryBot.define do
  factory :error, class: Hash do
    errors do
      [
        {
          title: "Invalid location_name",
          detail: "Name is missing",
          source: { pointer: "/data/attributes/location_name" },
        },
        {
          title: "Invalid postcode",
          detail: "Postcode is missing",
          source: { pointer: "/data/attributes/postcode" },
        },
      ]
    end

    initialize_with do
      attributes
    end

    trait :for_course_outcome do
      errors do
        [
          {
            title: "Invalid qualification",
            detail: "Qualification error",
            source: { pointer: "/data/attributes/qualification" },
          },
        ]
      end
    end

    trait :for_course_publish do
      errors do
        [
          {
            title: "Invalid about_course",
            detail: "About course can't be blank",
            source: { pointer: "/data/attributes/about_course" },
          },
        ]
      end
    end

    trait :for_provider_update do
      errors do
        [
          {
            title: "Invalid train_with_us",
            detail: "Reduce the word count for train with us",
            source: { pointer: "/data/attributes/train_with_us" },
          },
        ]
      end
    end

    trait :for_access_request_create do
      errors do
        [
          {
            title: "Invalid first_name",
            detail: "Enter your first name",
            source: { pointer: "/data/attributes/first_name" },
          },
        ]
      end
    end
  end
end
