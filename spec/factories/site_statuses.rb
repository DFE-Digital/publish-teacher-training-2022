FactoryBot.define do
  factory :site_status, class: Hash do
    sequence(:id)
    vac_status { 'both_full_time_and_part_time_vacancies' }

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
