FactoryBot.define do
  factory :course, class: Hash do
    sequence(:course_code) { |n| "X10#{n}" }
    name { "English" }
    association(:provider)
    has_vacancies? { true }

    initialize_with do
      {
        "id" => 1,
        "attributes" => attributes,
        "type" => "courses",
        "relationships" => {
          "provider" => {
            "meta" => {
              "included" => false
            }
          },
        }
      }
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
