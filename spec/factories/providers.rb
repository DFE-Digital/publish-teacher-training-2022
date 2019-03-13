FactoryBot.define do
  factory :provider, class: Hash do
    sequence(:institution_code) { |n| "A#{n}" }
    institution_name { "ACME SCITT #{institution_code}" }

    initialize_with do
      {
        "id" => 1,
        "attributes" => attributes,
        "type" => "providers",
        "relationships" => {
          "courses" => {
            "meta" => {
              "count" => 1
            }
          }
        }
      }
    end
  end

  factory :providers_response, class: Hash do
    data {
      [
        build(:provider, institution_code: "A0"),
        build(:provider, institution_code: "A1"),
        build(:provider, institution_code: "A2")
      ]
    }

    initialize_with { attributes }
  end
end
