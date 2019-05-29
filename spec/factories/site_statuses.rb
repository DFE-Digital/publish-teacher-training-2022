FactoryBot.define do
  factory :site_status, class: Hash do
    sequence(:id)
    status { 'running' }
    has_vacancies? { nil }

    trait :full_time_and_part_time do
      vac_status { 'both_full_time_and_part_time_vacancies' }
      has_vacancies? { true }
    end

    trait :full_time do
      vac_status { 'full_time_vacancies' }
      has_vacancies? { true }
    end

    trait :part_time do
      vac_status { 'part_time_vacancies' }
      has_vacancies? { true }
    end

    trait :no_vacancies do
      vac_status { 'no_vacancies' }
      has_vacancies? { false }
    end

    initialize_with do
      data_attributes = attributes.except(:id, :site)
      JSONAPIMockSerializable.new(
        id,
        'site_statuses',
        attributes: data_attributes,
        relationships: {
          site: site
        }
      )
    end
  end
end
